import Combine
import SwiftUI

private enum Constant {
    static let PLACEHOLDER_TEXT = "Card number"

    static let INTERNAL_PADDING: CGFloat = 4
    static let INTERNAL_BORDER_RADIUS: CGFloat = 8

    static let COMPLETE_COLOR = Color.blue
    static let INVALID_COLOR = Color.red
    static let DEFAULT_COLOR = Color.black
}

public enum ComponentState {
    case complete
    case incomplete
    case blank
    case invalid
}

public class CardNumberViewViewModel: ObservableObject {
    @Binding var state: ComponentState
    @Published var value: String = ""
    @Published var color: Color = .black
    @Published var cardBrand: CardBrand = .unknown
    private var queue: DispatchQueue

    var cancellable: AnyCancellable?

    public init(
        state: Binding<ComponentState>,
        value: String,
        cardBrand: CardBrand,
        queue: DispatchQueue = .main
    ) {
        self._state = state
        self.value = value
        self.cardBrand = cardBrand
        self.queue = queue

        cancellable = self.$value
            .sink { [weak self] newValue in
            self?.update(value: newValue)
        }
    }

    private func update(value: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.cardBrand = CardBrand.first(from: value)

#if DEBUG
            print("Value: \(self.value) -> \(value), brand: \(self.cardBrand)")
#endif

            self.state = self.state(brand: self.cardBrand, value: value)
            self.color = self.color(state: self.state)
        }
    }

    private func color(state: ComponentState) -> Color {
        switch state {
        case .complete: return Constant.COMPLETE_COLOR
        case .incomplete, .blank: return Constant.DEFAULT_COLOR
        case .invalid: return Constant.INVALID_COLOR
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

public struct CardNumberView: View {
    @StateObject private var viewModel: CardNumberViewViewModel

    var image: ImagePosition
    var padding: CGFloat

    var onBegin: (() -> Void)?
    var onEnd: (() -> Void)?

    public enum ImagePosition {
        case leading
        case trailing
        case hidden
    }

    public init(
        state: Binding<ComponentState>,
        image: ImagePosition,
        padding: CGFloat = 0,
        onBegin: (() -> Void)? = nil,
        onEnd: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(
            wrappedValue: CardNumberViewViewModel(
                state: state,
                value: "",
                cardBrand: .unknown
            )
        )
        self.image = image
        self.padding = padding
        self.onBegin = onBegin
        self.onEnd = onEnd
    }

    public var body: some View {
        let imageView = Image(
            viewModel.cardBrand.details.icon,
            bundle: .init(for: CardNumberFormatter.self as AnyClass)
        )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding([.horizontal], Constant.INTERNAL_PADDING)

        return HStack {
            if case .leading = image {
                imageView
            }

            WrappedUITextField(
                value: $viewModel.value,
                placeholder: Constant.PLACEHOLDER_TEXT,
                fontSize: 16,
                foregroundColor: viewModel.color,
                backgroundColor: .white,
                keyboardType: .numberPad,
                formatter: CardNumberFormatter(),
                onBegin: onBegin,
                onEnd: onEnd
            )
            .padding(self.padding)

            if case .trailing = image {
                imageView
            }
        }
        .padding(8)
        .frame(height: 44)
    }
}

extension CardNumberView {
    public func border() -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: Constant.INTERNAL_BORDER_RADIUS)
                .stroke(.secondary)
        )
    }
}

#if swift(>=5.9)

#Preview {

    var defaultState = ComponentState.blank
    let defaultStateBind = Binding { defaultState } set: { state in defaultState = state }

    var completState = ComponentState.complete
    let completStateBind = Binding { completState } set: { state in completState = state }

    var inValidState = ComponentState.invalid
    let inValidStateBind = Binding { inValidState } set: { state in inValidState = state }

    return ScrollView {
        Text("Default")
        CardNumberView(
            state: defaultStateBind,
            image: .leading
        )

        CardNumberView(
            state: defaultStateBind,
            image: .trailing
        )

        CardNumberView(
            state: defaultStateBind,
            image: .hidden
        )

        Text("Default - Complete")
        CardNumberView(
            state: completStateBind,
            image: .leading
        )

        CardNumberView(
            state: completStateBind,
            image: .trailing
        )

        CardNumberView(
            state: completStateBind,
            image: .hidden
        )

        Text("Default - Invalid")
        CardNumberView(
            state: inValidStateBind,
            image: .leading
        )

        CardNumberView(
            state: inValidStateBind,
            image: .trailing
        )

        CardNumberView(
            state: inValidStateBind,
            image: .hidden
        )

        Text("Border applied")

        CardNumberView(
            state: defaultStateBind,
            image: .leading
        )
        .border()

        CardNumberView(
            state: defaultStateBind,
            image: .trailing
        )
        .border()

        CardNumberView(
            state: defaultStateBind,
            image: .hidden
        )
        .border()
    }
}

#endif
