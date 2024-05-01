import SwiftUI
public let HG_STAGING_URL = URL(string: "https://staging.hellgate.dev")!

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
}

enum NextAction: String, Decodable {
    case tokenize_card
    case wait
}

public enum TokenizeCardResponse {
    public struct Success: Decodable {
        let id: String
    }

    public struct Failure: Error, Decodable {
        let message: String
        // TODO: Add other properties
    }
}

public protocol CardHandler {
    func tokenizeCard(
        _ cardNumberView: ViewState,
        _ cvcView: ViewState,
        _ expiryView: ViewState,
        _ additional: [ViewState]
    ) -> Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure>
}

class CardHandle: CardHandler {
    // let tokenService: TokenService
    let sessionId: String

    init(sessionId: String) {
        self.sessionId = sessionId
    }

    func tokenizeCard(
        _ cardNumberView: ViewState,
        _ cvcView: ViewState,
        _ expiryView: ViewState,
        _ additional: [ViewState]
    ) -> Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure> {
        print("TokenizeCard")
        print(cardNumberView.value)
        print(cvcView.value)
        print(expiryView.value)

        for view in additional {
            print(view.value)
        }

        print("Done")

        // TODO: Tokenize card
        return .success(.init(id: ""))
    }
}

public protocol Hellgate {
    func fetchSessionStatus() async -> SessionState
    func cardHandler() async -> CardHandler?
}

class InternalHellgate {
    let baseUrl: URL
    let sessionId: String
    let client: HttpClient

    init(baseUrl: URL, sessionId: String, session: URLSession = .shared) {
        self.baseUrl = baseUrl
        self.sessionId = sessionId
        self.client = HttpClient(session: session)
    }
}

public enum SessionState {
    case REQUIRE_TOKENIZATION
    case WAITING
    case COMPLETED
    case UNKNOWN
}

extension InternalHellgate: Hellgate {

    func fetchSessionStatus() async -> SessionState {
        var url = baseUrl
        url.appendPathComponent("sessions")
        url.appendPathComponent(sessionId)

        let response: Result<SessionResponse, Error> = await self.client.request(method: "GET", url: url)

        print(response)

        if case let .success(session) = response {
            if let nextAction = session.nextAction {
                switch nextAction {
                case .tokenize_card:
                    return SessionState.REQUIRE_TOKENIZATION
                case .wait:
                    return SessionState.WAITING
                }
            } else {
                switch session.status {
                case "success": return SessionState.COMPLETED
                default: return SessionState.UNKNOWN
                }
            }
        } else {
            return SessionState.UNKNOWN
        }
    }

    func cardHandler() async -> CardHandler? {
        let state = await fetchSessionStatus()

        if state != .REQUIRE_TOKENIZATION {
            return nil
        } else {
            return CardHandle(sessionId: sessionId)
        }
    }
}

public func initHellgate(baseUrl: URL, sessionId: String) async -> Hellgate {
    InternalHellgate(baseUrl: baseUrl, sessionId: sessionId)
}
