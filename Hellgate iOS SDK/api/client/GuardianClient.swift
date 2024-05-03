protocol GuardianClientAPI {
    func tokenizeCard(apiKey: String, cardData: CardData) async -> Result<GuardianceTokenizeResponse, Error>
}

class GuardianClient: GuardianClientAPI {
    private let baseURL: URL
    private let client: HttpClient

    enum GuardianError: Error {
        case cardDataYearMonthParsing
    }

    init(baseURL: URL, client: HttpClient) {
        self.baseURL = baseURL
        self.client = client
    }

    func tokenizeCard(apiKey: String, cardData: CardData) async -> Result<GuardianceTokenizeResponse, Error> {
        var url = self.baseURL
        url.appendPathComponent("tokenize")

        if let body = GuardTokenizeRequest(cardData: cardData) {
            return await self.client.request(
                method: "POST",
                url: url,
                body: body,
                headers: ["x-api-key": apiKey]
            )
        } else {
            return .failure(GuardianError.cardDataYearMonthParsing)
        }
    }
}

struct GuardTokenizeRequest: Encodable {
    let expiryMonth: Int
    let expiryYear: Int
    let accountNumber: String
    let securityCode: String

    enum CodingKeys: String, CodingKey {
        case expiryMonth = "expiry_month"
        case expiryYear = "expiry_year"
        case accountNumber = "account_number"
        case securityCode = " issuer_identification_number"
    }

    init?(cardData: CardData) {
        guard let month = Int(cardData.month), let year = Int(cardData.year) else {
            return nil
        }

        self.accountNumber = cardData.cardNumber
        self.securityCode = cardData.cvc
        self.expiryMonth = month
        self.expiryYear = year + 2000
    }
}

struct GuardianceTokenizeResponse: Decodable {
    let id: String
}
