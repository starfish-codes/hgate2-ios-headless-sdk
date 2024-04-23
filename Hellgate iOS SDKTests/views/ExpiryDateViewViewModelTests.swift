import SwiftUI
import XCTest
@testable import Hellgate_iOS_SDK

final class ExpiryDateViewViewModelTests: XCTestCase {

    private func viewModel() -> (ExpiryDateViewViewModel, DispatchQueue) {
        var state = ViewState(state: .blank)
        let binding = Binding {
            state
        } set: { newState in
            state = newState
        }

        let queue = DispatchQueue(label: "sync")

        var components = DateComponents()
        components.month = 1
        components.year = 2011

        let date = Calendar(identifier: .gregorian)
            .date(from: components) ?? .now

        return (ExpiryDateViewViewModel(
            viewState: binding,
            currentDate: date,
            queue: queue
        ),
                queue)
    }

    func test_Given_EmptyValue_When_Init_Then_StateBlank() {
        let (viewModel, _) = viewModel()

        XCTAssertEqual(viewModel.viewState.state, .blank)
    }

    func test_Given_EmptyValue_When_InputFutureDate_Then_StateComplete() {
        let (viewModel, queue) = viewModel()

        viewModel.value = "1299"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .complete)
        }
    }

    func test_Given_EmptyValue_When_InputPastDate_Then_StateComplete() {
        let (viewModel, queue) = viewModel()

        viewModel.value = "1210"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .invalid)
        }
    }

    func test_Given_EmptyValue_When_InputCurrentDate_Then_StateComplete() {
        let (viewModel, queue) = viewModel()

        viewModel.value = "0111"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .complete)
        }
    }

    func test_Given_EmptyValue_When_InputInvalidMonth_Then_StateIncomplete() {
        let (viewModel, queue) = viewModel()

        viewModel.value = "14"
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .incomplete)
        }
    }
}
