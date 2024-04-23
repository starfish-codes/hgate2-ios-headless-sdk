import SwiftUI
import XCTest
@testable import Hellgate_iOS_SDK

final class CardNumberViewTests: XCTestCase {

    private func viewModel() -> (CardNumberViewViewModel, DispatchQueue) {
        var state = ViewState(state: .blank)
        let binding = Binding {
            state
        } set: { newState in
            state = newState
        }

        let queue = DispatchQueue(label: "sync")

        return (CardNumberViewViewModel(
            viewState: binding,
            cardBrand: .unknown,
            queue: queue
        ),
                queue)
    }

    func test_Given_NoCardNumber_When_GetFontColor_Then_ReturnDefaultColor() throws {
        let (viewModel, queue) = viewModel()

        viewModel.value = ""

        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .blank)
            XCTAssertEqual(viewModel.color, Color.black)
        }
    }

    func test_Given_CompleteCardNumber_When_GetFontColor_Then_ReturnDefaultSuccessColor() throws {
        let (viewModel, queue) = viewModel()

        viewModel.value = "3900000000001235"

        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .complete)
            XCTAssertEqual(viewModel.color, Color.blue)
        }
    }

    func test_Given_InvalidCardNumber_When_GetFontColor_Then_ReturnDefaultSuccessColor() throws {
        let (viewModel, queue) = viewModel()

        viewModel.value = "3900000000001234"
        
        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .invalid)
            XCTAssertEqual(viewModel.color, Color.red)
        }
    }

    func test_Given_IncompleteCardNumber_When_GetState_Then_ReturnIncomplete() throws {
        let (viewModel, queue) = viewModel()

        viewModel.value = "3900000000001"

        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .incomplete)
        }
    }

    func test_Given_IncompleteCardNumberUnknownBrand_When_GetState_Then_ReturnIncomplete() throws {
        let (viewModel, queue) = viewModel()

        viewModel.value = "1234"

        queue.sync {
            XCTAssertEqual(viewModel.viewState.state, .incomplete)
        }
    }
}
