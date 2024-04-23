public enum TokenizeCardResponse {
    public struct Success: Decodable {
        public let id: String
    }

    public struct Failure: Error, Decodable {
        let message: String

        var localizedDescription: String {
            message
        }
    }
}
