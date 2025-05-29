public struct SessionResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case data
        case nextAction = "next_action"
        case status
    }

    let data: TokenData?
    let nextAction: NextAction?
    let status: String?

    struct TokenData: Decodable {
        let tokenId: String?

        let apiKey: String?
        let provider: Provider?
        let baseUrl: String?
        let jwk: JWK?

        enum CodingKeys: String, CodingKey {
            case tokenId = "token_id"
            case apiKey = "api_key"
            case provider
            case baseUrl = "base_url"
            case jwk = "jwk"
        }
    }

    struct JWK: Decodable {
        let kty: String?
        let n: String?
        let e: String?
    }

    enum Provider: String, Decodable {
        case external = "basis_theory"
        case guardian
    }

    enum NextAction: String, Decodable {
        case tokenize_card
        case wait
    }
}
