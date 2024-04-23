import Foundation

public struct CardBrand {
    let code: String
    let displayName: String
    let icon: String
    let errorIcon: String
    let cvcLength: Set<Int>
    let defaultMaxLength: Int
    let pattern: String?
    let partialPatterns: [Int: String]
    let variantMaxLength: [String: Int]
    let shouldRender: Bool
    let renderingOrder: Int
    
    public init(
        code: String,
        displayName: String,
        icon: String,
        errorIcon: String = "credit-card",
        cvcLength: Set<Int> = [3],
        defaultMaxLength: Int = 16,
        pattern: String? = nil,
        partialPatterns: [Int : String],
        variantMaxLength: [String : Int] = [:],
        shouldRender: Bool = true,
        renderingOrder: Int
    ) {
        self.code = code
        self.displayName = displayName
        self.icon = icon
        self.errorIcon = errorIcon
        self.cvcLength = cvcLength
        self.defaultMaxLength = defaultMaxLength
        self.pattern = pattern
        self.partialPatterns = partialPatterns
        self.variantMaxLength = variantMaxLength
        self.shouldRender = shouldRender
        self.renderingOrder = renderingOrder
    }
}

extension CardBrand {
    static let COMMON_CVC_LENGTH = 3
    
    var maxCVCLength: Int {
        self.cvcLength.max() ?? CardBrand.COMMON_CVC_LENGTH
    }
    
    func isValidLength(cardNumber: String) -> Bool {
        cardNumber.count == maxLength(for: cardNumber)
    }
    
    func maxLength(for cardNumber: String) -> Int {
        variableMaxLength(for: cardNumber) ?? defaultMaxLength
    }
    
    private func variableMaxLength(for cardNumber: String) -> Int? {
        variantMaxLength.map { key, value in
            guard let regex = try? NSRegularExpression(pattern: key),
                  let range = NSRange(cardNumber) else {
                return 0
            }
            
            if regex.firstMatch(in: cardNumber, range: range) != nil {
                return value
            } else {
                return 0
            }
        }.max()
    }
    
    func isValidLength(cvc: String) -> Bool {
        cvcLength.contains(cvc.count)
    }
    
    func isMaxLength(cvc: String) -> Bool {
        cvc.count == maxCVCLength
    }
    
    func patternBy(length: Int) -> String? {
        return partialPatterns[length] ?? pattern
    }
}

public enum CardBrands: CaseIterable {
    case visa
    case masterCard
    case americanExpress
    case discover
    case jcb
    case dinersClub
    case unionPay
    case cartesBancaires
    case unknown
}

extension CardBrands {
    static func first(from cardNumber: String) -> CardBrands {
        guard cardNumber.isEmpty == false else { return CardBrands.unknown }
        
        let range = NSRange(location: 0, length: cardNumber.lengthOfBytes(using: .utf8))
        
        let validCardBrands = CardBrands.allCases
            .filter { card in
                let details = card.details
                
                guard let pattern = details.patternBy(length: cardNumber.count) ?? details.pattern else {
                    return false
                }
                
                print("\(card) - Pattern: \(pattern)")
                
                do {
                    let regex = try NSRegularExpression(pattern: pattern)
                    return regex.firstMatch(in: cardNumber, range: range) != nil
                } catch {
                    print("Regex error: \(error)")
                }

                return false
            }
            .filter { $0.details.shouldRender }
        
        return validCardBrands.first ?? .unknown
    }
}
extension CardBrands {
    
    var details: CardBrand {
        switch self {
        case .visa:
            CardBrand(
                code: "visa",
                displayName: "Visa",
                icon: "visa",
                pattern: "^(4)[0-9]*$",
                partialPatterns: [1: "^4$"],
                renderingOrder: 1
            )
        case .masterCard:
            CardBrand(
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
            CardBrand(
                code: "amex",
                displayName: "Amercan Express",
                icon: "american-express",
                cvcLength: [3, 4],
                pattern: "^(34|37)[0-9]*$",
                partialPatterns: [1: "^3$"],
                renderingOrder: 3
            )
        case .discover:
            CardBrand(
                code: "discover",
                displayName: "Discover",
                icon: "discover",
                pattern: "^(60|64|65)[0-9]*$",
                partialPatterns: [1: "^6$"],
                renderingOrder: 4
            )
        case .jcb:
            CardBrand(
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
            CardBrand(
                code: "diner",
                displayName: "Diners Club",
                icon: "diners-club",
                pattern: "^(36|30|38|39)[0-9]*$",
                partialPatterns: [1: "^3$"],
                variantMaxLength: ["^(36)[0-9]*$": 14],
                renderingOrder: 6
            )
        case .unionPay:
            CardBrand(
                code: "unionpay",
                displayName: "UnionPay",
                icon: "unionpay",
                pattern: "^(62|81)[0-9]*$",
                partialPatterns: [1: "^6|8$"],
                renderingOrder: 7
            )
        case .cartesBancaires:
            CardBrand(
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
            CardBrand(
                code: "unknown",
                displayName: "unknown",
                icon: "credit-card",
                cvcLength: [3, 4],
                defaultMaxLength: -1,
                pattern: "",
                partialPatterns: [:],
                renderingOrder: -1
            )
        }
    }
}
