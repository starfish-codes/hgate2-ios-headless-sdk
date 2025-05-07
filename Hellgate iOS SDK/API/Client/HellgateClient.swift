import Foundation

protocol HellgateClientAPI {
    func sessionStatus(
        sessionId: String
    ) async -> Result<SessionResponse, Error>

    func completeTokenizeCard(
        sessionId: String,
        tokenId: String,
        additionalData: [AdditionalFieldType: String]
    ) async -> Result<SessionResponse, Error>

    func completeTokenizeCard(
        sessionId: String,
        encryptedCardData: String
    ) async -> Result<SessionResponse, Error>
}

class HellgateClient: HellgateClientAPI {
    private let baseURL: URL
    private let client: HttpClientSession

    init(baseURL: URL, client: HttpClientSession) {
        self.baseURL = baseURL
        self.client = client
    }

    func sessionStatus(sessionId: String) async -> Result<SessionResponse, Error> {
        var url = self.baseURL
        url.appendPathComponent("sessions")
        url.appendPathComponent(sessionId)

        return await self.client.request(method: "GET", url: url, headers: [:])
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
                additionalData: additionalData.isEmpty ? nil: .init(
                    cardholderName: additionalData[.CARDHOLDER_NAME]
                )
            )
        )
        return await self.client.request(method: "POST", url: url, body: body, headers: [:])
    }

    func completeTokenizeCard(
        sessionId: String,
        encryptedCardData: String
    ) async -> Result<SessionResponse, Error> {
        var url = self.baseURL
        url.appendPathComponent("sessions")
        url.appendPathComponent(sessionId)
        url.appendPathComponent("complete-action")

        let body = SessionCompleteTokenizeCardEncrypted(
            result: SessionCompleteTokenizeCardEncrypted.Result(encryptedPayload: encryptedCardData)
        )
        return await self.client.request(method: "POST", url: url, body: body, headers: [:])
    }
}
