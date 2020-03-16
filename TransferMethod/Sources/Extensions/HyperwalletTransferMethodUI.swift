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

#if !COCOAPODS
import Common
import TransferMethodRepository
#endif

/// The HyperwalletUI extension
public extension HyperwalletUI {
    /// Clears TransferMethodRepositoryFactory instance.
    static func transferMethodUIClearInstance() {
        TransferMethodRepositoryFactory.clearInstance()
    }

    /// Lists the user's transfer methods (bank account, bank card, PayPal account, prepaid card, paper check).
    ///
    /// The user can deactivate and add a new transfer method.
    ///
    /// - Returns: An instance of `ListTransferMethodsCoordinator`
    func listTransferMethodCoordinator(parentController: UIViewController) ->
        ListTransferMethodsCoordinator {
            let coordinator = ListTransferMethodsCoordinator()
            coordinator.start(parentController: parentController)
            return coordinator
    }

    /// Lists all transfer method types available based on the country, currency and profile type to create a new
    /// transfer method (bank account, bank card, PayPal account, prepaid card, paper check).
    ///
    /// - Parameter forceUpdateData: Forces to refresh the cached data.
    /// - Returns: An instance of `SelectTransferMethodTypeCoordinator`
    func selectTransferMethodTypeCoordinator(forceUpdateData: Bool = false, parentController: UIViewController)
        -> SelectTransferMethodTypeCoordinator {
            let coordinator = SelectTransferMethodTypeCoordinator()
            coordinator
            .start(initializationData:
                [InitializationDataField.forceUpdateData: forceUpdateData],
                   parentController: parentController)
            return coordinator
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
    ///   - forceUpdateData: Forces to refresh the cached data.
    /// - Returns: An instance of `AddTransferMethodCoordinator`
    func addTransferMethodCoordinator(
        _ country: String,
        _ currency: String,
        _ profileType: String,
        _ transferMethodTypeCode: String,
        _ forceUpdateData: Bool = false,
        parentController: UIViewController) -> AddTransferMethodCoordinator {
        var initializationData = [InitializationDataField: Any]()
        initializationData[InitializationDataField.country]  = country
        initializationData[InitializationDataField.currency]  = currency
        initializationData[InitializationDataField.profileType]  = profileType
        initializationData[InitializationDataField.transferMethodTypeCode]  = transferMethodTypeCode
        initializationData[InitializationDataField.forceUpdateData]  = forceUpdateData

        let coordinator = AddTransferMethodCoordinator()
        coordinator.start(initializationData: initializationData, parentController: parentController)
        return coordinator
}
}
