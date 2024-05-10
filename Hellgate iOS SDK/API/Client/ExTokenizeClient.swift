import Foundation

protocol ExTokenizeClientAPI {
    func tokenizeCard(apiKey: String, cardData: CardData) async -> Result<ExTokenizeResponse, Error>
}

class ExTokenizeClient: ExTokenizeClientAPI {
    private let baseURL: URL
    private let client: HttpClientSession

    enum ExTokenizeError: Error {
        case invalidCardData
    }

    init(baseURL: URL, client: HttpClientSession) {
        self.baseURL = baseURL
        self.client = client
    }

    func tokenizeCard(apiKey: String, cardData: CardData) async -> Result<ExTokenizeResponse, Error> {
        var url = self.baseURL
        url.appendPathComponent("tokenize")

        if let cardDataRequest = ExTokenizeRequest.CardDataRequest(cardData: cardData) {
            let body = ExTokenizeRequest(cardData: cardDataRequest)

            return await self.client.request(
                method: "POST",
                url: url,
                body: body,
                headers: ["BT-API-KEY": apiKey]
            )
        } else {
            return .failure(ExTokenizeError.invalidCardData)
        }
    }
}

struct ExTokenizeRequest: Encodable {
    let data: CardDataRequest
    let type: String
    let mask: Mask

    init(cardData: CardDataRequest, type: String = "card") {
        self.data = cardData
        self.type = type
        self.mask = Mask(
            expirationMonth: String(data.expiryMonth),
            expirationYear: String(data.expiryYear),
            number: data.accountNumber
        )
    }

    struct CardDataRequest: Encodable {
        let expiryMonth: Int
        let expiryYear: Int
        let accountNumber: String
        let securityCode: String

        enum CodingKeys: String, CodingKey {
            case expiryMonth = "expiry_month"
            case expiryYear = "expiry_year"
            case accountNumber = "account_number"
            case securityCode = "issuer_identification_number"
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

    struct Mask: Encodable {
        let expirationMonth: String
        let expirationYear: String
        let number: String

        enum CodingKeys: String, CodingKey {
            case expirationMonth = "expiration_month"
            case expirationYear = "expiration_year"
            case number
        }
    }
}

struct ExTokenizeResponse: Decodable {
    let id: String
}
