import XCTest
@testable import Hellgate_iOS_SDK

final class CardHandlerTests: XCTestCase {
    func test_Given_ValidCardDetails_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: "42424242424242424242"),
            .init(state: .complete, value: "123"),
            .init(state: .complete, value: "12/30"),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .success(let success) = result {
            XCTAssertEqual(success.id, "1")
        }
    }

    func test_Given_EmptyCardNumber_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: ""),
            .init(state: .complete, value: "123"),
            .init(state: .complete, value: "12/30"),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, CardDataValidationError.invalidCardNumber.localizedDescription)
        }
    }

    func test_Given_InvalidCardNumber_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: "42424242"),
            .init(state: .complete, value: "123"),
            .init(state: .complete, value: "12/30"),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, CardDataValidationError.invalidCardNumber.localizedDescription)
        }
    }

    func test_Given_EmptyCVC_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: "4242424242424242"),
            .init(state: .complete, value: ""),
            .init(state: .complete, value: "12/30"),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, CardDataValidationError.invalidCvcNumber.localizedDescription)
        }
    }

    func test_Given_InvalidCVC_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: "4242424242424242"),
            .init(state: .complete, value: "123456789"),
            .init(state: .complete, value: "12/30"),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, CardDataValidationError.invalidCvcNumber.localizedDescription)
        }
    }

    func test_Given_EmptyExpiry_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: "4242424242424242"),
            .init(state: .complete, value: "123"),
            .init(state: .complete, value: ""),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, CardDataValidationError.invalidExpiryDate.localizedDescription)
        }
    }

    func test_Given_InvalidYearExpiry_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: "4242424242424242"),
            .init(state: .complete, value: "123"),
            .init(state: .complete, value: "12/20"),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, CardDataValidationError.invalidExpiryDate.localizedDescription)
        }
    }

    func test_Given_InvalidMonthExpiry_When_Tokenize_Then_ReturnSuccess() async {

        let mockTokenService = MockTokenService()
        let cardHandler = CardHandle(tokenService: mockTokenService, sessionId: "")

        mockTokenService.result = .success(.init(id: "1"))

        let result = await cardHandler.tokenizeCard(
            .init(state: .complete, value: "4242424242424242"),
            .init(state: .complete, value: "123"),
            .init(state: .complete, value: "14/30"),
            [.CARDHOLDER_NAME: .init(state: .complete, value: "Bob")]
        )

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, CardDataValidationError.invalidExpiryDate.localizedDescription)
        }
    }
}
