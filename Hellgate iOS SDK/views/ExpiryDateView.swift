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
    @Binding var state: ComponentState
    @Published var value: String = ""
    @Published var color: Color = .black
    private var currentDate: Date
    private var queue: DispatchQueue

    var cancellable: AnyCancellable?

    public init(
        state: Binding<ComponentState>,
        value: String,
        currentDate: Date = .now,
        queue: DispatchQueue = .main
    ) {
        self._state = state
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
        guard value.count == 4 else { return .incomplete }

        if let month = Int(value.prefix(2)),
           let year = Int("20" + value.suffix(2)) {

            var components = DateComponents()
            components.month = month
            components.year = year

            let expiry = Calendar.current.date(from: components)
            let now = self.currentDate

            // Allow cards that expire this month
            if let expiry = expiry {
                if now.compare(expiry) == .orderedDescending {
                    return .invalid
                }
            }
        }

        return .complete
    }
}

public struct ExpiryDateField: View {
    @StateObject private var viewModel: ExpiryDateViewViewModel
    var padding: CGFloat

    var onBegin: (() -> Void)?
    var onEnd: (() -> Void)?

    public init(
        state: Binding<ComponentState>,
        padding: CGFloat = 0,
        onBegin: (() -> Void)? = nil,
        onEnd: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(
            wrappedValue: ExpiryDateViewViewModel(
                state: state,
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

    var defaultState = ComponentState.blank
    let defaultStateBind = Binding { defaultState } set: { state in defaultState = state }

    var completState = ComponentState.complete
    let completStateBind = Binding { completState } set: { state in completState = state }

    var inValidState = ComponentState.invalid
    let inValidStateBind = Binding { inValidState } set: { state in inValidState = state }

    return ScrollView {
        Text("Default")
        ExpiryDateField(
            state: defaultStateBind
        )

        Text("Default - Complete")
        ExpiryDateField(
            state: completStateBind
        )

        Text("Default - Invalid")
        ExpiryDateField(
            state: inValidStateBind
        )

        Text("Border applied")

        ExpiryDateField(
            state: defaultStateBind
        )
        .border()
    }
}

#endif
