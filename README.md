# Hyperwallet UI SDK

[![Platforms](https://img.shields.io/cocoapods/p/HyperwalletUISDK.svg?)](https://cocoapods.org/pods/HyperwalletUISDK)
[![Build Status](https://travis-ci.org/hyperwallet/hyperwallet-ios-ui-sdk.svg?branch=master)](https://travis-ci.org/hyperwallet/hyperwallet-ios-ui-sdk)
[![Coverage Status](https://coveralls.io/repos/github/hyperwallet/hyperwallet-ios-ui-sdk/badge.svg?branch=master)](https://coveralls.io/github/hyperwallet/hyperwallet-ios-ui-sdk?branch=master)

[![CocoaPods](https://img.shields.io/cocoapods/v/HyperwalletUISDK.svg?color=blue)](https://cocoapods.org/pods/HyperwalletUISDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


Welcome to Hyperwallet's iOS UI SDK. This out-of-the-box library will help you create transfer methods in your iOS app, such as bank account, PayPal account, etc.

Note that this SDK is geared towards those who need both backend data and UI features. Please refer to [Hyperwallet iOS Core SDK](https://github.com/hyperwallet/hyperwallet-ios-sdk) if you decide to build your own UI.

## Prerequisites
* A Hyperwallet merchant account
* Set Up your server to manage the user's authentication process on the Hyperwallet platform. See the  [Authentication](#Authentication) section for more information.
* iOS 10.0+
* Xcode 10.2+
* Swift 5.0

## Dependencies

- [HyperwalletSDK 1.0.0-beta03](https://github.com/hyperwallet/hyperwallet-ios-sdk)

## Installation
Use [Carthage](https://github.com/Carthage/Carthage) or [CocoaPods](https://cocoapods.org/) to integrate to HyperwalletSDK.
### Carthage
Specify it in your Cartfile:
```ogdl
github "hyperwallet/hyperwallet-ios-ui-sdk" "1.0.0-beta03"
```

### CocoaPods
- Install HyperwalletUISDK framwork as a whole:
```ruby
pod 'HyperwalletUISDK', '~> 1.0.0-beta03'
```
- Install a specific framework:
```ruby
pod 'HyperwalletUISDK/TransferMethod', '~> 1.0.0-beta03'
```

## Initialization
After you're done installing the SDK, you need to initialize an instance in order to utilize core SDK functions. Also, you need to provide a HyperwalletAuthenticationTokenProvider object to retrieve an authentication token.

### Setup the UI Style
HyperwalletUISDK provides default themes for all the modules(e.g. TransferMethod, Receipt). If you import HyperwalletUISDK, in order to
apply all the default themes, firstly you will have to call ThemeManager.applyTheme which will apply the basic theme. Secondly, you need to apply
the themes for all the modules in HyperwalletUISDK.
For example:
```swift
...
import HyperwalletUISDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Optional - Define the HyperwalletUISDK on the `Theme` object. See the section `Customize the visual style`.

        // Set the default tint color
        window?.tintColor = Theme.tintColor
        // Avoid to display a black area during the view transaction in the UINavigationBar.
        window?.backgroundColor = Theme.ViewController.backgroundColor

        // Apply basic theme
        ThemeManager.applyTheme()
        // Apply TransferMethod theme
        ThemeManager.applyTransferMethodTheme()
        // Apply Receipt theme
        ThemeManager.applyReceiptTheme()
        return true
    }
}
```
You can also customize the default themes accoding to your needs. Please see customize the visual style for detail.

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
import Foundation
import HyperwalletSDK

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
The user can deactivate and add a new transfer method.
```swift
let coordinator = HyperwalletUI.shared.listTransferMethodCoordinator(parentController: self)
coordinator.navigate()
```

### Select a transfer method type available by country and currency
```swift
let coordinator = HyperwalletUI.shared.selectTransferMethodTypeCoordinator(parentController: self)
coordinator.navigate()
```

### Create a transfer method
The form fields are based on the country, currency, user's profile type, and transfer method type should be passed to this Controller to create a new Transfer Method for those values.
```swift
let country = ProcessInfo.processInfo.environment["COUNTRY"] // The 2 letter ISO 3166-1 country code.
let currency = ProcessInfo.processInfo.environment["CURRENCY"] // The 3 letter ISO 4217-1 currency code.
let accountType = ProcessInfo.processInfo.environment["ACCOUNT_TYPE"] // The profile type. Possible values - INDIVIDUAL, BUSINESS.
let profileType = ProcessInfo.processInfo.environment["PROFILE_TYPE"] // The transfer method type. Possible values - BANK_ACCOUNT, BANK_CARD, PAYPAL_ACCOUNT

let coordinator = HyperwalletUI.shared.addTransferMethodCoordinator(country, currency, profileType, accountType, parentController: self)
coordinator.navigate()
```

### Lists the user's receipts
```swift
let coordinator = HyperwalletUI.shared.listUserReceiptCoordinator(parentController: self)
coordinator.navigate()
```

### Lists the prepaid card's receipts
```swift
let prepaidCardToken = Bundle.main.infoDictionary!["PREPAID_CARD_TOKEN"] as! String
let coordinator = HyperwalletUI.shared.listPrepaidCardReceiptCoordinator(parentController: self, prepaidCardToken: prepaidCardToken)
coordinator.navigate()
```


## NotificationCenter Events

| Notification name | Description |
|:-----------------|:-----------|
| Notification.Name.transferMethodAdded | Posted when a new transfer method (bank account, bank card, PayPal account, prepaid card, paper check) has been created. |
| Notification.Name.transferMethodDeactivated | Posted when a transfer method (bank account, bank card, PayPal account, prepaid card, paper check) has been deactivated. |

When an object adds itself as an observer, it specifies which notifications it should receive. An object may, therefore, call this method several times in order to register itself as an observer for several different notifications.

### How to use `Notification.Name.transferMethodAdded`

```swift
import HyperwalletSDK
import HyperwalletUISDK

override public func viewDidLoad() {
    super.viewDidLoad()
    ...
    NotificationCenter.default.addObserver(self,
                                        selector: #selector(didCreateNewTransferMethodNotification(notification:)),
                                        name: Notification.Name.transferMethodAdded, object: nil)
}

@objc func didCreateNewTransferMethodNotification(notification: Notification) {
    if let transferMethod = notification.userInfo![UserInfo.transferMethod] as? HyperwalletTransferMethod {
        // A new transfer method has been created
    }
}
```

### How to use `Notification.Name.transferMethodDeactivated`

```swift
import HyperwalletSDK
import HyperwalletUISDK

override public func viewDidLoad() {
    super.viewDidLoad()
    ...
    NotificationCenter.default.addObserver(self,
                                        selector: #selector(didTransferMethodDeactivatedNotification(notification:)),
                                        name: Notification.Name.transferMethodDeactivated, object: nil)
}

@objc func didTransferMethodDeactivatedNotification(notification: Notification) {
    if let statusTransition = notification.userInfo![UserInfo.statusTransition] as? HyperwalletStatusTransition {
        // A transfer method has been deactived.
        print(statusTransition.fromStatus)
        print(statusTransition.toStatus)
    }
}
```

## Customize the visual style
UI SDK is designed to make the process of the UI Styling as simple as possible. The `Theme.swift` object is responsible for UI customization.

Use the application(_:didFinishLaunchingWithOptions:) method to customize the user interface of SDK.

On the Theme is possible to customize the properties:

| Property | Default Value | Description |
|:--------|:-------------|:-----------|
| `Theme.themeColor` | `#00AFD0` | The primary color |
| `Theme.tintColor` | `UIColor.white` | The tint color |
| `Theme.Label.color` | `#FFFFFF` | The primary color |
| `Theme.Label.errorColor` | `#FF3B30` | The color to highlight errors|
| `Theme.Label.subTitleColor` | `#666666` | The subtitle color |
| `Theme.Label.textColor` | `#8e8e93` | The text color |
| `Theme.Label.titleFont` | `UIFont.preferredFont(forTextStyle: .headline)` | The title font style |
| `Theme.Label.bodyFont` | `UIFont.preferredFont(forTextStyle: .body)` | The body font style |
| `Theme.Label.bodyFontMedium` | `UIFont.systemFont(ofSize: bodyFont.pointSize, weight: .medium)` | The body font style with medium weight |
| `Theme.Label.captionOne` | `UIFont.preferredFont(forTextStyle: .caption1)` | The caption one font style |
| `Theme.Label.captionOneMedium` | `UIFont.systemFont(ofSize: captionOne.pointSize, weight: .medium)` | The caption one font style with medium weight |
| `Theme.Label.footnoteFont` | `UIFont.preferredFont(forTextStyle: .footnote)` | The footnote font style |
| `Theme.NavigationBar.barStyle` | `UIBarStyle.black` | The `UINavigationBar` bar style. |
| `Theme.NavigationBar.isTranslucent` | `false`	| Sets the opaque background color. When the value is false the navigation bar will appear with a solid color. |
| `Theme.Button.color` | `Theme.themeColor` | The button primary color |
| `Theme.Text.color` | `UIColor.black` | The text primary color |
| `Theme.SearchBar.textFieldTintColor` | `Theme.tintColor` | The `UITextField` tint color |
| `Theme.SearchBar.textFieldBackgroundColor` | `#28BBD7` | The `UITextField` background color |
| `Theme.Cell.height` | `88` | The `UITableViewViewCell` height for the List transfer method items and the Select transfer method type items. |
| `Theme.Cell.rowHeight` | `44`	| The common `UITableViewViewCell` height. |
| `Theme.Cell.headerHeight` | `16` | The Select transfer method type items header height. |
| `Theme.Cell.separatorInsetZero` | `UIEdgeInsets.zero` | The separator inset with edge insets struct whose top, left, bottom, and right fields are all set to 0. |
| `Theme.Cell.separatorInset16` | `UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)` | The separator inset with the left edge set to 16. |
| `Theme.Cell.separatorInset70` | `UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)` | The separator inset with the left edge set to 70. |
| `Theme.Icon.size` | `20` | The icon size. |
| `Theme.Icon.color` | `Theme.themeColor` | The icon primary color |
| `Theme.Icon.backgroundColor` | `#E5F7FA` | The icon background color |
| `Theme.ViewController.backgroundColor` | `#EFEFF4` | The `UIViewController` background color. |
| `Theme.SpinnerView.activityIndicatorViewStyle` | `UIActivityIndicatorView.Style.whiteLarge` | The `UIActivityIndicatorView` style. |
| `Theme.SpinnerView.activityIndicatorViewColor` | `Theme.themeColor` | The `UIActivityIndicatorView` color. |
| `Theme.SpinnerView.backgroundColor` | `UIColor.clear` | The background color |
| `Theme.ProcessingView.backgroundColor` | `UIColor.black.withAlphaComponent(0.85)` | The background color. |
| `Theme.ProcessingView.stateLabelColor` | `UIColor.white` | The state label color. |

Example to define the light theme code in class AppDelegate:
```swift
import HyperwalletUISDK
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Override point for customization after application launch.

        Theme.themeColor = UIColor.white
        Theme.tintColor = UIColor(red: 3 / 255, green: 124 / 255, blue: 1, alpha: 1) //blue
        Theme.Button.color = Theme.tintColor
        Theme.Icon.color = Theme.tintColor
        Theme.Icon.backgroundColor = UIColor(red: 219 / 255, green: 241 / 255, blue: 1, alpha: 1) // Light blue
        Theme.SpinnerView.activityIndicatorViewColor = Theme.tintColor

        // Set the default tint color
        window?.tintColor = Theme.tintColor
        // Avoid to display a black area during the view transaction in the UINavigationBar.
        window?.backgroundColor = Theme.ViewController.backgroundColor

        ThemeManager.applyTheme()
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

## Error Handling
In Hyperwallet UI SDK, we categorized HyperwalletException into three groups, which are input errors (business errors), network errors and unexpected errors.

### Unexpected Error
Once an unexpected error happened, an AlertView that only contains the `OK` button will be shown in the UI.

### Network Error
Network errors happen due to connectivity issues, such as poor-quality network connection, the request timed out from the server side, etc. Once a network error happened, an AlertView that contains a `Cancel` and a `Try Again` buttons will be shown in the UI.

### Business Errors
Business errors happen when the Hyperwallet platform has found invalid information or some business restriction related to the data has been submitted and require some action from the user.

## License
The Hyperwallet iOS SDK is open source and available under the [MIT](https://github.com/hyperwallet/hyperwallet-ios-ui-sdk/blob/master/LICENSE) license
