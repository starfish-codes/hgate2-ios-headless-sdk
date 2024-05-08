@testable import Hellgate_iOS_SDK

class MockTokenService: TokenServiceProvider {
    var result: Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure> = .failure(.init(message: "Mock not set"))

    func tokenize(
        sessionId: String,
        cardData: CardData,
        additionalData: [AdditionalFieldType : String]
    ) async -> Result<TokenizeCardResponse.Success, TokenizeCardResponse.Failure> {
        return result
    }
}
