public struct SessionResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case data
        case nextAction = "next_action"
        case status
    }

    let data: [String: String]?
    let nextAction: NextAction?
    let status: String?

    //    struct TokenId: Decodable {
    //        let tokenId: String
    //    }
    //
    //    struct TokenizationParam: Decodable {
    //        let apiKey: String
    //        let provider: Provider
    //        let baseUrl: String
    //    }

    enum Provider: String, Decodable {
        case external = "basis_theory"
        case guardian
    }

    enum NextAction: String, Decodable {
        case tokenize_card
        case wait
    }
}
