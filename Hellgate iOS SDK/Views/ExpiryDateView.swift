import Combine
import SwiftUI

private enum Constant {
    static let PLACEHOLDER_TEXT = "MM / YY"

    static let INTERNAL_PADDING: CGFloat = 4
    static let INTERNAL_BORDER_RADIUS: CGFloat = 8

    static let COMPLETE_COLOR = Color.blue
    static let INVALID_COLOR = Color.red
    static let DEFAULT_COLOR = Color.black
}

public class ExpiryDateViewViewModel: ObservableObject {
    @Binding var viewState: ViewState
    @Published var value: String = ""
    @Published var color: Color = .black
    private let currentDate: Date
    private let queue: DispatchQueue

    var cancellable: AnyCancellable?

    public init(
        viewState: Binding<ViewState>,
        value: String,
        currentDate: Date = .now,
        queue: DispatchQueue = .main
    ) {
        self._viewState = viewState
        self.value = value
        self.currentDate = currentDate
        self.queue = queue

        cancellable = self.$value
            .sink { [weak self] newValue in
                self?.update(value: newValue)
            }
    }

    private func update(value: String) {
        queue.async { [weak self] in
            guard let self = self else { return }

            self.viewState = self.state(value: value)
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

    private func state(value: String) -> ViewState {
        guard !value.isEmpty else { return ViewState(state: .blank, value: value) }
        guard value.count == 4 else { return ViewState(state: .incomplete, value: value) }

        guard let month = Int(value.prefix(2)),
                (1...12).contains(month) else {
            return ViewState(state: .invalid, value: value)
        }

        if let year = Int("20" + value.suffix(2)) {
            var components = DateComponents()
            components.month = month
            components.year = year

            let expiry = Calendar.current.date(from: components)
            let now = self.currentDate

            // Allow cards that expire this month
            if let expiry = expiry {
                if now.compare(expiry) == .orderedDescending {
                    return ViewState(state: .invalid, value: value)
                }
            }
        }

        return ViewState(state: .complete, value: value)
    }
}

public struct ExpiryDateField: View {
    @StateObject var viewModel: ExpiryDateViewViewModel
    let padding: CGFloat

    let onBegin: (() -> Void)?
    let onEnd: (() -> Void)?

    public init(
        viewState: Binding<ViewState>,
        padding: CGFloat = 0,
        onBegin: (() -> Void)? = nil,
        onEnd: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(
            wrappedValue: ExpiryDateViewViewModel(
                viewState: viewState,
                value: ""
            )
        )
        self.padding = padding
        self.onBegin = onBegin
        self.onEnd = onEnd
    }

    public var body: some View {
        WrappedUITextField(
            value: $viewModel.value,
            placeholder: Constant.PLACEHOLDER_TEXT,
            fontSize: 16,
            foregroundColor: viewModel.color,
            backgroundColor: .white,
            keyboardType: .numberPad,
            formatter: ExpiryDateFormatter(),
            onBegin: onBegin,
            onEnd: onEnd
        )
        .padding(8)
        .frame(height: 44)
    }
}

extension ExpiryDateField {
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

    var defaultState = ViewState(state: .blank)
    let defaultStateBind = Binding { defaultState } set: { state in defaultState = state }

    return ScrollView {
        Text("Default")
        ExpiryDateField(
            viewState: defaultStateBind
        )

        Text("Border applied")

        ExpiryDateField(
            viewState: defaultStateBind
        )
        .border()
    }
}

#endif
