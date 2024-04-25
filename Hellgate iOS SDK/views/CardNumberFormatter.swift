import Foundation

class CardNumberFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String else { return nil }
        guard string.isEmpty == false else { return string }
        guard string.trimmingCharacters(in: .whitespacesAndNewlines).allSatisfy({ $0.isNumber }) else { return nil }

        var pattern = [4, 8, 12]

        if string.count == 14 || string.count == 15 {
            pattern = [4, 10]
        }

        var result = string
        for index in pattern.reversed() where index < result.count {
            result.insert(" ", at: result.index(result.startIndex, offsetBy: index))
        }

        return result
    }

    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        if let obj = obj {
            obj.pointee = string.replacingOccurrences(of: " ", with: "") as AnyObject
            return true
        }

        return false
    }
}
