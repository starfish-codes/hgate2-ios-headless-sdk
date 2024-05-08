enum CardDataValidationError: Error {
    case invalidCardNumber
    case invalidCvcNumber
    case invalidExpiryDate

    var localizedDescription: String {
        switch self {

        case .invalidCardNumber:
            return "Invalid Card Number"
        case .invalidCvcNumber:
            return "Invalid CVC Number"
        case .invalidExpiryDate:
            return "Invalid Expiry Date"
        }
    }
}

public protocol CardHandler {
    func tokenizeCard(
        _ cardNumberView: ViewState,
        _ cvcView: ViewState,
        _ expiryView: ViewState,
        _ additional: [AdditionalFieldType: ViewState]
    ) async -> Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure>
}

class CardHandle: CardHandler {
    let tokenService: TokenServiceProvider
    let sessionId: String

    init(tokenService: TokenServiceProvider, sessionId: String) {
        self.tokenService = tokenService
        self.sessionId = sessionId
    }

    private func validateInput(
        _ cardNumberView: ViewState,
        _ cvcView: ViewState,
        _ expiryView: ViewState
    ) -> Result<CardData, CardDataValidationError> {

        let cardNumber = cardNumberView.value
        let cvc = cvcView.value
        let yearString = String(expiryView.value.suffix(2))
        let monthString = String(expiryView.value.prefix(2))

        let brand = CardBrand.first(from: cardNumber).details

        guard !cardNumber.isEmpty, brand.isValidLength(cardNumber: cardNumber) else {
            return .failure(.invalidCardNumber)
        }

        guard !cvc.isEmpty, brand.isValidLength(cvc: cvc) else {
            return .failure(.invalidCvcNumber)
        }

        guard !monthString.isEmpty, let month = Int(monthString), (1...12).contains(month) else {
            return .failure(.invalidExpiryDate)
        }

        let thisYear = Calendar.current.component(.year, from: .now) % 100
        guard !yearString.isEmpty, let year = Int(yearString), (thisYear...99).contains(year) else {
            return .failure(.invalidExpiryDate)
        }

        return .success(
            CardData(
                cardNumber: cardNumber,
                year: yearString,
                month: monthString,
                cvc: cvc
            )
        )
    }

    func tokenizeCard(
        _ cardNumberView: ViewState,
        _ cvcView: ViewState,
        _ expiryView: ViewState,
        _ additional: [AdditionalFieldType: ViewState]
    ) async -> Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure> {

        let validation = validateInput(cardNumberView, cvcView, expiryView)

        switch validation {

        case .success(let cardData):
            return await tokenService.tokenize(
                sessionId: sessionId,
                cardData: cardData,
                additionalData: additional.mapValues { $0.value }
            )
        case .failure(let error):
            return .failure(
                TokenizeCardResponse.Failure(message: error.localizedDescription)
            )
        }
    }
}
