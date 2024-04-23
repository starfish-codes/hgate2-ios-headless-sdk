import SwiftUI
import Hellgate_iOS_SDK

struct ContentView: View {
    @State var cardNumberState = CardNumberView.State()
    @State var value: String = "1234 1234"
    
    var body: some View {
        VStack {
            CardNumberView(state: $cardNumberState, value: $value, image: .leading)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
