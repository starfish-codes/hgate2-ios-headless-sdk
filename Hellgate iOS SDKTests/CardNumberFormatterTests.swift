import XCTest
@testable import Hellgate_iOS_SDK

final class CardNumberFormatterTests: XCTestCase {

    func test_Given_Valid16DigitNumber_When_Formatted_Then_IsFormatted() {
        let formatter = CardNumberFormatter()

        XCTAssertEqual(formatter.string(for: "1234123412341234"), "1234 1234 1234 1234")
    }

    func test_Given_Valid14And15DigitNumber_When_Formatted_Then_IsFormatted() {
        let formatter = CardNumberFormatter()

        XCTAssertEqual(formatter.string(for: "12341234123412"), "1234 123412 3412")
        XCTAssertEqual(formatter.string(for: "123412341234123"), "1234 123412 34123")
    }

    func test_Given_Valid5DigitNumber_When_Formatted_Then_IsFormatted() {
        let formatter = CardNumberFormatter()

        XCTAssertEqual(formatter.string(for: "12341"), "1234 1")
    }

    func test_Given_CardNumberWithCharacters_When_Formatted_Then_Nil() {
        let formatter = CardNumberFormatter()

        XCTAssertEqual(formatter.string(for: "123412341234123X"), nil)

    }

    func test_Given_FormattedCardNumber_When_ReturningOriginalString_Then_ReturnStringWithNoSpaces() {
        let formatter = CardNumberFormatter()

        var result: String? = String()
        result = withUnsafeMutablePointer(to: &result) { mut in
            let object = AutoreleasingUnsafeMutablePointer<AnyObject?>(mut)
            _ = formatter.getObjectValue(object, for: "1234 1234 1234 1234", errorDescription: nil)
            return object.pointee as? String
        }

        XCTAssertEqual(result, "1234123412341234")
    }
}
