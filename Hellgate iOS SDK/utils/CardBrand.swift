import Foundation

public struct BrandDetails {
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
        partialPatterns: [Int: String],
        variantMaxLength: [String: Int] = [:],
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

extension BrandDetails {
    static let COMMON_CVC_LENGTH = 3

    var maxCVCLength: Int {
        self.cvcLength.max() ?? BrandDetails.COMMON_CVC_LENGTH
    }

    func isValidLength(cardNumber: String) -> Bool {
        cardNumber.count == maxLength(for: cardNumber)
    }

    func maxLength(for cardNumber: String) -> Int {
        variableMaxLength(for: cardNumber) ?? defaultMaxLength
    }

    private func variableMaxLength(for cardNumber: String) -> Int? {
        variantMaxLength.map { key, value in
            let range = NSRange(location: 0, length: cardNumber.lengthOfBytes(using: .utf8))
            guard let regex = try? NSRegularExpression(pattern: key) else {
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

public enum CardBrand: CaseIterable {
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

extension CardBrand {
    static func first(from cardNumber: String) -> CardBrand {
        guard cardNumber.isEmpty == false else { return CardBrand.unknown }

        let range = NSRange(location: 0, length: cardNumber.lengthOfBytes(using: .utf8))

        let validCardBrands = CardBrand.allCases
            .map { (card: $0, details: $0.details)}
            .filter { (card, details) in
                guard let pattern = details.patternBy(length: cardNumber.count) ?? details.pattern else {
                    return false
                }

                #if DEBUG
                print("\(card) - Pattern: \(pattern)")
                #endif

                do {
                    let regex = try NSRegularExpression(pattern: pattern)
                    if let match = regex.firstMatch(in: cardNumber, range: range) {
                        #if DEBUG
                        print("Match: \(match)")
                        #endif
                        return true
                    }
                } catch {
                    print("Failed to create regular expression: \(error)")
                }

                return false
            }
            .filter { $0.details.shouldRender }
            .map { $0.card }

        #if DEBUG
        print("Possible valid card types: \(validCardBrands)")
        #endif

        return validCardBrands.first ?? .unknown
    }
}
