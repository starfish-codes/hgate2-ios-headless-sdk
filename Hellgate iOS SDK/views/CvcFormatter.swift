import Foundation

class CvcFormatter: Formatter {
    let maxLength: UInt

    init(maxLength: UInt) {
        self.maxLength = maxLength
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func string(for obj: Any?) -> String? {
        guard let string = obj as? String else { return nil }
        guard string.isEmpty == false else { return string }
        guard string.trimmingCharacters(in: .whitespacesAndNewlines).allSatisfy({ $0.isNumber }) else { return nil }
        guard string.count <= maxLength else { return nil }
        return string
    }

    override func getObjectValue(
        _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        if let obj = obj {
            obj.pointee = string as AnyObject
            return true
        }

        return false
    }
}
