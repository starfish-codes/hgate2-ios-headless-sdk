import SwiftUI
import Hellgate_iOS_SDK

struct ContentView: View {
    @State var cardNumberState = CardNumberView.ComponentState.incomplete
    @State var value: String = "12341234"
    
    var body: some View {
        VStack {
            CardNumberView(
                state: $cardNumberState,
                value: $value,
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
