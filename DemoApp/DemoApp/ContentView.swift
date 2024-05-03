import SwiftUI
import Hellgate_iOS_SDK

struct ContentView: View {
    @StateObject var viewModel = ContentViewViewModel()

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Secret API Key", text: $viewModel.secretKey)
                    .frame(height: 44)
                Text("Session Id: \(viewModel.sessionId)")
                    .frame(height: 44)
                Text("Status: \(viewModel.sessionState?.rawValue ?? "N/A")")
                    .frame(height: 44)
            }
            .padding(8)
            .background(Color(uiColor: .systemGroupedBackground))
            if viewModel.sessionState != nil {
                Button("Restart session") {
                    Task {
                        await viewModel.initSession()
                    }
                }
                .padding(.bottom, 32)
            }

            VStack {
                switch viewModel.sessionState {
                case .UNKNOWN:
                    Button("Get Session Status") {
                        Task {
                            await viewModel.sessionStatus()
                        }
                    }

                case .REQUIRE_TOKENIZATION:
                    VStack(alignment: .leading) {
                        Text("Card Details")
                            .font(.caption)

                        CardNumberView(
                            viewState: $viewModel.cardNumberViewState,
                            image: .leading
                        )
                        .border()

                        ExpiryDateField(viewState: $viewModel.expiryViewState)
                            .border()

                        CvcView(viewState: $viewModel.cvcViewState, length: .cvc)
                            .border()

                        Button("Tokenize") {
                            Task {
                                await viewModel.tokenize()
                            }
                        }
                        .frame(height: 44)
                        .disabled(viewModel.sessionId.isEmpty)
                    }
                case .WAITING:
                    Text("Session status: \(viewModel.sessionState?.rawValue ?? "N/A")")

                case .COMPLETED:
                    Text("Session status: \(viewModel.sessionState?.rawValue ?? "N/A")")
                    Text(viewModel.token ?? "N/A")

                default:
                    Button("Start session") {
                        Task {
                            await viewModel.initSession()
                        }
                    }
                }
            }



            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
