import XCTest
import SwiftUI
@testable import Hellgate_iOS_SDK

final class WrappedUITextFieldTests: XCTestCase {

    func test_Given_Textfield_When_ReceiveBegin_Then_OnBeginCalled() throws {

        let exp = expectation(description: "Textfield did begin editing")

        let wrapped = WrappedUITextField(
            value: .constant(""),
            placeholder: "",
            formatter: CardNumberFormatter(),
            onBegin: {
                exp.fulfill()
            })

        let coordinator = wrapped.makeCoordinator()

        coordinator.textFieldDidBeginEditing(UITextField())

        wait(for: [exp], timeout: 1)
    }

    func test_Given_Textfield_When_ReceiveEnd_Then_OnEndCalled() throws {

        let exp = expectation(description: "Textfield did begin editing")

        let wrapped = WrappedUITextField(
            value: .constant(""),
            placeholder: "",
            formatter: CardNumberFormatter(),
            onEnd: {
                exp.fulfill()
            })

        let coordinator = wrapped.makeCoordinator()

        coordinator.textFieldDidEndEditing(UITextField())

        wait(for: [exp], timeout: 1)
    }

    func test_Given_Textfield_When_DonebuttonTapped_Then_OnResignCalled() throws {

        let exp = expectation(description: "Done button tapped")

        let wrapped = WrappedUITextField(
            value: .constant(""),
            placeholder: "",
            formatter: CardNumberFormatter()
        )

        let coordinator = wrapped.makeCoordinator()
        coordinator.resign = {
            exp.fulfill()
        }

        coordinator.tappedDoneButton(.init())

        wait(for: [exp], timeout: 1)
    }

    func test_Given_Textfield_When_ReceiveChanges_Then_UpdateValue() throws {
        var value = ""
        let valueBind = Binding {
            value
        } set: { newValue in
            value = newValue
        }

        let wrapped = WrappedUITextField(
            value: valueBind,
            placeholder: "",
            formatter: CardNumberFormatter()
        )

        let coordinator = wrapped.makeCoordinator()
        let textfield = UITextField()
        textfield.text = "123"

        _ = coordinator.textField(
            textfield,
            shouldChangeCharactersIn: NSRange(location: 0, length: 0),
            replacementString: "1"
        )

        XCTAssertEqual(value, "1123")
    }

}
