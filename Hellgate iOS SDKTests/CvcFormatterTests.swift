import XCTest
@testable import Hellgate_iOS_SDK

final class CvcFormatterTests: XCTestCase {

    let data: [(String,String?)] = [
        ("", ""),
        ("1", "1"),
        ("01", "01"),
        ("0", "0"),
        ("101", "101"),
        ("1012", nil),
        ("10121", nil),
    ]

    func test_Given_IncorrectObjectType_When_Formatted_Then_IsFormatted() {
        let formatter = CvcFormatter(maxLength: 3)

        XCTAssertNil(formatter.string(for: 1))
    }

    func test_Given_Data_When_Formatted_Then_IsFormatted() {
        let formatter = CvcFormatter(maxLength: 3)

        for (input, result) in data {
            XCTAssertEqual(formatter.string(for: input), result)
        }
    }

    func test_Given_MaxLengthFour_When_Formatted_Then_IsFormatted() {
        let formatter = CvcFormatter(maxLength: 4)
        XCTAssertEqual(formatter.string(for: "1234"), "1234")
        XCTAssertEqual(formatter.string(for: "12345"), nil)
    }

    func test_Given_FormattedText_When_Reverse_Then_IsFormatted() {
        let formatter = CvcFormatter(maxLength: 4)

        var result = String()
        withUnsafeMutablePointer(to: &result) { mut in
            let object = AutoreleasingUnsafeMutablePointer<AnyObject?>(mut)
            XCTAssert(formatter.getObjectValue(object, for: "1234", errorDescription: nil))
            XCTAssertFalse(formatter.getObjectValue(nil, for: "1234", errorDescription: nil))
        }
    }
}
