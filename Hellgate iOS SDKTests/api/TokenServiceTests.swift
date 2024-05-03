import XCTest
@testable import Hellgate_iOS_SDK

final class TokenServiceTests: XCTestCase {

    func test_Given_() async {
        let baseURL = URL(string: "https://api-reference.hellgate.io")!
        let client = HttpClient()
        let hellgateClient = HellgateClient(baseURL: baseURL, client: client)
        let tokenService = TokenService(hellgateClient: hellgateClient, client: client)

        let cardData = CardData(cardNumber: "", year: "", month: "", cvc: "")
        _ = await tokenService.tokenize(sessionId: "", cardData: cardData, additionalData: [:])
    }
}
