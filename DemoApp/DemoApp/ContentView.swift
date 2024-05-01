import SwiftUI
import Hellgate_iOS_SDK

struct ContentView: View {
    @State var cardNumberViewState = ViewState(state: .blank)
    @State var expiryViewState = ViewState(state: .blank)
    @State var cvcViewState = ViewState(state: .blank)

    static let sandboxURL = URL(string: "https://sandbox.hellgate.io")!
    @State var secretKey = "sk_sndbx_AZhTZM8yTJ39D3fDtZI"
    @State var sessionId = ""

    @State var hellgate: Hellgate?

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                TextField("Secret API Key", text: $secretKey)
                    .frame(height: 44)
                TextField("Session Id", text: $sessionId)
                    .frame(height: 44)

                HStack {

                    Button("Get Session Id") {
                        Task {
                            await fetchSessionId()
                            hellgate = await initHellgate(baseUrl: Self.sandboxURL, sessionId: sessionId)
                        }
                    }

                    Spacer()

                    Button("Get Session Status") {
                        Task {
                            if let hellgate = self.hellgate {
                                print(await hellgate.fetchSessionStatus())
                            }
                        }
                    }
                    .disabled(sessionId.isEmpty)
                }
                .frame(height: 44)
            }
            .padding(8)
            .background(Color(uiColor: .systemGroupedBackground))
            .padding(.bottom, 32)

            VStack(alignment: .leading) {
                Text("Card Details")
                    .font(.caption)

                CardNumberView(
                    viewState: $cardNumberViewState,
                    image: .leading
                )
                    .border()

                ExpiryDateField(viewState: $expiryViewState)
                    .border()

                CvcView(viewState: $cvcViewState, length: .cvc)
                    .border()

                Button("Tokenize") {
                    Task {
                        if let hellgate = self.hellgate {
                            let handle = await hellgate.cardHandler()
                            _ = handle?.tokenizeCard(
                                cardNumberViewState,
                                cvcViewState,
                                expiryViewState,
                                []
                            )
                        }
                    }
                }
                .frame(height: 44)
                .disabled(sessionId.isEmpty)
            }

            Spacer()
        }
        .padding()
    }

    // This called needs to be performed on your backend servers
    private func fetchSessionId() async {
        var url = Self.sandboxURL
        url.appendPathComponent("tokens")
        url.appendPathComponent("session")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(secretKey, forHTTPHeaderField: "X-API-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print(String(data: data, encoding: .utf8)!)

            let result = try JSONDecoder().decode(Session.self, from: data)
            self.sessionId = result.session_id
        } catch {
            print(error)
        }

    }
}

struct Session: Decodable {
    let session_id: String
}

#Preview {
    ContentView()
}
