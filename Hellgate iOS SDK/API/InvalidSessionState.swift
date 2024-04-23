public struct InvalidSessionState: Error {
    enum State {
        case notTokenizedCard(String)
        case notTDSToComplete(String)
    }

    private let state: State

    init(state: State) {
        self.state = state
    }

    var localizedDescription: String {
        switch self.state {
        case .notTokenizedCard(let string):
            return "Session is not in correct state to tokenize card, actual state: \(string)"
        case .notTDSToComplete(let string):
            return "Session is not in correct state to complete TDS, actual state: \(string)"
        }
    }
}
