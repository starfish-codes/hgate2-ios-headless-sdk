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

public struct AdditionalFieldsView: View {
    let type: AdditionalFieldType
    @State var text: String
    let padding: CGFloat

    let onBegin: (() -> Void)?
    let onEnd: (() -> Void)?

    public init(
        type: AdditionalFieldType,
        padding: CGFloat = 0,
        onBegin: (() -> Void)? = nil,
        onEnd: (() -> Void)? = nil
    ) {
        self.type = type
        self.text = ""
        self.padding = padding
        self.onBegin = onBegin
        self.onEnd = onEnd
    }

    public var body: some View {
        WrappedUITextField(
            value: $text,
            placeholder: type.label,
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

    var defaultState = ComponentState.blank
    let defaultStateBind = Binding { defaultState } set: { state in defaultState = state }

    return ScrollView {
        Text("Default")
        AdditionalFieldsView(type: .CARDHOLDER_NAME)

        Text("Border applied")
        AdditionalFieldsView(type: .CARDHOLDER_NAME)
            .border()
    }
}

#endif
