import SwiftUI

public struct WrappedUITextField: UIViewRepresentable {

    @Binding var value: String
    var placeholder: String
    var fontSize: UInt32
    var foregroundColor: Color
    var backgroundColor: Color
    var keyboardType: UIKeyboardType
    var formatter: Formatter?

    var onBegin: (() -> Void)?
    var onEnd: (() -> Void)?

    public init(
        value: Binding<String>,
        placeholder: String,
        fontSize: UInt32 = 16,
        foregroundColor: Color = .black,
        backgroundColor: Color = .white,
        keyboardType: UIKeyboardType = .numberPad,
        formatter: Formatter?,
        onBegin: (() -> Void)? = nil,
        onEnd: (() -> Void)? = nil
    ) {
        self._value = value
        self.placeholder = placeholder
        self.fontSize = fontSize
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.keyboardType = keyboardType
        self.formatter = formatter
        self.onBegin = onBegin
        self.onEnd = onEnd
    }

    public func makeUIView(context: Self.Context) -> UITextField {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: CGFloat(self.fontSize))
        textField.placeholder = self.placeholder
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = .next
        textField.textColor = UIColor(foregroundColor)
        textField.clearButtonMode = .never
        textField.delegate = context.coordinator

        textField.text = self.formatter?.string(for: value)

        // Toolbar for keyboard
        let inputView = UIToolbar()
        inputView.sizeToFit()
        inputView.items = [
            .flexibleSpace(),
            UIBarButtonItem(
                title: "Done",
                style: UIBarButtonItem.Style.plain,
                target: context.coordinator,
                action: #selector(
                    context.coordinator.tappedDoneButton(_:)
                )
            )
        ]
        textField.inputAccessoryView = inputView
        context.coordinator.resign = { [weak textField] in textField?.resignFirstResponder() }

        return textField
    }

    public func updateUIView(_ uiView: UITextField, context: Self.Context) {
        let textField = uiView
        textField.placeholder = self.placeholder
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = .next
        textField.textColor = UIColor(foregroundColor)
        textField.clearButtonMode = .never
        context.coordinator.resign = { [weak textField] in textField?.resignFirstResponder() }

        let formatted = self.formatter?.string(for: textField.text)
        textField.text = formatted ?? textField.text
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            value: $value,
            formatter: self.formatter,
            onBegin: onBegin,
            onEnd: onEnd
        )
    }

    public class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var value: String

        var formatter: Formatter?
        var resign: (() -> Void)?
        var onBegin: (() -> Void)?
        var onEnd: (() -> Void)?

        init(
            value: Binding<String>,
            formatter: Formatter?,
            resign: (() -> Void)? = nil,
            onBegin: (() -> Void)? = nil,
            onEnd: (() -> Void)? = nil
        ) {
            self._value = value
            self.formatter = formatter
            self.resign = resign
            self.onBegin = onBegin
            self.onEnd = onEnd
        }

        public func textFieldDidBeginEditing(_ textField: UITextField) {
            onBegin?()
        }

        public func textFieldDidEndEditing(_ textField: UITextField) {
            onEnd?()
        }

        public func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {

            var changedFormattedText = textField.text ?? ""
            changedFormattedText = (changedFormattedText as NSString).replacingCharacters(in: range, with: string)

#if DEBUG
            print("Text should change - \(textField.text ?? "NIL") to \(changedFormattedText)")
#endif

            guard let formatter = self.formatter else {
                value = changedFormattedText
                return true
            }

            var result = String()
            return withUnsafeMutablePointer(to: &result) { mut in
                let object = AutoreleasingUnsafeMutablePointer<AnyObject?>(mut)

                if formatter.getObjectValue(object, for: changedFormattedText, errorDescription: nil) {

                    let newUnformattedText = object.pointee as? String ?? ""

                    #if DEBUG
                    print("Unformat - \(newUnformattedText)")
                    #endif

                    if let newFormattedText = formatter.string(for: object.pointee) {

                        let cursorLocation = textField.position(
                            from: textField.beginningOfDocument,
                            offset: range.location + string.count
                        )

                        textField.text = newFormattedText

                        if let cursorLocation = cursorLocation {
                            let textRange = textField.textRange(
                                from: cursorLocation,
                                to: cursorLocation
                            )
                            textField.selectedTextRange = textRange
                        }

                        value = newUnformattedText
                        return false
                    } else {
                        print("Could not format \(newUnformattedText)")
                    }
                } else {
                    print("Error formattting")
                }
                return false
            }
        }

        @objc public func tappedDoneButton(_ barButton: UIBarButtonItem) {
            resign?()
        }
    }
}

#if swift(>=5.9)

#Preview {

    var data = ""
    let bind = Binding {
        data
    } set: { value in
        data = value
    }

    return VStack {
        WrappedUITextField(
            value: bind,
            placeholder: "Card Number",
            fontSize: 16,
            foregroundColor: .black,
            backgroundColor: .white,
            keyboardType: .numberPad,
            formatter: CardNumberFormatter()
        )
        Spacer()
    }
}

#endif
