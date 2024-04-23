import XCTest
@testable import Hellgate_iOS_SDK

final class CardBrandTests: XCTestCase {

    func test_Given_VisaNumber_When_PatternMatching_Then_MatchWithVisa() {
        let visaNumber = "4123412341234123"
        XCTAssertEqual(CardBrand.first(from: visaNumber), .visa)
    }

    func test_Given_FirstVisaNumber_When_PatternMatching_Then_MatchWithVisa() {
        let visaNumber = "4"
        XCTAssertEqual(CardBrand.first(from: visaNumber), .visa)
    }

    func test_Given_InvalidVisaNumber_When_PatternMatching_Then_MatchWithUnknown() {
        let visaNumber = "412341234123412a"
        XCTAssertEqual(CardBrand.first(from: visaNumber), .unknown)
    }

    func test_Given_DefaultBrandDetails_When_GetMaxCvcLength_Then_ReturnLength() {
        let details = BrandDetails.stub(cvcLength: [100])
        XCTAssertEqual(details.maxCVCLength, 100 )
    }

    func test_Given_EmptyCvcLength_When_GetMaxCvcLength_Then_ReturnLength() {
        let details = BrandDetails.stub(cvcLength: [])
        XCTAssertEqual(details.maxCVCLength, BrandDetails.COMMON_CVC_LENGTH)
    }

    func test_Given_EmptyVariantMax_When_GetMaxLength_Then_Return_DefaultMaxLength() {
        let details = BrandDetails.stub(defaultMaxLength: 100, variantMaxLength: [:])
        XCTAssertEqual(details.defaultMaxLength, 100)
        XCTAssertEqual(details.maxLength(for: ""), 100)
    }

    func test_Given_VariantMaxLengthSet_When_GetMaxLength_Then_Return_VariantMaxLength() {
        let details = BrandDetails.stub(
            defaultMaxLength: 100,
            variantMaxLength: ["^(4)[0-9]*$": 14]
        )
        XCTAssertEqual(details.defaultMaxLength, 100)
        XCTAssertEqual(details.maxLength(for: "4123412341234"), 14)
    }

    func test_Given_VariantMaxLengthSetAndNonMatchingCardNumber_When_GetMaxLength_Then_Return_DefaultMaxLength() {
        let details = BrandDetails.stub(
            defaultMaxLength: 100,
            variantMaxLength: ["^(4)[0-9]*$": 14]
        )
        XCTAssertEqual(details.defaultMaxLength, 100)
        XCTAssertEqual(details.maxLength(for: "123412341234"), 100)
    }

    func test_Given_InvalidVariantMaxLengthSetAndNonMatchingCardNumber_When_GetMaxLength_Then_Return_DefaultMaxLength() {
        let details = BrandDetails.stub(
            defaultMaxLength: 100,
            variantMaxLength: ["](4*)[0-9": 14]
        )
        XCTAssertEqual(details.defaultMaxLength, 100)
        XCTAssertEqual(details.maxLength(for: "123412341234"), 100)
    }
}

extension BrandDetails {
    static func stub(
        code: String = "",
        displayName: String = "",
        icon: String = "",
        errorIcon: String = "",
        cvcLength: Set<Int> = [],
        defaultMaxLength: Int = 16,
        pattern: String? = nil,
        partialPatterns: [Int: String] = [:],
        variantMaxLength: [String: Int] = [:],
        shouldRender: Bool = true,
        renderingOrder: Int = 0
    ) -> Self {
        BrandDetails(
            code: code,
            displayName: displayName,
            icon: icon,
            errorIcon: errorIcon,
            cvcLength: cvcLength,
            defaultMaxLength: defaultMaxLength,
            pattern: pattern,
            partialPatterns: partialPatterns,
            variantMaxLength: variantMaxLength,
            shouldRender: shouldRender,
            renderingOrder: renderingOrder
        )
    }
}
