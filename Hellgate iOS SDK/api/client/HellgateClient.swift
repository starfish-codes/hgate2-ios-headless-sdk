protocol HellgateClientAPI {
    func sessionStatus(
        sessionId: String
    ) async -> Result<SessionResponse, Error>

    func completeTokenizeCard(
        sessionId: String,
        tokenId: String,
        additionalData: [AdditionalFieldType: String]
    ) async -> Result<SessionResponse, Error>
}

class HellgateClient: HellgateClientAPI {
    private let baseURL: URL
    private let client: HttpClient

    init(baseURL: URL, client: HttpClient) {
        self.baseURL = baseURL
        self.client = client
    }

    func sessionStatus(sessionId: String) async -> Result<SessionResponse, Error> {
        var url = self.baseURL
        url.appendPathComponent("sessions")
        url.appendPathComponent(sessionId)

        return await self.client.request(method: "GET", url: url)
    }

    func completeTokenizeCard(
        sessionId: String,
        tokenId: String,
        additionalData: [AdditionalFieldType: String]
    ) async -> Result<SessionResponse, Error> {
        var url = self.baseURL
        url.appendPathComponent("sessions")
        url.appendPathComponent(sessionId)
        url.appendPathComponent("complete-action")

        let body = SessionCompleteTokenizeCard(
            result: SessionCompleteTokenizeCard.Result(
                tokenId: tokenId,
                additionalData: .init(
                    cardholderName: additionalData[.CARDHOLDER_NAME]
                )
            )
        )
        return await self.client.request(method: "POST", url: url, body: body)
    }
}
