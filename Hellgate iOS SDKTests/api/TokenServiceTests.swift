import XCTest
@testable import Hellgate_iOS_SDK

final class TokenServiceTests: XCTestCase {

    struct FakeError: Error {}

    func test_Given_IncorrectSessionStatus_When_Tokenize_Then_Fail() async {
        _ = URL(string: "https://api-reference.hellgate.io")!
        let client = HttpClient()
        let hellgateClient = MockHellgateClient {
            .failure(FakeError())
        } competeTokenizeCard: {
            .failure(FakeError())
        }

        let tokenService = TokenService(hellgateClient: hellgateClient, client: client)

        let cardData = CardData(cardNumber: "", year: "", month: "", cvc: "")
        let result = await tokenService.tokenize(sessionId: "", cardData: cardData, additionalData: [:])

        switch result {
        case .success(_): XCTFail()
        case .failure(_):
            break
        }
    }
}
