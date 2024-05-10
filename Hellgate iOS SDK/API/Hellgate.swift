import SwiftUI

public let HG_STAGING_URL = URL(string: "https://staging.hellgate.dev")!

public protocol Hellgate {
    func fetchSessionStatus() async -> SessionState
    func cardHandler() async -> Result<CardHandler, InvalidSessionState>
}

class InternalHellgate {
    let baseUrl: URL
    let sessionId: String
    let client: HttpClient
    let hellgateClient: HellgateClientAPI

    init(baseUrl: URL, sessionId: String, client: HttpClient, hellgateClient: HellgateClientAPI) {
        self.baseUrl = baseUrl
        self.sessionId = sessionId
        self.client = client
        self.hellgateClient = hellgateClient
    }
}

extension InternalHellgate: Hellgate {

    func fetchSessionStatus() async -> SessionState {
        let response: Result<SessionResponse, Error> = await self.hellgateClient.sessionStatus(sessionId: sessionId)

        #if DEBUG
        print(response)
        #endif

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

    func cardHandler() async -> Result<CardHandler, InvalidSessionState> {
        let state = await fetchSessionStatus()

        if state != .REQUIRE_TOKENIZATION {
            return .failure(.init(state: .notTokenizedCard(state.rawValue)))
        } else {
            return .success(
                CardHandle(
                    tokenService: TokenService(
                        hellgateClient: self.hellgateClient,
                        client: self.client
                    ),
                    sessionId: sessionId
                )
            )
        }
    }
}

public func initHellgate(baseUrl: URL, sessionId: String) async -> Hellgate {
    let client = HttpClient()
    let hellgateClient = HellgateClient(baseURL: baseUrl, client: client)

    return InternalHellgate(
        baseUrl: baseUrl,
        sessionId: sessionId,
        client: client,
        hellgateClient: hellgateClient
    )
}
