import XCTest
@testable import Hellgate_iOS_SDK

final class CardUtilsTests: XCTestCase {
    func test_Given_ValidNumber_When_LUHNValidated_Then_Valid() throws {
        let cardNumber = "1234567890123452"
        XCTAssertTrue(isValidLUHN(cardNumber))
    }

    func test_Given_InvalidNumber_When_LUHNValidated_Then_Invalid() throws {
        let cardNumber = "1234567890123456"
        XCTAssertFalse(isValidLUHN(cardNumber))
    }

    func test_Given_InvalidNumberWithDigits_When_LUHNValidated_Then_Invalid() throws {
        let cardNumber = "12345b789012345a"
        XCTAssertFalse(isValidLUHN(cardNumber))
    }
}
