public enum TokenizeCardResponse {
    public struct Success: Decodable {
        let id: String
    }

    public struct Failure: Error, Decodable {
        let message: String
        // TODO: Add other properties
    }
}
