import XCTest
@testable import Hellgate_iOS_SDK

final class ExTokenizeClientTests: XCTestCase {

    func test_Given_IncorrectCardData_When_Tokenize_Then_Fail() async {
        let mockClient = MockClient()
        let baseURL = URL(string: "http://")!
        let tokenizeClient = ExTokenizeClient(baseURL: baseURL, client: mockClient)

        let response = await tokenizeClient.tokenizeCard(
            apiKey: "",
            cardData: CardData(
                cardNumber: "1234 1234 11234 12341 23123",
                year: "asdf",
                month: "asdf",
                cvc: "1234"
            )
        )

        switch response {
        case .success(_):
            XCTFail()
        case .failure(let failure):
            XCTAssert(failure is ExTokenizeClient.ExTokenizeError)
        }
    }

    func test_Given_CardData_When_Tokenize_Then_ReturnToken() async {
        let mockClient = MockClient()
        let baseURL = URL(string: "http://test.com")!
        let tokenizeClient = ExTokenizeClient(baseURL: baseURL, client: mockClient)

        mockClient.request["http://test.com/tokenize"] = """
        {
            "id": "1"
        }
        """

        let response = await tokenizeClient.tokenizeCard(
            apiKey: "",
            cardData: CardData(
                cardNumber: "123456789",
                year: "12",
                month: "12",
                cvc: "123"
            )
        )

        switch response {
        case .success(let response):
            XCTAssertEqual(response.id, "1")
        case .failure(_):
            XCTFail()
        }
    }
}
