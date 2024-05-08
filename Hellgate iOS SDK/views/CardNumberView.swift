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

public class CardNumberViewViewModel: ObservableObject {
    @Binding var viewState: ViewState

    @Published var value: String = ""
    @Published var color: Color = .black
    @Published var cardBrand: CardBrand = .unknown
    private let queue: DispatchQueue

    var cancellable: AnyCancellable?

    public init(
        viewState: Binding<ViewState>,
        value: String,
        cardBrand: CardBrand,
        queue: DispatchQueue = .main
    ) {
        self.value = value
        self.cardBrand = cardBrand
        self.queue = queue
        self._viewState = viewState

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

            self.viewState = self.state(brand: self.cardBrand, value: value)
            self.color = self.color(state: self.viewState.state)
        }
    }

    private func color(state: ComponentState) -> Color {
        switch state {
        case .complete: return Constant.COMPLETE_COLOR
        case .incomplete, .blank: return Constant.DEFAULT_COLOR
        case .invalid: return Constant.INVALID_COLOR
        }
    }

    private func state(brand: CardBrand = .unknown, value: String) -> ViewState {
        guard !value.isEmpty else { return ViewState(state: .blank, value: value) }
        guard brand != .unknown else { return ViewState(state: .incomplete, value: value) }

        let details = brand.details

        let numberAllowedDigits = details.maxLength(for: value)
        let luhnValid = isValidLUHN(value)
        let isDigitLimit = numberAllowedDigits != -1

        let incomplete = isDigitLimit && value.count < numberAllowedDigits
        let invalid = !luhnValid
        let full = isDigitLimit && value.count == numberAllowedDigits

        if incomplete {
            return ViewState(state: .incomplete, value: value)
        } else if invalid {
            return ViewState(state: .invalid, value: value)
        } else if full {
            return ViewState(state: .complete, value: value)
        }

        return ViewState(state: .blank, value: value)
    }
}

public struct CardNumberView: View {
    @StateObject var viewModel: CardNumberViewViewModel

    let image: ImagePosition
    let padding: CGFloat

    let onBegin: (() -> Void)?
    let onEnd: (() -> Void)?

    public enum ImagePosition {
        case leading
        case trailing
        case hidden
    }

    public init(
        viewState: Binding<ViewState>,
        image: ImagePosition,
        padding: CGFloat = 0,
        onBegin: (() -> Void)? = nil,
        onEnd: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(
            wrappedValue: CardNumberViewViewModel(
                viewState: viewState,
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

    var viewState = ViewState(state: .blank)
    let viewStateBind = Binding { viewState } set: { state in viewState = state }

    return ScrollView {
        Text("Default")
        CardNumberView(
            viewState: viewStateBind,
            image: .leading
        )

        CardNumberView(
            viewState: viewStateBind,
            image: .trailing
        )

        CardNumberView(
            viewState: viewStateBind,
            image: .hidden
        )

        Text("Border applied")

        CardNumberView(
            viewState: viewStateBind,
            image: .leading
        )
        .border()

        CardNumberView(
            viewState: viewStateBind,
            image: .trailing
        )
        .border()

        CardNumberView(
            viewState: viewStateBind,
            image: .hidden
        )
        .border()
    }
}

#endif
