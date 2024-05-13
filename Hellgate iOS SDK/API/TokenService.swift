import Foundation

protocol TokenServiceProvider {
    func tokenize(
        sessionId: String,
        cardData: CardData,
        additionalData: [AdditionalFieldType: String]
    ) async -> Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure>
}

class TokenService: TokenServiceProvider {
    let hellgateClient: HellgateClientAPI
    let client: HttpClientSession

    init(
        hellgateClient: HellgateClientAPI,
        client: HttpClientSession
    ) {
        self.hellgateClient = hellgateClient
        self.client = client
    }

    func tokenize(
        sessionId: String,
        cardData: CardData,
        additionalData: [AdditionalFieldType: String]
    ) async -> Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure> {

        let result = await hellgateClient.sessionStatus(sessionId: sessionId)

        if case let .success(sessionStatus) = result {

            guard sessionStatus.nextAction == .tokenize_card,
                  let data = sessionStatus.data,
                  let apiKey = data.apiKey,
                  let baseUrl = data.baseUrl,
                  let url = URL(string: baseUrl) else {
                return .failure(.init(message: "Tokenization failed"))
            }

            var tokenId: String
            switch data.provider {
            case .external:
                let response = await ExTokenizeClient(baseURL: url, client: client)
                    .tokenizeCard(apiKey: apiKey, cardData: cardData)

                if case let .success(data) = response {
                    tokenId = data.id
                } else {
                    return .failure(.init(message: "Tokenization failed"))
                }
            case .guardian:
                let response = await GuardianClient(baseURL: url, client: client)
                    .tokenizeCard(apiKey: apiKey, cardData: cardData)

                if case let .success(data) = response {
                    tokenId = data.id
                } else {
                    return .failure(.init(message: "Tokenization failed"))
                }
            default:
                return .failure(.init(message: "Tokenization failed"))
            }

            let response = await hellgateClient.completeTokenizeCard(
                sessionId: sessionId,
                tokenId: tokenId,
                additionalData: additionalData
            )

            if case let .success(sessionStatus) = response,
               let data = sessionStatus.data,
               let tokenId = data.tokenId {
                return .success(.init(id: tokenId))
            }
        }

        return .failure(.init(message: "Tokenization failed"))
    }
}
