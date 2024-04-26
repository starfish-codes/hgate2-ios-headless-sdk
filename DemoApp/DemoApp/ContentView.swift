import SwiftUI
import Hellgate_iOS_SDK

struct ContentView: View {
    @State var cardNumberState = ComponentState.incomplete

    var body: some View {
        VStack {
            CardNumberView(
                state: $cardNumberState,
                image: .leading
            )
            .border()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
