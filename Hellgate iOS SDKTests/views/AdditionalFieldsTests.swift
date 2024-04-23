import SwiftUI
import XCTest
@testable import Hellgate_iOS_SDK

final class AdditionalFieldsViewModelTests: XCTestCase {

    private func viewModel() -> (AdditionalFieldsViewModel, DispatchQueue) {
        var state = ViewState(state: .blank)
        let binding = Binding {
            state
        } set: { newState in
            state = newState
        }

        let queue = DispatchQueue(label: "sync")

        return (AdditionalFieldsViewModel(
            type: .CARDHOLDER_NAME,
            viewState: binding,
            queue: queue
        ),
                queue)
    }

    func test_Given_AdditionalFields_When_Init_Then_StateBlank() {
        let (viewModel, _) = viewModel()

        XCTAssertEqual(viewModel.viewState.state, .blank)
    }

    func test_Given_AdditionalFieldsEmpty_When_Init_Then_StateBlank() {
        let (viewModel, _) = viewModel()

        viewModel.value = ""

        XCTAssertEqual(viewModel.viewState.state, .blank)
    }

    func test_Given_AdditionalFields_When_SomeValue_Then_Complete() {
        let (viewModel, queue) = viewModel()

        viewModel.value = "12"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .complete)
        }
    }
}
