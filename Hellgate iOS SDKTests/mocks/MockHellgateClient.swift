@testable import Hellgate_iOS_SDK

class MockHellgateClient: HellgateClientAPI {
    var sessionStatus: () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>
    var completeTokenizeCard: () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>
    var completeTokenizeCardEncrypted: () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>

    init(
        sessionStatus: @escaping () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>,
        competeTokenizeCard: @escaping () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>,
        completeTokenizeCardEncrypted: @escaping () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>
    ) {
        self.sessionStatus = sessionStatus
        self.completeTokenizeCard = competeTokenizeCard
        self.completeTokenizeCardEncrypted = completeTokenizeCardEncrypted
    }

    func sessionStatus(sessionId: String) async -> Result<Hellgate_iOS_SDK.SessionResponse, Error> {
        return sessionStatus()
    }

    func completeTokenizeCard(
        sessionId: String,
        tokenId: String,
        additionalData: [Hellgate_iOS_SDK.AdditionalFieldType : String]
    ) async -> Result<Hellgate_iOS_SDK.SessionResponse, Error> {
        return completeTokenizeCard()
    }

    func completeTokenizeCard(
        sessionId: String,
        encryptedCardData: String
    ) async -> Result<SessionResponse, Error> {
        return completeTokenizeCardEncrypted()
    }
}
