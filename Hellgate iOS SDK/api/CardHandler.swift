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
        let year = String(expiryView.value.suffix(2))
        let month = String(expiryView.value.prefix(2))

        // TODO: Extract out validation from fields and apply here

        return .success(
            CardData(
                cardNumber: cardNumber,
                year: year,
                month: month,
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
