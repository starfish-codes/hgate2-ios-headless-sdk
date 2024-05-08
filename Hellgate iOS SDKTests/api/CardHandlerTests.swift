import XCTest
@testable import Hellgate_iOS_SDK

final class CardHandlerTests: XCTestCase {
    func test_Given_ValidCardDetails_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: ""),
            .init(state: .complete, value: ""),
            .init(state: .complete, value: ""),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .success(let success) = result {
            XCTAssertEqual(success.id, "1")
        }
    }
}
