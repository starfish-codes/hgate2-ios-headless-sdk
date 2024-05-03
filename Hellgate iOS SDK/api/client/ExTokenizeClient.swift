protocol ExTokenizeClientAPI {
    func tokenizeCard(apiKey: String, cardData: CardData) async -> Result<ExTokenizeResponse, Error>
}

class ExTokenizeClient: ExTokenizeClientAPI {
    private let baseURL: URL
    private let client: HttpClient

    enum ExTokenizeClient: Error {
        case notImplemented
    }

    init(baseURL: URL, client: HttpClient) {
        self.baseURL = baseURL
        self.client = client
    }

    func tokenizeCard(apiKey: String, cardData: CardData) async -> Result<ExTokenizeResponse, Error> {
        return .failure(ExTokenizeClient.notImplemented)
    }
}

struct ExTokenizeRequest: Encodable {

}

struct ExTokenizeResponse: Decodable {
    let id: String
}
