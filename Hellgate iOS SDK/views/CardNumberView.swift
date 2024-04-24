import SwiftUI

public struct CardNumberView: View {
    @State var cardBrand: CardBrand = .unknown
    
    @Binding var state: ComponentState
    @Binding var value: String
    var image: ImagePosition
    var padding: CGFloat
    
    public enum ComponentState {
        case complete
        case incomplete
        case blank
        case invalid
    }

    public enum ImagePosition {
        case leading
        case trailing
        case hidden
    }

    public init(
        state: Binding<ComponentState>,
        value: Binding<String>,
        image: ImagePosition,
        padding: CGFloat = 0
    ) {
        self._state = state
        self._value = value
        self.image = image
        self.padding = padding
    }
    
    public var body: some View {
        let imageView = Image(cardBrand.details.icon, bundle: .init(for: CardNumberFormatter.self as AnyClass))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding([.horizontal], 4)
        
        return HStack {
            if case .leading = image {
                imageView
            }

            WrappedUITextField(
                value: $value,
                placeholder: "Card Number",
                fontSize: 16,
                foregroundColor: color(state: self.state),
                backgroundColor: .white,
                keyboardType: .numberPad,
                formatter: CardNumberFormatter()
            )
            .padding(self.padding)
            .onChange(of: value) { value in
                self.cardBrand = CardBrand.first(from: value)
                #if DEBUG
                print("Value: \(self.value) -> \(value), brand: \(self.cardBrand)")
                #endif

                self.state = state(brand: self.cardBrand, value: value)
            }

            if case .trailing = image {
                imageView
            }
        }
        .padding(8)
        .frame(height: 44)
    }
    
    private func color(state: ComponentState) -> Color {
        switch state {
        case .complete: .blue
        case .incomplete, .blank: .black
        case .invalid: .red
        }
    }
    
    private func state(brand: CardBrand = .unknown, value: String) -> ComponentState {
        guard !value.isEmpty else { return .blank }
        guard brand != .unknown else { return .incomplete }

        let details = brand.details
        
        let numberAllowedDigits = details.maxLength(for: value)
        let luhnValid = isValidLUHN(value)
        let isDigitLimit = numberAllowedDigits != -1
        
        let incomplete = isDigitLimit && value.count < numberAllowedDigits
        let invalid = !luhnValid
        let full = isDigitLimit && value.count == numberAllowedDigits
        
        if incomplete {
            return .incomplete
        } else if invalid {
            return .invalid
        } else if full {
            return .complete
        }
        
        return .blank
    }
}

extension CardNumberView {
    public func border() -> some View {
        self
            .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary)
        )
    }
}

#Preview {
    
    var data = "1234123412341234"
    let bind = Binding { data } set: { value in data = value }
    
    var defaultState = CardNumberView.ComponentState.blank
    let defaultStateBind = Binding { defaultState } set: { state in defaultState = state }
    
    var completState = CardNumberView.ComponentState.complete
    let completStateBind = Binding { completState } set: { state in completState = state }
    
    var inValidState = CardNumberView.ComponentState.invalid
    let inValidStateBind = Binding { inValidState } set: { state in inValidState = state }

    return ScrollView {
        Text("Default")
        CardNumberView(
            state: defaultStateBind,
            value: bind,
            image: .leading
        )
        
        CardNumberView(
            state: defaultStateBind,
            value: bind,
            image: .trailing
        )
        
        CardNumberView(
            state: defaultStateBind,
            value: bind,
            image: .hidden
        )
        
        Text("Default - Complete")
        CardNumberView(
            state: completStateBind,
            value: bind,
            image: .leading
        )
        
        CardNumberView(
            state: completStateBind,
            value: bind,
            image: .trailing
        )
        
        CardNumberView(
            state: completStateBind,
            value: bind,
            image: .hidden
        )
        
        Text("Default - Invalid")
        CardNumberView(
            state: inValidStateBind,
            value: bind,
            image: .leading
        )
        
        CardNumberView(
            state: inValidStateBind,
            value: bind,
            image: .trailing
        )
        
        CardNumberView(
            state: inValidStateBind,
            value: bind,
            image: .hidden
        )
        
        Text("Border applied")
        
        CardNumberView(
            state: defaultStateBind,
            value: bind,
            image: .leading
        )
        .border()
        
        CardNumberView(
            state: defaultStateBind,
            value: bind,
            image: .trailing
        )
        .border()
        
        CardNumberView(
            state: defaultStateBind,
            value: bind,
            image: .hidden
        )
        .border()
    }
}
