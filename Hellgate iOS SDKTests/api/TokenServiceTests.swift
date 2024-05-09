import XCTest
@testable import Hellgate_iOS_SDK

final class TokenServiceTests: XCTestCase {

    struct FakeError: Error {}

    func test_Given_SessionStatusFailure_When_Tokenize_Then_Fail() async {
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

    func test_Given_IncorrectSessionStatus_When_Tokenize_Then_Fail() async {
        _ = URL(string: "https://api-reference.hellgate.io")!
        let client = HttpClient()
        let hellgateClient = MockHellgateClient {
            .success(.init(data: nil, nextAction: nil, status: nil))
        } competeTokenizeCard: {
            .failure(FakeError())
        }

        let tokenService = TokenService(hellgateClient: hellgateClient, client: client)

        let cardData = CardData(cardNumber: "", year: "", month: "", cvc: "")
        let result = await tokenService.tokenize(sessionId: "", cardData: cardData, additionalData: [:])

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, "Tokenization failed")
        } else {
            XCTFail()
        }
    }

    func test_Given_CardDetailsValidProviderExternal_When_Tokenize_Then_ReturnToken() async {
        let client = MockClient()
        client.request["https://api-reference.hellgate.io/tokenize"] = """
        {
            "id": "1"
        }
        """

        let hellgateClient = MockHellgateClient {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: nil,
                        apiKey: "key",
                        provider: .external,
                        baseUrl: "https://api-reference.hellgate.io"
                    ),
                    nextAction: .tokenize_card,
                    status: nil
                )
            )
        } competeTokenizeCard: {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: "1",
                        apiKey: nil,
                        provider: nil,
                        baseUrl: nil
                    ),
                    nextAction: nil,
                    status: "complete"
                )
            )
        }

        let tokenService = TokenService(
            hellgateClient: hellgateClient,
            client: client
        )

        let cardData = CardData(cardNumber: "1234123412341234", year: "12", month: "12", cvc: "123")
        let result = await tokenService.tokenize(sessionId: "", cardData: cardData, additionalData: [:])

        if case .success(let success) = result {
            XCTAssertEqual(success.id, "1")
        } else {
            XCTFail()
        }
    }

    func test_Given_CardDetailsValidProviderGuardian_When_Tokenize_Then_ReturnToken() async {
        let client = MockClient()
        client.request["https://api-reference.hellgate.io/tokenize"] = """
        {
            "id": "1"
        }
        """

        let hellgateClient = MockHellgateClient {
            .success(
                .init(
                    data:  SessionResponse.TokenData(
                        tokenId: nil,
                        apiKey: "key",
                        provider: .guardian,
                        baseUrl: "https://api-reference.hellgate.io"
                    ),
                    nextAction: .tokenize_card,
                    status: nil
                )
            )
        } competeTokenizeCard: {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: "1",
                        apiKey: nil,
                        provider: nil,
                        baseUrl: nil
                    ),
                    nextAction: nil,
                    status: "complete"
                )
            )
        }

        let tokenService = TokenService(
            hellgateClient: hellgateClient,
            client: client
        )

        let cardData = CardData(cardNumber: "1234123412341234", year: "12", month: "12", cvc: "123")
        let result = await tokenService.tokenize(sessionId: "", cardData: cardData, additionalData: [:])

        if case .success(let success) = result {
            XCTAssertEqual(success.id, "1")
        } else {
            XCTFail()
        }
    }

    func test_Given_CardDetailsValidProviderExternal_When_FailedTokenize_Then_Fail() async {
        let client = MockClient()

        let hellgateClient = MockHellgateClient {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: nil,
                        apiKey: "key",
                        provider: .external,
                        baseUrl: "https://api-reference.hellgate.io"
                    ),
                    nextAction: .tokenize_card,
                    status: nil
                )
            )
        } competeTokenizeCard: {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: "1",
                        apiKey: nil,
                        provider: nil,
                        baseUrl: nil
                    ),
                    nextAction: nil,
                    status: "complete"
                )
            )
        }

        let tokenService = TokenService(
            hellgateClient: hellgateClient,
            client: client
        )

        let cardData = CardData(cardNumber: "1234123412341234", year: "12", month: "12", cvc: "123")
        let result = await tokenService.tokenize(sessionId: "", cardData: cardData, additionalData: [:])

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, "Tokenization failed")
        } else {
            XCTFail()
        }
    }

    func test_Given_CardDetailsValidProviderGuardian_When_FailedTokenize_Then_Fail() async {
        let client = MockClient()

        let hellgateClient = MockHellgateClient {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: nil,
                        apiKey: "key",
                        provider: .guardian,
                        baseUrl: "https://api-reference.hellgate.io"
                    ),
                    nextAction: .tokenize_card,
                    status: nil
                )
            )
        } competeTokenizeCard: {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: "1",
                        apiKey: nil,
                        provider: nil,
                        baseUrl: nil
                    ),
                    nextAction: nil,
                    status: "complete"
                )
            )
        }

        let tokenService = TokenService(
            hellgateClient: hellgateClient,
            client: client
        )

        let cardData = CardData(cardNumber: "1234123412341234", year: "12", month: "12", cvc: "123")
        let result = await tokenService.tokenize(sessionId: "", cardData: cardData, additionalData: [:])

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, "Tokenization failed")
        } else {
            XCTFail()
        }
    }

    func test_Given_CardDetailsValidProviderUnknown_When_FailedTokenize_Then_Fail() async {
        let client = MockClient()

        let hellgateClient = MockHellgateClient {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: nil,
                        apiKey: "key",
                        provider: nil,
                        baseUrl: "https://api-reference.hellgate.io"
                    ),
                    nextAction: .tokenize_card,
                    status: nil
                )
            )
        } competeTokenizeCard: {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: "1",
                        apiKey: nil,
                        provider: nil,
                        baseUrl: nil
                    ),
                    nextAction: nil,
                    status: "complete"
                )
            )
        }

        let tokenService = TokenService(
            hellgateClient: hellgateClient,
            client: client
        )

        let cardData = CardData(cardNumber: "1234123412341234", year: "12", month: "12", cvc: "123")
        let result = await tokenService.tokenize(sessionId: "", cardData: cardData, additionalData: [:])

        if case .failure(let failure) = result {
            XCTAssertEqual(failure.localizedDescription, "Tokenization failed")
        } else {
            XCTFail()
        }
    }
}
