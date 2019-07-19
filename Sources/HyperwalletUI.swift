//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import HyperwalletSDK

/// Class responsible for initializing the Hyperwallet UI SDK. It contains methods to interact with the controllers
/// used to interact with the Hyperwallet platform
@objcMembers public final class HyperwalletUI: NSObject {
    private static var instance: HyperwalletUI?

    /// Returns the previously initialized instance of the Hyperwallet UI SDK interface object
    public static var shared: HyperwalletUI {
        guard let instance = instance else {
            fatalError("Call HyperwalletUI.setup(_:) before accessing HyperwalletUI.shared")
        }
        return instance
    }

    /// Creates a new instance of the Hyperwallet UI SDK interface object. If a previously created instance exists,
    /// it will be replaced.
    ///
    /// - Parameter provider: a provider of Hyperwallet authentication tokens.
    public class func setup(_ provider: HyperwalletAuthenticationTokenProvider) {
        instance = HyperwalletUI(provider)
    }

    /// Lists the user's transfer methods (bank account, bank card, PayPal account, prepaid card, paper check).
    ///
    /// The user can deactivate and add a new transfer method.
    ///
    /// - Returns: An instance of `listTransferMethodTableViewController`
    public func listTransferMethodTableViewController() -> ListTransferMethodTableViewController {
        return ListTransferMethodTableViewController()
    }

    /// Lists the user's transactions.
    ///
    ///
    /// - Returns: An instance of `ListReceiptTableViewController`
    public func listUserReceiptTableViewController() -> ListReceiptTableViewController {
        return ListReceiptTableViewController()
    }

    /// Lists the user's prepaid card transactions.
    ///
    /// - Parameter prepaidCardToken: prepaid card token for which transactions are requested
    /// - Returns: An instance of `ListReceiptTableViewController`
    public func listPrepaidCardReceiptTableViewController(_ prepaidCardToken: String)
        -> ListReceiptTableViewController {
        return ListReceiptTableViewController(prepaidCardToken: prepaidCardToken)
    }
    /// Lists all transfer method types available based on the country, currency and profile type to create a new
    /// transfer method (bank account, bank card, PayPal account, prepaid card, paper check).
    ///
    /// - Returns: An instance of `SelectTransferMethodTypeTableViewController`
    public func selectTransferMethodTypeTableViewController() -> SelectTransferMethodTypeTableViewController {
        return SelectTransferMethodTypeTableViewController()
    }

    /// Controller to create a new transfer method.
    ///
    /// The form fields are based on the country, currency, user's profile type and transfer method type should be
    /// passed to this Controller to create new Transfer Method for those values.
    ///
    /// - Parameters:
    ///   - country: The 2 letter ISO 3166-1 country code.
    ///   - currency: The 3 letter ISO 4217-1 currency code.
    ///   - profileType: The profile type. Possible values - INDIVIDUAL, BUSINESS.
    ///   - transferMethodTypeCode: The transfer method type. Possible values - BANK_ACCOUNT, BANK_CARD.
    /// - Returns: An instance of `AddTransferMethodTableViewController`
    public func addTransferMethodTableViewController(
        _ country: String,
        _ currency: String,
        _ profileType: String,
        _ transferMethodTypeCode: String) -> AddTransferMethodTableViewController {
        return AddTransferMethodTableViewController(country, currency, profileType, transferMethodTypeCode)
    }

    private init(_ provider: HyperwalletAuthenticationTokenProvider) {
        Hyperwallet.setup(provider)
    }
}
