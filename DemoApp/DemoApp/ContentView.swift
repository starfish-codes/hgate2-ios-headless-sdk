import SwiftUI
import Hellgate_iOS_SDK

struct ContentView: View {
    @State var cardNumberState = ComponentState.incomplete
    @State var expiryState = ComponentState.incomplete

    var body: some View {
        VStack {
            CardNumberView(
                state: $cardNumberState,
                image: .leading
            )
            .border()

            ExpiryDateField(state: $expiryState)
                .border()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
