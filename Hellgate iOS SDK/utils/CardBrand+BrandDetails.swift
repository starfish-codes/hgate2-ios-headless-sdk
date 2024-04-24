import Foundation

extension CardBrand {
    
    var details: BrandDetails {
        switch self {
        case .visa:
            BrandDetails(
                code: "visa",
                displayName: "Visa",
                icon: "visa",
                pattern: "^(4)[0-9]*$",
                partialPatterns: [1: "^4$"],
                renderingOrder: 1
            )
        case .masterCard:
            BrandDetails(
                code: "mastercard",
                displayName: "Mastercard",
                icon: "mastercard",
                pattern: "^(2221|2222|2223|2224|2225|2226|2227|2228|2229|222|223|224|225|226|227|228|229|23|24|25|26|270|271|2720|50|51|52|53|54|55|56|57|58|59|67)[0-9]*$",
                partialPatterns: [
                    1 : "^2|5|6$",
                    2 : "^(22|23|24|25|26|27|50|51|52|53|54|55|56|57|58|59|67)$"
                ],
                renderingOrder: 2
            )
        case .americanExpress:
            BrandDetails(
                code: "amex",
                displayName: "Amercan Express",
                icon: "american-express",
                cvcLength: [3, 4],
                pattern: "^(34|37)[0-9]*$",
                partialPatterns: [1: "^3$"],
                renderingOrder: 3
            )
        case .discover:
            BrandDetails(
                code: "discover",
                displayName: "Discover",
                icon: "discover",
                pattern: "^(60|64|65)[0-9]*$",
                partialPatterns: [1: "^6$"],
                renderingOrder: 4
            )
        case .jcb:
            BrandDetails(
                code: "jcb",
                displayName: "JCB",
                icon: "jcb",
                pattern: "^(352[89]|35[3-8][0-9])[0-9]*$",
                partialPatterns: [
                    1: "^3$",
                    2: "^(35)$",
                    3: "^(35[2-8])$"
                ],
                renderingOrder: 5
            )
        case .dinersClub:
            BrandDetails(
                code: "diner",
                displayName: "Diners Club",
                icon: "diners-club",
                pattern: "^(36|30|38|39)[0-9]*$",
                partialPatterns: [1: "^3$"],
                variantMaxLength: ["^(36)[0-9]*$": 14],
                renderingOrder: 6
            )
        case .unionPay:
            BrandDetails(
                code: "unionpay",
                displayName: "UnionPay",
                icon: "unionpay",
                pattern: "^(62|81)[0-9]*$",
                partialPatterns: [1: "^6|8$"],
                renderingOrder: 7
            )
        case .cartesBancaires:
            BrandDetails(
                code: "cartes_bancaires",
                displayName: "Cartes Bancaires",
                icon: "credit-card",
                pattern: "(^(4)[0-9]*) |" +
                "^(2221|2222|2223|2224|2225|2226|2227|2228|2229|222|223|224|225|226|" +
                "227|228|229|23|24|25|26|270|271|2720|50|51|52|53|54|55|56|57|58|59|67)[0-9]*$",
                partialPatterns: [
                    1: "^4$",
                    2: "^2|5|6$",
                    3: "^(22|23|24|25|26|27|50|51|52|53|54|55|56|57|58|59|67)$"
                ],
                shouldRender: false,
                renderingOrder: 8
            )
        case .unknown:
            BrandDetails(
                code: "unknown",
                displayName: "unknown",
                icon: "credit-card",
                cvcLength: [3, 4],
                defaultMaxLength: -1,
                pattern: nil,
                partialPatterns: [:],
                renderingOrder: -1
            )
        }
    }
}
