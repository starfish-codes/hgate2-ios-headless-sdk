# Hellgate iOS SDK

## Installation

The Hellgate iOS SDK is distributed via Cocoapods, Carthage and SPM.

### Cocoapods

Add the following line to your `Podfile`:

```Podfile
pod 'Hellgate-iOS-SDK'
```

### Carthage

1. Add the following line to your `Cartfile`:
```Cartfile
github "starfish-codes/hgate2-ios-headless-sdk"
```

2. Run in same directory as your `Cartfile`:
```sh
$ carthage update --use-xcframeworks
```
3. Add the built XCFrameworks to your project under "Frameworks and Libraries"

### Swift Package Manager

Add the package via Xcode from `https://github.com/starfish-codes/hgate2-ios-headless-sdk.git`

## Usage

### Import

```swift
import Hellgate-iOS-SDK
```

### UI Fields

Use the following views to create a card form:
```swift
// Card number field, validation state and which side should the card images appear
CardNumberView(viewState: $viewModel.cardNumberViewState, image: .leading)
    .border()

// Expiry date field, validation state
ExpiryDateField(viewState: $viewModel.expiryViewState)
    .border()

// CVC and CVV view with view state and max length either .cvc or .cvv
CvcView(viewState: $viewModel.cvcViewState, length: .cvc)
    .border()
```

Each field has a `ViewState` which looks somewhat like this:

```swift
public enum ComponentState: String {
    case complete
    case incomplete
    case blank
    case invalid
}

public struct ViewState {
    public let state: ComponentState
}
```

The `ViewStates` can help to determine how the user is progressing in filling out the fields.

### Hellgate

First we have to initialize a Hellgate session using the `sessionId` delivered from your backend.
```swift
let hellgate = await initHellgate(baseUrl: hellgateURL, sessionId: sessionId)
```

Next we need to get a card handler from the Hellgate session and then we can try and tokenize the card details based on the view states previously defined in the UI.

```swift
// First try to get a valid card handler
let cardHandlerResult = await hellgate.cardHandler()

if case let .success(handler) = cardHandlerResult {

    // Using the card handler and the previously defined view states
    // try and tokenize the card

    let tokenizeCardResult = await handler.tokenizeCard(
        cardNumberViewState,
        cvcViewState,
        expiryViewState,
        [:]
    )

    switch tokenizeCardResult {
    case let .success(data):
        // Results in a token id
        print(data.id)

    case let .failure(err):
        print(err.localizedDescription)
    }
}
```

## Development

### Linting

If `swiftlint` is installed then it will run during the build process.

### Code Coverage
- Minmimum code coverage is 60%
