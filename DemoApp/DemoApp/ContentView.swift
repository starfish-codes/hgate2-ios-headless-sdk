import SwiftUI
import Hellgate_iOS_SDK

struct ContentView: View {
    @State var cardNumberState = ComponentState.incomplete
    @State var expiryState = ComponentState.incomplete
    @State var cvcState = ComponentState.incomplete

    var body: some View {
        VStack {
            CardNumberView(
                state: $cardNumberState,
                image: .leading
            )
            .border()

            ExpiryDateField(state: $expiryState)
                .border()

            CvcView(state: $cvcState, length: .cvc)
                .border()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
