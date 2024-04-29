import Combine
import SwiftUI

private enum Constant {
    static let PLACEHOLDER_TEXT_CVC = "CVC"
    static let PLACEHOLDER_TEXT_CVV = "CVV"

    static let INTERNAL_PADDING: CGFloat = 4
    static let INTERNAL_BORDER_RADIUS: CGFloat = 8

    static let COMPLETE_COLOR = Color.blue
    static let INVALID_COLOR = Color.red
    static let DEFAULT_COLOR = Color.black
}

public enum Cvc: UInt {
    case cvc = 3
    case cvv = 4

    var placeholder: String {
        switch self {
        case .cvc: return Constant.PLACEHOLDER_TEXT_CVC
        case .cvv: return Constant.PLACEHOLDER_TEXT_CVV
        }
    }
}

public class CvcViewViewModel: ObservableObject {
    @Binding var state: ComponentState
    @Published var value: String = ""
    @Published var color: Color = .black
    let length: UInt
    let placeholder: String
    private let queue: DispatchQueue

    var cancellable: AnyCancellable?

    public init(
        state: Binding<ComponentState>,
        value: String,
        length: Cvc,
        queue: DispatchQueue = .main
    ) {
        self._state = state
        self.value = value
        self.length = length.rawValue
        self.queue = queue
        self.placeholder = length.placeholder

        cancellable = self.$value
            .sink { [weak self] newValue in
                self?.update(value: newValue)
            }
    }

    private func update(value: String) {
        queue.async { [weak self] in
            guard let self = self else { return }

            self.state = self.state(value: value)
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

    private func state(value: String) -> ComponentState {
        guard !value.isEmpty else { return .blank }
        guard value.count == self.length else { return .incomplete }
        return .complete
    }
}

public struct CvcView: View {
    @StateObject private var viewModel: CvcViewViewModel
    let padding: CGFloat

    let onBegin: (() -> Void)?
    let onEnd: (() -> Void)?

    public init(
        state: Binding<ComponentState>,
        length: Cvc,
        padding: CGFloat = 0,
        onBegin: (() -> Void)? = nil,
        onEnd: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(
            wrappedValue: CvcViewViewModel(
                state: state,
                value: "",
                length: length
            )
        )
        self.padding = padding
        self.onBegin = onBegin
        self.onEnd = onEnd
    }

    public var body: some View {
        WrappedUITextField(
            value: $viewModel.value,
            placeholder: viewModel.placeholder,
            fontSize: 16,
            foregroundColor: viewModel.color,
            backgroundColor: .white,
            keyboardType: .numberPad,
            formatter: CvcFormatter(maxLength: viewModel.length),
            onBegin: onBegin,
            onEnd: onEnd
        )
        .padding(8)
        .frame(height: 44)
    }
}

extension CvcView {
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

    return ScrollView {
        Text("Default")
        CvcView(
            state: defaultStateBind,
            length: .cvc
        )

        CvcView(
            state: defaultStateBind,
            length: .cvv
        )

        Text("Border applied")

        CvcView(
            state: defaultStateBind,
            length: .cvc
        )
        .border()

        CvcView(
            state: defaultStateBind,
            length: .cvv
        )
        .border()
    }
}

#endif
