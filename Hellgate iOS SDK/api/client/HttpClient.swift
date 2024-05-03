protocol URLDataTask {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: URLDataTask {}

class HttpClient {
    private let session: URLDataTask

    init(session: URLDataTask = URLSession.shared) {
        self.session = session
    }

    enum HttpError: Error {
        case failedToEncodeBody
        case failedToDecodeBody
        case statusCode(Int)
        case unknown
    }

    func request<Response: Decodable>(
        method: String = "GET",
        url: URL,
        headers: [String: String] = [:]
    ) async -> Result<Response, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = method

        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        return await make(request: request)
    }

    func request<Body: Encodable, Response: Decodable>(
        method: String = "GET",
        url: URL,
        body: Body? = nil,
        headers: [String: String] = [:]
    ) async -> Result<Response, Error> {
        let jsonEncoder = JSONEncoder()

        var request = URLRequest(url: url)
        request.httpMethod = method

        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let data = try jsonEncoder.encode(body)
                request.httpBody = data
            } catch {
                return .failure(HttpError.failedToEncodeBody)
            }
        }

        return await make(request: request)
    }

    private func make<Response: Decodable>(request: URLRequest) async -> Result<Response, Error> {

        do {
            let (data, response) = try await self.session.data(for: request, delegate: nil)

            #if DEBUG
            print("Result JSON:")
            print(String(data: data, encoding: .utf8)!)
            #endif

            if let response = response as? HTTPURLResponse {
                // TODO: Add correct status code responses
                switch response.statusCode {
                case 201...999: throw HttpError.statusCode(response.statusCode)
                default: break
                }
            }

            let jsonDecoder = JSONDecoder()
            let result = try jsonDecoder.decode(Response.self, from: data)
            return .success(result)
        } catch is DecodingError {
            return .failure(HttpError.failedToDecodeBody)
        } catch {
            return .failure(error)
        }
    }
}
