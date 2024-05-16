import Combine
import SwiftUI

private enum Constant {
    static let INTERNAL_PADDING: CGFloat = 4
    static let INTERNAL_BORDER_RADIUS: CGFloat = 8

    static let COMPLETE_COLOR = Color.blue
    static let INVALID_COLOR = Color.red
    static let DEFAULT_COLOR = Color.black
}

public enum AdditionalFieldType: String {
    case CARDHOLDER_NAME = "Cardholder Name"
    case EMAIL = "E-Mail"
    case BILLING_ADDRESS_LINE_1 = "Billing Address Line 1"
    case BILLING_ADDRESS_LINE_2 = "Billing Address Line 2"
    case BILLING_ADDRESS_LINE_3 = "Billing Address Line 3"
    case BILLING_ADDRESS_POSTAL_CODE = "Postal Code"
    case BILLING_ADDRESS_CITY = "City"
    case BILLING_ADDRESS_COUNTRY = "Country"

    var label: String {
        self.rawValue
    }
}

public class AdditionalFieldsViewModel: ObservableObject {
    @Binding var viewState: ViewState
    @Published var value: String = ""
    let placeholder: String
    private let queue: DispatchQueue

    var cancellable: AnyCancellable?

    public init(
        type: AdditionalFieldType,
        viewState: Binding<ViewState>,
        queue: DispatchQueue = .main
    ) {
        self._viewState = viewState
        self.value = viewState.wrappedValue.value
        self.queue = queue
        self.placeholder = type.label

        cancellable = self.$value
            .sink { [weak self] newValue in
                self?.update(value: newValue)
            }
    }

    private func update(value: String) {
        queue.async { [weak self] in
            guard let self = self else { return }

            self.viewState = self.state(value: value)
        }
    }

    private func state(value: String) -> ViewState {
        guard !value.isEmpty else { return ViewState(state: .blank, value: value) }
        return ViewState(state: .complete, value: value)
    }
}

public struct AdditionalFieldsView: View {
    @StateObject var viewModel: AdditionalFieldsViewModel
    let padding: CGFloat

    let onBegin: (() -> Void)?
    let onEnd: (() -> Void)?

    public init(
        type: AdditionalFieldType,
        viewState: Binding<ViewState>,
        padding: CGFloat = 0,
        onBegin: (() -> Void)? = nil,
        onEnd: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: AdditionalFieldsViewModel(type: type, viewState: viewState))
        self.padding = padding
        self.onBegin = onBegin
        self.onEnd = onEnd
    }

    public var body: some View {
        WrappedUITextField(
            value: $viewModel.value,
            placeholder: viewModel.placeholder,
            fontSize: 16,
            foregroundColor: .black,
            backgroundColor: .white,
            keyboardType: .default,
            formatter: nil,
            onBegin: onBegin,
            onEnd: onEnd
        )
        .padding(8)
        .frame(height: 44)
    }
}

extension AdditionalFieldsView {
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
        VStack {
            Text("Default")
            AdditionalFieldsView(
                type: .CARDHOLDER_NAME,
                viewState: defaultStateBind
            )

            Text("Border applied")
            AdditionalFieldsView(
                type: .CARDHOLDER_NAME,
                viewState: defaultStateBind
            )
                .border()
        }
        .padding()
    }
}

#endif
