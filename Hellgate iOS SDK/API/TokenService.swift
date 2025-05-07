import Foundation
import JOSESwift

protocol TokenServiceProvider {
    func tokenize(
        sessionId: String,
        cardData: CardData,
        additionalData: [AdditionalFieldType: String]
    ) async -> Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure>
}

class TokenService: TokenServiceProvider {
    private let keyMgmtAlg: KeyManagementAlgorithm = .RSAOAEP
    private let contentEncAlg: ContentEncryptionAlgorithm = .A256GCM

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

        guard case let .success(sessionStatus) = result else {
            return .failure(.init(message: "Tokenization failed"))
        }

        guard sessionStatus.nextAction == .tokenize_card,
              let data = sessionStatus.data,
              let apiKey = data.apiKey,
              let baseUrl = data.baseUrl,
              let url = URL(string: baseUrl) else {
            return .failure(.init(message: "Tokenization failed"))
        }

        var tokenId: String
        var response: Result<SessionResponse, Error>

        switch data.provider {
        case .external:
            let tokenResponse = await ExTokenizeClient(baseURL: url, client: client)
                .tokenizeCard(apiKey: apiKey, cardData: cardData)

            if case let .success(data) = tokenResponse {
                tokenId = data.id

                response = await hellgateClient.completeTokenizeCard(
                    sessionId: sessionId,
                    tokenId: tokenId,
                    additionalData: additionalData
                )
            } else {
                return .failure(.init(message: "Tokenization failed"))
            }
        case .guardian:
            let plainCardData = GuardianCardData(cardData: cardData, additionalData: additionalData)

            do {
                // encrypt the card data
                let cardData = try encryptAndSerializeAsJWE(payload: plainCardData, with: data.jwk)

                response = await hellgateClient.completeTokenizeCard(sessionId: sessionId, encryptedCardData: cardData)
            } catch {
                return .failure(error)
            }
        default:
            return .failure(.init(message: "Tokenization failed"))
        }

        return if case let .success(sessionStatus) = response, let tokenId = sessionStatus.data?.tokenId {
            .success(.init(id: tokenId))
        } else {
            .failure(.init(message: "Tokenization failed"))
        }
    }
}

private extension TokenService {

    func encryptAndSerializeAsJWE(
        payload: Encodable, with jwk: SessionResponse.JWK?,
    ) throws(TokenizeCardResponse.Failure) -> String {
        // check if we have everything we need
        guard let modulus = jwk?.n, let exponent = jwk?.e else {
            throw TokenizeCardResponse.Failure(message: "Tokenization failed: Missing required JWK RSA parameters")
        }

        let jsonCardData: Data = try runCatching(errorMsg: "Failed to encode payload") {
            try JSONEncoder().encode(payload)
        }

        // generate the public key from the parameters passed via the session from the backend
        let publicKey: SecKey = try runCatching(errorMsg: "Failed to create RSA public key") {
            try RSAPublicKey(modulus: modulus, exponent: exponent).converted(to: SecKey.self)
        }

        guard let encrypter = Encrypter(
            keyManagementAlgorithm: keyMgmtAlg,
            contentEncryptionAlgorithm: contentEncAlg,
            encryptionKey: publicKey
        ) else {
            throw TokenizeCardResponse.Failure(message: "Tokenization failed: Failed to encrypt payload")
        }

        let header = JWEHeader(keyManagementAlgorithm: keyMgmtAlg, contentEncryptionAlgorithm: contentEncAlg)
        let payload = Payload(jsonCardData)

        return try runCatching(errorMsg: "Failed to serialize JWE") {
            // this is where the actual encryption of the payload happens
            try JWE(header: header, payload: payload, encrypter: encrypter).compactSerializedString
        }
    }

    private func runCatching<T>(errorMsg: String, block: () throws -> T) throws(TokenizeCardResponse.Failure) -> T {
        do {
            return try block()
        } catch {
            throw TokenizeCardResponse.Failure(message: "Tokenization failed: \(errorMsg)")
        }
    }

}

struct GuardianCardData: Encodable {
    let expiryMonth: Int
    let expiryYear: Int
    let accountNumber: String
    let securityCode: String
    let additionalData: AdditionalData?

    enum CodingKeys: String, CodingKey {
        case expiryMonth = "expiry_month"
        case expiryYear = "expiry_year"
        case accountNumber = "account_number"
        case securityCode = "security_code"
        case additionalData = "additional_data"
    }

    init?(cardData: CardData, additionalData: [AdditionalFieldType: String]) {
        guard let month = Int(cardData.month), let year = Int(cardData.year) else {
            return nil
        }

        self.accountNumber = cardData.cardNumber
        self.securityCode = cardData.cvc
        self.expiryMonth = month
        self.expiryYear = year + 2000
        self.additionalData = additionalData.isEmpty ? nil: .init(
            cardholderName: additionalData[.CARDHOLDER_NAME]
        )
    }

}
