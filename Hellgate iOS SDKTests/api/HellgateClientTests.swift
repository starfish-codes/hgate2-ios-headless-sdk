import XCTest
@testable import Hellgate_iOS_SDK

final class HellgateClientTests: XCTestCase {

    func test_Given_HellgateClient_When_FetchSessionStatus_Then_UseCorrectURL() async throws {
        let mockURLSession = MockURLSession()
        let baseURL = URL(string: "https://api-reference.hellgate.io")!
        let client = HttpClient(session: mockURLSession)
        let hellgateClient = HellgateClient(baseURL: baseURL, client: client)

        mockURLSession.data = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://api-reference.hellgate.io/sessions/1234")
        }

        _ = await hellgateClient.sessionStatus(sessionId: "1234")
    }

    func test_Given_HellgateClient_When_CompleteToken_Then_UseCorrectURL() async throws {
        let mockURLSession = MockURLSession()
        let baseURL = URL(string: "https://api-reference.hellgate.io")!
        let client = HttpClient(session: mockURLSession)
        let hellgateClient = HellgateClient(baseURL: baseURL, client: client)

        mockURLSession.data = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://api-reference.hellgate.io/sessions/1234/complete-action")
        }

        _ = await hellgateClient.completeTokenizeCard(sessionId: "1234", tokenId: "1234", additionalData: [:])
    }
}

class MockURLSession: URLDataTask {
    var data: ((URLRequest) -> Void)?
    var dataReturn: (Data, URLResponse)?

    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        self.data?(request)

        return dataReturn ?? (Data(), URLResponse())
    }
}
