@testable import Hellgate_iOS_SDK

class MockClient: HttpClientSession {
    typealias Handler = (() -> Result<Decodable, Error>)
    struct FakeError: Error {}

    var request: [String: String] = [:]

    func request<Response: Decodable>(
        method: String,
        url: URL,
        headers: [String : String]
    ) async -> Result<Response, Error> {
        return await mock(url: url)
    }

    func request<Body: Encodable, Response: Decodable>(
        method: String,
        url: URL,
        body: Body?,
        headers: [String : String]
    ) async -> Result<Response, Error> {
        return await mock(url: url)
    }

    private func mock<Response: Decodable>(url: URL) async -> Result<Response, Error> {

        guard let response = request[url.absoluteString] else { return .failure(FakeError()) }

        guard let data = response.data(using: .utf8) else { return .failure(FakeError()) }

        if let result = try? JSONDecoder().decode(Response.self, from: data) {

            return .success(result)
        } else {
            return .failure(FakeError())
        }
    }
}
