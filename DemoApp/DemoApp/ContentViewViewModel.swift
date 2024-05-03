import Hellgate_iOS_SDK

struct Session: Decodable {
    let session_id: String
}

class ContentViewViewModel: ObservableObject {
    static let sandboxURL = URL(string: "https://sandbox.hellgate.io")!

    private var hellgate: Hellgate?

    @Published var cardNumberViewState = ViewState(state: .blank)
    @Published var expiryViewState = ViewState(state: .blank)
    @Published var cvcViewState = ViewState(state: .blank)

    @Published var secretKey = "sk_sndbx_AZhTZM8yTJ39D3fDtZI"
    @Published var sessionId = ""
    @Published var sessionState: SessionState?
    @Published var token: String?

    @Published var showTokenizeWaitingSpinner = false

    // This called needs to be performed on your backend servers
    private func fetchSessionId() async -> String {
        var url = Self.sandboxURL
        url.appendPathComponent("tokens")
        url.appendPathComponent("session")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(secretKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print(String(data: data, encoding: .utf8)!)

            let result = try JSONDecoder().decode(Session.self, from: data)
            return result.session_id
        } catch {
            print(error)
        }

        return ""
    }

    @MainActor
    func initSession() async {
        showTokenizeWaitingSpinner = false

        // Retrieve the session id from your backend services
        let sessionId = await fetchSessionId()
        self.sessionId = sessionId

        // Initialise Hellgate with the session id
        hellgate = await initHellgate(baseUrl: Self.sandboxURL, sessionId: sessionId)
        await sessionStatus()
    }

    @MainActor
    func sessionStatus() async {
        guard let hellgate = self.hellgate else { return }
        self.sessionState = await hellgate.fetchSessionStatus()
    }

    @MainActor
    func tokenize() async {
        guard let hellgate = self.hellgate else { return }

        let result = await hellgate.cardHandler()

        if case let .success(handler) = result {
            let response = await handler.tokenizeCard(
                cardNumberViewState,
                cvcViewState,
                expiryViewState,
                [:]
            )
            print(response)

            switch response {
            case let .success(result):
                self.token = result.id
            case let .failure(err):
                print(err.localizedDescription)
            }
        }

        await sessionStatus()
    }
}
