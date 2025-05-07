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
        } completeTokenizeCardEncrypted: {
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
        } completeTokenizeCardEncrypted: {
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
                        baseUrl: "https://api-reference.hellgate.io",
                        jwk: nil
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
                        baseUrl: nil,
                        jwk: nil
                    ),
                    nextAction: nil,
                    status: "complete"
                )
            )
        } completeTokenizeCardEncrypted: {
            .failure(FakeError())
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
                        baseUrl: "https://api-reference.hellgate.io",
                        jwk: .testData
                    ),
                    nextAction: .tokenize_card,
                    status: nil
                )
            )
        } competeTokenizeCard: {
            .failure(FakeError())
        } completeTokenizeCardEncrypted: {
            .success(
                .init(
                    data: SessionResponse.TokenData(
                        tokenId: "23",
                        apiKey: nil,
                        provider: nil,
                        baseUrl: nil,
                        jwk: .testData
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

        switch result {
        case .success(let success): XCTAssertEqual(success.id, "23")
        case .failure(let error): XCTFail("\(error)")
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
                        baseUrl: "https://api-reference.hellgate.io",
                        jwk: nil
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
                        baseUrl: nil,
                        jwk: nil
                    ),
                    nextAction: nil,
                    status: "complete"
                )
            )
        } completeTokenizeCardEncrypted: {
            .failure(FakeError())
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
                        baseUrl: "https://api-reference.hellgate.io",
                        jwk: nil
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
                        baseUrl: nil,
                        jwk: nil
                    ),
                    nextAction: nil,
                    status: "complete"
                )
            )
        } completeTokenizeCardEncrypted: {
            .failure(FakeError())
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

extension SessionResponse.JWK {

    static var testData: SessionResponse.JWK {
        SessionResponse.JWK(kty: "RSA", n: "yLyhcdVjD88GgNLiQcB5BBDxQ3130F1621OiPKqiqPrCGe3HmrkPyWCuYouoZg6CtCdPpI2g_4vn3JjFLlSfsRKHbfzMA89vdPJDb-eqyiGSFeNUcmW82TguLw-lF3wuU7AmQMrhLGkwid5bdDwlzRQd6fsAZ6yLE31qcR7oshTruOycf7hyu1p5tV3DXkhO1DcqK0j7U6SUAbCOraR9bXMnXN-qEA3KzM2M7hU_RkzndOscD7uI9uYD6TaSEnuL4o6m8Xo8oJP9REp6ttKuqFjfu1RzYdWiTNgQKko7PgoCVTI0LWSCOT1p7ckpUTYdBcLpRajVxmpP56Q07zsDGQ", e: "AQAB")
    }

}
