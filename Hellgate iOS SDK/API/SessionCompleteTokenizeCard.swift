struct SessionCompleteTokenizeCard: Encodable {
    let action: String
    let result: Result

    init(action: String = "tokenize_card", result: Result) {
        self.action = action
        self.result = result
    }

    struct Result: Encodable {
        let tokenId: String
        let additionalData: AdditionalData?

        enum CodingKeys: String, CodingKey {
            case tokenId = "token_id"
            case additionalData = "additional_data"
        }
    }

    struct AdditionalData: Encodable {
        let cardholderName: String?

        enum CodingKeys: String, CodingKey {
            case cardholderName = "cardholder_name"
        }
    }
}
