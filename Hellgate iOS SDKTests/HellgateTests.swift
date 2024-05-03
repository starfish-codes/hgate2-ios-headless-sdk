import XCTest
@testable import Hellgate_iOS_SDK

final class HellgateTests: XCTestCase {

    enum FakeError: Error {
        case error
    }

    func test_Given_NoHellgate_When_InitHellgate_Then_GetInternalHellgateBack() async throws {
        let hellgate = await initHellgate(
            baseUrl: URL(string:"https://api-reference.hellgate.io")!,
            sessionId: ""
        )

        XCTAssert(hellgate is InternalHellgate)
    }


    func test_Given_InitHellgate_When_FetchSessionStatus_Then_ReturnRequireTokenization() async throws {

        let mock = MockHellgateClient {
            .success(.init(data: [:], nextAction: .tokenize_card, status: nil))
        } competeTokenizeCard: {
            .failure(FakeError.error)
        }

        let baseURL = URL(string:"https://api-reference.hellgate.io")!
        let sessionId = ""
        let hellgate = InternalHellgate(baseUrl: baseURL, sessionId: sessionId, client: HttpClient(), hellgateClient: mock)

        let status = await hellgate.fetchSessionStatus()
        XCTAssertEqual(status, .REQUIRE_TOKENIZATION)
    }

    func test_Given_InitHellgate_When_FetchSessionStatus_Then_ReturnWAITING() async throws {

        let mock = MockHellgateClient {
            .success(.init(data: [:], nextAction: .wait, status: nil))
        } competeTokenizeCard: {
            .failure(FakeError.error)
        }

        let baseURL = URL(string:"https://api-reference.hellgate.io")!
        let sessionId = ""
        let hellgate = InternalHellgate(baseUrl: baseURL, sessionId: sessionId, client: HttpClient(), hellgateClient: mock)
        let status = await hellgate.fetchSessionStatus()
        XCTAssertEqual(status, .WAITING)
    }

    func test_Given_InitHellgate_When_FetchSessionStatus_Then_ReturnCompleted() async throws {
        
        let mock = MockHellgateClient {
            .success(.init(data: [:], nextAction: nil, status: "success"))
        } competeTokenizeCard: {
            .failure(FakeError.error)
        }

        let baseURL = URL(string:"https://api-reference.hellgate.io")!
        let sessionId = ""
        let hellgate = InternalHellgate(baseUrl: baseURL, sessionId: sessionId, client: HttpClient(), hellgateClient: mock)

        let status = await hellgate.fetchSessionStatus()
        XCTAssertEqual(status, .COMPLETED)
    }

    func test_Given_InitHellgate_When_FetchSessionStatus_Then_ReturnUnknown() async throws {

        let mock = MockHellgateClient {
            .success(.init(data: [:], nextAction: nil, status: nil))
        } competeTokenizeCard: {
            .failure(FakeError.error)
        }

        let baseURL = URL(string:"https://api-reference.hellgate.io")!
        let sessionId = ""
        let hellgate = InternalHellgate(baseUrl: baseURL, sessionId: sessionId, client: HttpClient(), hellgateClient: mock)

        let status = await hellgate.fetchSessionStatus()
        XCTAssertEqual(status, .UNKNOWN)
    }

    func test_Given_InitHellgate_When_FetchSessionStatusFailed_Then_ReturnUnknown() async throws {
        
        let mock = MockHellgateClient {
            .failure(FakeError.error)
        } competeTokenizeCard: {
            .failure(FakeError.error)
        }

        let baseURL = URL(string:"https://api-reference.hellgate.io")!
        let sessionId = ""
        let hellgate = InternalHellgate(baseUrl: baseURL, sessionId: sessionId, client: HttpClient(), hellgateClient: mock)

        let status = await hellgate.fetchSessionStatus()
        XCTAssertEqual(status, .UNKNOWN)
    }
}

class MockHellgateClient: HellgateClientAPI {
    var sessionStatus: () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>
    var completeTokenizeCard: () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>

    init(sessionStatus: @escaping () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>, competeTokenizeCard: @escaping () -> Result<Hellgate_iOS_SDK.SessionResponse, Error>) {
        self.sessionStatus = sessionStatus
        self.completeTokenizeCard = competeTokenizeCard
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
}
