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
            .success(.init(data: nil, nextAction: .tokenize_card, status: nil))
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
            .success(.init(data: nil, nextAction: .wait, status: nil))
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
            .success(.init(data: nil, nextAction: nil, status: "success"))
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
            .success(.init(data: nil, nextAction: nil, status: nil))
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

    func test_Given_RequireTokenization_When_GetCardHandler_Then_ReturnCardHandler() async {

        let mock = MockHellgateClient {
            .success(.init(data: nil, nextAction: .tokenize_card, status: nil))
        } competeTokenizeCard: {
            .failure(FakeError.error)
        }

        let baseURL = URL(string:"https://api-reference.hellgate.io")!
        let sessionId = ""
        let hellgate = InternalHellgate(baseUrl: baseURL, sessionId: sessionId, client: HttpClient(), hellgateClient: mock)

        let result = await hellgate.cardHandler()

        if case .failure(_) = result {
            XCTFail()
        }
    }

    func test_Given_NotRequireTokenization_When_GetCardHandler_Then_ReturnFailure() async {

        let mock = MockHellgateClient {
            .success(.init(data: nil, nextAction: nil, status: "UNKNOWN"))
        } competeTokenizeCard: {
            .failure(FakeError.error)
        }

        let baseURL = URL(string:"https://api-reference.hellgate.io")!
        let sessionId = ""
        let hellgate = InternalHellgate(baseUrl: baseURL, sessionId: sessionId, client: HttpClient(), hellgateClient: mock)

        let result = await hellgate.cardHandler()

        switch result {
        case .success(_):
            XCTFail()
        case .failure(let failure):
            XCTAssertEqual(failure.localizedDescription, "Session is not in correct state to tokenize card, actual state: UNKNOWN")
        }
    }
}
