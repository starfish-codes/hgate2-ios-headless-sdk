protocol ExTokenizeClientAPI {
    func tokenizeCard(apiKey: String, cardData: CardData) async -> Result<ExTokenizeResponse, Error>
}

class ExTokenizeClient: ExTokenizeClientAPI {
    private let baseURL: URL
    private let client: HttpClient

    enum ExTokenizeClient: Error {
        case invalidCardData
    }

    init(baseURL: URL, client: HttpClient) {
        self.baseURL = baseURL
        self.client = client
    }

    func tokenizeCard(apiKey: String, cardData: CardData) async -> Result<ExTokenizeResponse, Error> {
        var url = self.baseURL
        url.appendPathComponent("tokenize")

        if let body = GuardTokenizeRequest(cardData: cardData) {
            return await self.client.request(
                method: "POST",
                url: url,
                body: body,
                headers: ["BT-API-KEY": apiKey]
            )
        } else {
            return .failure(ExTokenizeClient.invalidCardData)
        }
    }
}

struct ExTokenizeRequest: Encodable {
    // TODO:
}

struct ExTokenizeResponse: Decodable {
    let id: String
}
