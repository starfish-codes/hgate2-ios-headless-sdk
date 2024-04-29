import XCTest
@testable import Hellgate_iOS_SDK

final class ExpiryDateFormatterTests: XCTestCase {

    let data: [(String,String?)] = [
        ("", ""),
        ("2", "02"),
        ("1", "1"),
        ("01", "01"),
        ("0", "0"),
        ("101", "10 / 1"),
        ("1012", "10 / 12"),
        ("10121", nil),
    ]

    func test_Given_Data_When_Formatted_Then_IsFormatted() {
        let formatter = ExpiryDateFormatter()

        for (input, result) in data {
            XCTAssertEqual(formatter.string(for: input), result)
        }
    }
}
