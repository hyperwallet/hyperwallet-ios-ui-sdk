# Hyperwallet UI SDK

[![Platforms](https://img.shields.io/cocoapods/p/HyperwalletUISDK.svg?)](https://cocoapods.org/pods/HyperwalletUISDK)
[![Build Status](https://travis-ci.com/hyperwallet/hyperwallet-ios-ui-sdk.svg?branch=master)](https://travis-ci.com/hyperwallet/hyperwallet-ios-ui-sdk)
[![Coverage Status](https://coveralls.io/repos/github/hyperwallet/hyperwallet-ios-ui-sdk/badge.svg?branch=master)](https://coveralls.io/github/hyperwallet/hyperwallet-ios-ui-sdk?branch=master)

[![CocoaPods](https://img.shields.io/cocoapods/v/HyperwalletUISDK.svg?color=blue)](https://cocoapods.org/pods/HyperwalletUISDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

NOTE: This is a beta product available for use in your mobile app. If you are interested in using this product, please notify your Relationship Manager and / or Project Manager to support you during the integration process.

Welcome to Hyperwallet's iOS UI SDK. This out-of-the-box library will help you create transfer methods in your iOS app, such as bank account, PayPal account, etc.

Note that this SDK is geared towards those who need both backend data and UI features. Please refer to [Hyperwallet iOS Core SDK](https://github.com/hyperwallet/hyperwallet-ios-sdk) if you decide to build your own UI.

## Prerequisites
* A Hyperwallet merchant account
* Set Up your server to manage the user's authentication process on the Hyperwallet platform. See the  [Authentication](#Authentication) section for more information.
* iOS 10.0+
* Xcode 10.2+
* Swift 5.0

## Dependencies

- [HyperwalletSDK 1.0.0-beta11](https://github.com/hyperwallet/hyperwallet-ios-sdk)

## Installation
Use [Carthage](https://github.com/Carthage/Carthage) or [CocoaPods](https://cocoapods.org/) to integrate to HyperwalletSDK.
Currently, the following modules are available:
* TransferMethod - List, add or remove Transfer Methods
* Transfer - Create a transfer from user account or prepaid card to available accounts for the user
* Receipt - List user/prepaid card receipts
Adding one or more of these frameworks allows users to explore the particular function. If every feature is required, all the frameworks should be added
### Carthage
Specify it in your Cartfile:
```ogdl
github "hyperwallet/hyperwallet-ios-ui-sdk" "1.0.0-beta11"
```
Add desired modules using the `Linked Frameworks and Libraries` option to make them available in the app.
Use `import <module-name>` to add the dependency within a file

### CocoaPods
- Install a specific framework (install one or more frameworks based on your requirement)
```ruby
pod "HyperwalletUISDK/TransferMethod", "1.0.0-beta11"
pod "HyperwalletUISDK/Transfer", "1.0.0-beta11"
pod "HyperwalletUISDK/Receipt", "1.0.0-beta11"
```
- To install all available modules (TransferMethod, Transfer, Receipt)
```ruby
pod 'HyperwalletUISDK', '~> 1.0.0-beta11'
```
Use `import HyperwalletUISDK` to add the dependency within a file.

## Initialization
After you're done installing the SDK, you need to initialize an instance in order to utilize core SDK functions. Also, you need to provide a HyperwalletAuthenticationTokenProvider object to retrieve an authentication token.

### Setup the UI Style
HyperwalletUISDK provides default themes for all the modules(e.g. TransferMethod, Receipt). If you import HyperwalletUISDK, in order to
apply the default theme, you will have to call `ThemeManager.applyTheme()` which will apply the basic theme to ProcessingView and SpinnerView. If you want Hyperwallet custom theme for UINavigationBar then add `ThemeManager.applyToUINavigationBar()`
For example:
```swift
...
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Optional - Define the HyperwalletUISDK on the `Theme` object. See the section `Customize the visual style`.

        // Set the default tint color
        window?.tintColor = .systemBlue
        // Avoid to display a black area during the view transaction in the UINavigationBar.
        window?.backgroundColor = Theme.UITableViewController.backgroundColor

        // Apply basic theme
        ThemeManager.applyTheme()
        return true
    }
}
```
You can also customize the default themes according to your needs. Please see [customize the visual style](#Customize the visual style) for detail.

### Setup the authentication
Add in the header:
```swift
import HyperwalletUISDK
```
Initialize the `HyperwalletUISDK` with a `HyperwalletAuthenticationTokenProvider` implementation instance:
```swift
HyperwalletUI.setup(_ :HyperwalletAuthenticationTokenProvider)
```

## Authentication
Your server side should be able to send a POST request to Hyperwallet endpoint `/rest/v3/users/{user-token}/authentication-token` to retrieve an [authentication token](https://jwt.io/).
Then, you need to provide a class (an authentication provider) which implements HyperwalletAuthenticationTokenProvider to retrieve an authentication token from your server.

Example implementation using the  `URLRequest` from Swift  Foundation :
```swift
public struct AuthenticationTokenProviders: HyperwalletAuthenticationTokenProvider {
    private let url = URL(string: "http://your/server/to/retrieve/authenticationToken")!

    public func retrieveAuthenticationToken(
        completionHandler: @escaping HyperwalletAuthenticationTokenProvider.CompletionHandler) {

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let defaultSession = URLSession(configuration: .default)
        let task = defaultSession.dataTask(with: request) {(data, response, error) in
            DispatchQueue.main.async {
                guard let data = data,
                    let clientToken = String(data: data, encoding: .utf8),
                    let response = response as? HTTPURLResponse else {
                        completionHandler(nil, HyperwalletAuthenticationErrorType.unexpected(error?.localizedDescription ??
                        "authentication token cannot be retrieved"))
                        return
                }

                switch response.statusCode {
                    case 200 ..< 300:
                        completionHandler(clientToken, nil)

                    default:
                        completionHandler(nil, HyperwalletAuthenticationErrorType
                            .unexpected("authentication token cannot be retrieved"))
                }
            }
        }
        task.resume()
    }
}
```
## Usage
The functions in the UI SDK are available to use once the authentication is done.

### The user's transfer methods (bank account, bank card, PayPal account, prepaid card, paper check)

Add in the header:
```swift
import HyperwalletSDK
import HyperwalletUISDK
```

### Lists the user's transfer methods
The user can deactivate or add a new transfer method.
```swift
let coordinator = HyperwalletUI.shared.listTransferMethodCoordinator(parentController: self)
coordinator.navigate()
```

### Select a transfer method type available by country and currency
```swift
let coordinator = HyperwalletUI.shared.selectTransferMethodTypeCoordinator(parentController: self)
coordinator.navigate()
```
Also add following method to dismiss the presented view and perform any action based on the transfer method created.
```swift
override public func didFlowComplete(with response: Any) {
    if let transferMethod = response as? HyperwalletTransferMethod {
    navigationController?.popViewController(animated: false)
    }
}
```


### Create a transfer method
The form fields are based on the country, currency, user's profile type, and transfer method type. These values should be passed to this method to create a new Transfer Method.
```swift
let coordinator = HyperwalletUI.shared.addTransferMethodCoordinator(
    "US", // The 2 letter ISO 3166-1 country code.
    "USD", // The 3 letter ISO 4217-1 currency code.
    "INDIVIDUAL", // The profile type. Possible values - INDIVIDUAL, BUSINESS.
    "BANK_ACCOUNT", // The transfer method type. Possible values - BANK_ACCOUNT, BANK_CARD, PAYPAL_ACCOUNT
    parentController: self)
coordinator.navigate()
```
Also add following method to dismiss the presented view on successful creation of transfer method and perform any action based on the transfer method created.
```swift
override public func didFlowComplete(with response: Any) {
    if let transferMethod = response as? HyperwalletTransferMethod {
    navigationController?.popViewController(animated: false)
    }
}
```

### Update a transfer method
```swift
let coordinator = HyperwalletUI.shared.updateTransferMethodCoordinator(
    "your-transfer-method-token", // The transfer method token
    parentController: self)
coordinator.navigate()
```

### Lists the user's receipts
```swift
let coordinator = HyperwalletUI.shared.listUserReceiptCoordinator(parentController: self)
coordinator.navigate()
```

### Lists the prepaid card's receipts
```swift
let coordinator = HyperwalletUI.shared.listPrepaidCardReceiptCoordinator(parentController: self, prepaidCardToken: "your-prepaid-card-token")
coordinator.navigate()
```

### Lists receipts from all available sources
```swift
let coordinator = HyperwalletUI.shared.listAllAvailableSourcesReceiptCoordinator(parentController: self)
coordinator.navigate()
```

### Make a new transfer from user's account
To add new Transfer Method from Transfer module, TransferMethod module needs to be added as a dependency in the app. If TransferMethod module is not added, users will not be able to add a new Transfer Method inside the Transfer flow.
```swift
let clientTransferId = UUID().uuidString.lowercased()
let coordinator = HyperwalletUI.shared
            .createTransferFromUserCoordinator(clientTransferId: clientTransferId, parentController: self)
coordinator.navigate()
```
Also add following method to dismiss the presented view on successful creation of transfer and perform any action based on the transfer created.
```swift
override public func didFlowComplete(with response: Any) {
    if let statusTransition = response as? HyperwalletStatusTransition, let transition = statusTransition.transition {
        if transition == HyperwalletStatusTransition.Status.scheduled {
            navigationController?.popViewController(animated: false)
        }
    }
}
```

### Make a new transfer from prepaid card
```swift
let clientTransferId = UUID().uuidString.lowercased()
let coordinator = HyperwalletUI.shared
            .createTransferFromPrepaidCardCoordinator(clientTransferId: clientTransferId,
                                                      sourceToken: "your-prepaid-card-token",
                                                      parentController: self)
coordinator.navigate()
```
Also add following method to dismiss the presented view on successful creation of transfer and perform any action based on the transfer created.
```swift
override public func didFlowComplete(with response: Any) {
    if let statusTransition = response as? HyperwalletStatusTransition, let transition = statusTransition.transition {
        if transition == HyperwalletStatusTransition.Status.scheduled {
            navigationController?.popViewController(animated: false)
        }
    }
}
```

### Display all the available sources to make a new transfer from. User can then select the transfer from source and make a new tansfer from that source
```swift
let clientTransferId = UUID().uuidString.lowercased()
let coordinator = HyperwalletUI.shared
            .createTransferFromAllAvailableSourcesCoordinator(clientTransferId: clientTransferId,
                                                              parentController: self)
coordinator.navigate()
```
Also add following method to dismiss the presented view on successful creation of transfer and perform any action based on the transfer created.
```swift
override public func didFlowComplete(with response: Any) {
    if let statusTransition = response as? HyperwalletStatusTransition, let transition = statusTransition.transition {
        if transition == HyperwalletStatusTransition.Status.scheduled {
            navigationController?.popViewController(animated: false)
        }
    }
}
```


## NotificationCenter Events

| Notification name | Description |
|:-----------------|:-----------|
| Notification.Name.transferMethodAdded | Posted when a new transfer method (bank account, bank card, PayPal account, prepaid card, paper check) has been created. |
| Notification.Name.transferMethodDeactivated | Posted when a transfer method (bank account, bank card, PayPal account, prepaid card, paper check) has been deactivated. |
| Notification.Name.transferCreated | Posted when a transfer of funds has been created. |
| Notification.Name.transferScheduled | Posted when a transfer of funds has been scheduled. |
| Notification.Name.authenticationError | Posted when SDK is unable to fetch new authentication token from client implementation. Client can choose to close the app/ logout/ navigate to some other screen when this notification is received. |

When an object adds itself as an observer, it specifies which notifications it should receive. An object may, therefore, call this method several times in order to register itself as an observer for several different notifications.

### How to use `Notification.Name.transferMethodAdded`

```swift
override public func viewDidLoad() {
    super.viewDidLoad()
    ...
    NotificationCenter.default.addObserver(self,
                                        selector: #selector(didCreateNewTransferMethodNotification(notification:)),
                                        name: Notification.Name.transferMethodAdded, object: nil)
}

@objc func didCreateNewTransferMethodNotification(notification: Notification) {
    if let transferMethod = notification.userInfo![UserInfo.transferMethodAdded] as? HyperwalletTransferMethod {
        // A new transfer method has been created
    }
}
```

### How to use `Notification.Name.transferMethodDeactivated`

```swift
override public func viewDidLoad() {
    super.viewDidLoad()
    ...
    NotificationCenter.default.addObserver(self,
                                        selector: #selector(didTransferMethodDeactivatedNotification(notification:)),
                                        name: Notification.Name.transferMethodDeactivated, object: nil)
}

@objc func didTransferMethodDeactivatedNotification(notification: Notification) {
    if let statusTransition = notification.userInfo![UserInfo.transferMethodDeactivated] as? HyperwalletStatusTransition {
        // A transfer method has been deactivated.
    }
}
```

### How to use `Notification.Name.transferCreated`

```swift
override public func viewDidLoad() {
    super.viewDidLoad()
    ...
    NotificationCenter.default.addObserver(self,
                                        selector: #selector(didTransferCreatedNotification(notification:)),
                                        name: Notification.Name.transferCreated, object: nil)
}

@objc func didTransferCreatedNotification(notification: Notification) {
    if let transfer = notification.userInfo![UserInfo.transferCreated] as? HyperwalletTransfer {
        // A transfer has been created.
    }
}
```

### How to use `Notification.Name.transferScheduled`

```swift
override public func viewDidLoad() {
    super.viewDidLoad()
    ...
    NotificationCenter.default.addObserver(self,
                                        selector: #selector(didTransferScheduledNotification(notification:)),
                                        name: Notification.Name.transferScheduled, object: nil)
}

@objc func didTransferScheduledNotification(notification: Notification) {
    if let statusTransition = notification.userInfo![UserInfo.transferScheduled] as? HyperwalletStatusTransition {
        // A transfer has been scheduled.
    }
}
```

### How to use `Notification.Name.authenticationError`

```swift
override public func viewDidLoad() {
super.viewDidLoad()
...
NotificationCenter.default.addObserver(self,
selector: #selector(didAuthenticationErrorOccur(notification:)),
name: Notification.Name.authenticationError, object: nil)
}

@objc func didAuthenticationErrorOccur(notification: Notification) {
// Logout/ navigate to any other screen
}
```

## Customize the visual style
UI SDK is designed to make the process of the UI Styling as simple as possible. The `Theme.swift` object is responsible for UI customization.

Use the application(_:didFinishLaunchingWithOptions:) method to customize the user interface of SDK.

On the Theme is possible to customize the properties:

| Property | Default Value | Description |
|:--------|:-------------|:-----------|
| `Theme.themeColor` | `0x00AFD0` | The main color |
| `Theme.tintColor` | `UIColor.white` | The tint color |
| `Theme.Label.color` | `UIColor(rgb: 0x2C2E2F)` | The label primary color |
| `Theme.Label.errorColor` | `0xFF3B30` | The color to highlight errors|
| `Theme.Label.subtitleColor` | `UIColor(rgb: 0x3c3c43, alpha: 0.6)` | The subtitle color |
| `Theme.Label.textColor` | `0x8e8e93` | The text color |
| `Theme.Label.titleFont` | `UIFont.preferredFont(forTextStyle: .body)` | The title font style |
| `Theme.Label.subtitleFont` | `UIFont.preferredFont(forTextStyle: .subheadline)` | The caption one font style |
| `Theme.Label.footnoteFont` | `UIFont.preferredFont(forTextStyle: .footnote)` | The footnote font style |
| `Theme.NavigationBar.barStyle` | `UIBarStyle.default` | The `UINavigationBar` bar style. |
| `Theme.NavigationBar.isTranslucent` | `false`	| Sets the opaque background color |
| `Theme.NavigationBar.shadowColor` | `UIColor.clear`	| The color of NavigationBar shadow |
| `Theme.NavigationBar.largeTitleColor` | `UIColor.white`    | The UINavigationBar large title color |
| `Theme.NavigationBar.titleColor` | `UIColor.white`    | The UINavigationBar title color |
| `Theme.NavigationBar.backButtonColor` | `UIColor.white`    | The UINavigationBar Back Button color |
| `Theme.NavigationBar.largeTitleFont` | `UIFont.preferredFont(forTextStyle: .largeTitle)`    | The UINavigationBar large title font |
| `Theme.NavigationBar.titleFont` | `UIFont.preferredFont(forTextStyle: .body)`    | The UINavigationBar title font |
| `Theme.Button.color` | `UIColor(rgb: 0xFFFFFF)` | The button primary color |
| `Theme.Button.linkColor` | `Theme.themeColor` | The button link color |
| `Theme.Button.font` | `Theme.Label.bodyFont` | The button font |
| `Theme.Button.linkFont` | `Theme.Label.titleFont` | The link button font |
| `Theme.Button.backgroundColor` | `Theme.themeColor` | The button background color |
| `Theme.Text.font` | `UIFont.preferredFont(forTextStyle: .body)` | The text font style |
| `Theme.Text.labelFont` | `Theme.Label.titleFont` | The text  label font style |
| `Theme.Text.color` | `Theme.Label.color` | The text primary color |
| `Theme.Text.labelColor` | `Theme.Label.color` | The text label primary color |
| `Theme.Text.disabledColor` | `Theme.Label.textColor` | The text disabled color |
| `Theme.Cell.smallHeight` | `61` | The common ``UITableViewCell`` height. |
| `Theme.Cell.height` | `80` | The common ``UITableViewCell`` height. |
| `Theme.Cell.largeHeight` | `88` | The `UITableViewCell` height for the List transfer method items and the Select transfer method type items. |
| `Theme.Cell.headerHeight` | `37` | The Select transfer method type items header height. |
| `Theme.Cell.dividerHeight` | `8` | The divider `UITableViewCell` height. |
| `Theme.Cell.separatorColor` | `UIColor(rgb: 0x3c3c43, alpha: 0.29)` | The `UITableViewCell` separator color. |
| `Theme.Cell.tintColor` | `UIColor.white` | The `UITableViewCell` tint color. |
| `Theme.Icon.size` | `30` | The icon font size |
| `Theme.Icon.frame` | `CGSize(width: 30, height: 30)` | The icon frame |
| `Theme.Icon.primaryColor` | `Theme.themeColor` | The icon primary color |
| `Theme.Icon.creditColor` | `Amount.creditColor` | The icon credit color |
| `Theme.Icon.debitColor` | `Amount.debitColor` | The icon debit color |
| `Theme.Amount.creditColor` | `UIColor(rgb: 0x299976)` | The credit color |
| `Theme.Amount.debitColor` | `Theme.Label.color` | The debit color |
| `Theme.ViewController.backgroundColor` | `UIColor.white` | The `UIViewController` background color. |
| `Theme.SpinnerView.activityIndicatorViewStyle` | `UIActivityIndicatorView.Style.whiteLarge` | The `UIActivityIndicatorView` style. |
| `Theme.SpinnerView.activityIndicatorViewColor` | `Theme.themeColor` | The `UIActivityIndicatorView` color. |
| `Theme.SpinnerView.backgroundColor` | `UIColor.clear` | The background color |
| `Theme.ProcessingView.backgroundColor` | `UIColor.black.withAlphaComponent(0.85)` | The background color. |
| `Theme.ProcessingView.stateLabelColor` | `UIColor.white` | The state label color. |

Example to define the light theme code in class AppDelegate:
```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.

        ThemeManager.applyWhiteTheme()
        // Set the default tint color
        window?.tintColor = .systemBlue
        // Avoid to display a black area during the view transaction in the UINavigationBar.
        window?.backgroundColor = Theme.UITableViewController.backgroundColor

        return true
    }
}
```

Example to customize the label colors:
```swift
...
/// Labels
Theme.Label.color = UIColor(red: 252 / 255, green: 67 / 255, blue: 77 / 255, alpha: 1)
Theme.Label.subTitleColor = UIColor(red: 19 / 255, green: 165 / 255, blue: 185 / 255, alpha: 1)
Theme.Label.textColor = UIColor(red: 0 / 255, green: 45 / 255, blue: 67 / 255, alpha: 1)
Theme.Label.errorColor = .red
```

Note: If you do not use `ThemeManager.applyToUINavigationBar()`, then any changes done to Theme.NavigationBar.xxx will not be reflected.

## Error Handling
In Hyperwallet UI SDK, we categorized HyperwalletException into three groups, which are input errors (business errors), network errors and unexpected errors.

### Unexpected Error
Once an unexpected error occurs, an AlertView that only contains the `OK` button will be shown in the UI.

### Network Error
Network errors occurs due to connectivity issues, such as poor-quality network connection, the request timed out from the server side, etc. Once a network error happened, an AlertView that contains a `Cancel` and a `Try Again` buttons will be shown in the UI.

### Business Errors
Business errors occurs when the Hyperwallet platform has found invalid information or some business restriction related to the data has been submitted and require some action from the user.

### Authentication Error
Authentication error occurs when the Hyperwallet SDK is not able to fetch the authentication token from the client implementation.

## License
The Hyperwallet iOS SDK is open source and available under the [MIT](https://github.com/hyperwallet/hyperwallet-ios-ui-sdk/blob/master/LICENSE) license
