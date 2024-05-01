public enum ComponentState {
    case complete
    case incomplete
    case blank
    case invalid
}

public struct ViewState {
    public let state: ComponentState

    let value: String

    public init(state: ComponentState) {
        self.state = state
        self.value = ""
    }

    init(state: ComponentState, value: String) {
        self.state = state
        self.value = value
    }
}
