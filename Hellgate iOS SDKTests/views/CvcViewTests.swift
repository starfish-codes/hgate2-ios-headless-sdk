import SwiftUI
import XCTest
@testable import Hellgate_iOS_SDK

final class CvcViewModelTests: XCTestCase {

    private func viewModel(length: Cvc) -> (CvcViewViewModel, DispatchQueue) {
        var state = ViewState(state: .blank)
        let binding = Binding {
            state
        } set: { newState in
            state = newState
        }

        let queue = DispatchQueue(label: "sync")

        return (CvcViewViewModel(
            viewState: binding,
            length: length,
            queue: queue
        ),
                queue)
    }

    func test_Given_Cvc_When_Init_Then_StateBlank() {
        let (viewModel, _) = viewModel(length: .cvc)

        XCTAssertEqual(viewModel.viewState.state, .blank)
    }

    func test_Given_Cvv_When_Init_Then_StateBlank() {
        let (viewModel, _) = viewModel(length: .cvv)

        XCTAssertEqual(viewModel.viewState.state, .blank)
    }

    func test_Given_Cvc_When_SomeValue_Then_Complete() {
        let (viewModel, queue) = viewModel(length: .cvc)

        viewModel.value = "12"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .incomplete)
        }
    }

    func test_Given_Cvv_When_SomeValue_Then_Complete() {
        let (viewModel, queue) = viewModel(length: .cvv)

        viewModel.value = "123"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .incomplete)
        }
    }

    func test_Given_Cvc_When_MaxInput_Then_Complete() {
        let (viewModel, queue) = viewModel(length: .cvc)

        viewModel.value = "123"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .complete)
        }
    }

    func test_Given_Cvv_When_MaxInput_Then_Complete() {
        let (viewModel, queue) = viewModel(length: .cvv)

        viewModel.value = "1234"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .complete)
        }
    }
}
