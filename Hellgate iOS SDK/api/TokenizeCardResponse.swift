public enum TokenizeCardResponse {
    public struct Success: Decodable {
        public let id: String
    }

    public struct Failure: Error, Decodable {
        let message: String
        // TODO: Add other properties

        var localizedDescription: String {
            message
        }
    }
}
