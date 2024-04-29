import Foundation

class ExpiryDateFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String else { return nil }
        guard string.isEmpty == false else { return string }
        guard string.trimmingCharacters(in: .whitespacesAndNewlines).allSatisfy({ $0.isNumber }) else { return nil }
        guard string.count <= 4 else { return nil }

        if string.count == 1,
           let number = Int(string) {
            if number > 1 {
                return "0" + string
            }
        }

        if string.count == 2,
           let number = Int(string) {
            if number > 12 {
                return nil
            }
        }

        if string.count > 2 {
            var result = string
            result.insert(" ", at: string.index(string.startIndex, offsetBy: 2))
            result.insert("/", at: string.index(string.startIndex, offsetBy: 2))
            result.insert(" ", at: string.index(string.startIndex, offsetBy: 2))
            return String(result.prefix(7))
        }

        return string
    }

    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        if let obj = obj {
            obj.pointee = string
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "/", with: "") as AnyObject
            return true
        }

        return false
    }
}
