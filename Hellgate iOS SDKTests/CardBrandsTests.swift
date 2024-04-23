import XCTest
@testable import Hellgate_iOS_SDK

final class CardBrandsTests: XCTestCase {

    func test_Given_VisaNumber_When_PatternMatching_Then_MatchWithVisa() {
        let visaNumber = "4123412341234123"
        XCTAssertEqual(CardBrands.first(from: visaNumber), .visa)
    }

    func test_Given_FirstVisaNumber_When_PatternMatching_Then_MatchWithVisa() {
        let visaNumber = "4"
        XCTAssertEqual(CardBrands.first(from: visaNumber), .visa)
    }
    
    func test_Given_InvalidVisaNumber_When_PatternMatching_Then_MatchWithUnknown() {
        let visaNumber = "412341234123412a"
        XCTAssertEqual(CardBrands.first(from: visaNumber), .unknown)
    }
}
