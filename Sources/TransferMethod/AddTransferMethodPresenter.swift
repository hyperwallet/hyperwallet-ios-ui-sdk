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

import HyperwalletSDK

protocol AddTransferMethodView: class {
    func fieldValues() -> [(name: String, value: String)]
    func dismissProcessing(handler: @escaping () -> Void)
    func hideLoading()
    func areAllFieldsValid() -> Bool
    func notifyTransferMethodAdded(_ transferMethod: HyperwalletTransferMethod)
    func showConfirmation(handler: @escaping () -> Void)
    func showError( title: String, message: String)
    func showError(_ error: HyperwalletErrorType, _ handler: (() -> Void)?)
    func showBusinessError(_ error: HyperwalletErrorType, _ handler: @escaping () -> Void)
    func showLoading()
    func showProcessing()
    func showTransferMethodFields(_ fieldGroups: [HyperwalletFieldGroup],
                                  _ transferMethodType: HyperwalletTransferMethodType)
    func showFooterViewWithUpdatedSectionData(for sections: [AddTransferMethodSectionData])
}

final class AddTransferMethodPresenter {
    private unowned var view: AddTransferMethodView
    private let country: String
    private let currency: String
    private let profileType: String
    private let transferMethodTypeCode: String
    var sectionData = [AddTransferMethodSectionData]()

    init(_ view: AddTransferMethodView,
         _ country: String,
         _ currency: String,
         _ profileType: String,
         _ transferMethodTypeCode: String) {
        self.view = view
        self.country = country
        self.currency = currency
        self.profileType = profileType
        self.transferMethodTypeCode = transferMethodTypeCode
    }

    func loadTransferMethodConfigurationFields() {
        let fieldsQuery = HyperwalletTransferMethodConfigurationFieldQuery(
            country: country,
            currency: currency,
            transferMethodType: transferMethodTypeCode,
            profile: profileType
        )
        view.showLoading()
        Hyperwallet.shared.retrieveTransferMethodConfigurationFields(
            request: fieldsQuery,
            completion: { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }

                DispatchQueue.main.async {
                    strongSelf.view.hideLoading()
                    if let error = error {
                        strongSelf.view.showError(error, { () -> Void in
                            strongSelf.loadTransferMethodConfigurationFields() })
                        return
                    }
                    guard
                        let result = result,
                        let fieldGroups = result.fieldGroups(),
                        let transferMethodType = result.transferMethodType()
                        else {
                            return
                    }
                    strongSelf.view.showTransferMethodFields(fieldGroups, transferMethodType)
                }
            })
    }

    func createTransferMethod() {
        guard view.areAllFieldsValid()
            else {
                return
        }
        var hyperwalletTransferMethod: HyperwalletTransferMethod
        switch transferMethodTypeCode {
        case "BANK_ACCOUNT":
            hyperwalletTransferMethod = HyperwalletBankAccount.Builder(transferMethodCountry: country,
                                                                       transferMethodCurrency: currency,
                                                                       transferMethodProfileType: profileType)
                .build()

        case "BANK_CARD":
            hyperwalletTransferMethod = HyperwalletBankCard.Builder(transferMethodCountry: country,
                                                                    transferMethodCurrency: currency,
                                                                    transferMethodProfileType: profileType)
                .build()

        case "PAYPAL_ACCOUNT":
            hyperwalletTransferMethod = HyperwalletPayPalAccount.Builder(transferMethodCountry: country,
                                                                         transferMethodCurrency: currency,
                                                                         transferMethodProfileType: profileType)
                .build()

        case "WIRE_ACCOUNT":
            hyperwalletTransferMethod = HyperwalletBankAccount.Builder(transferMethodCountry: country,
                                                                       transferMethodCurrency: currency,
                                                                       transferMethodProfileType: profileType)
                .type("WIRE_ACCOUNT")
                .build()

        default:
            view.showError(title: "error".localized(), message: "transfer_method_not_supported_message".localized())
            return
        }

        for field in view.fieldValues() {
            hyperwalletTransferMethod.setField(key: field.name, value: field.value)
        }
        createTransferMethod(transferMethod: hyperwalletTransferMethod)
    }

    func prepareSectionForScrolling(_ section: AddTransferMethodSectionData,
                                    _ row: Int,
                                    _ focusWidget: AbstractWidget) {
        section.rowShouldBeScrolledTo = row
        section.fieldToBeFocused = focusWidget
    }

    private func createTransferMethod(transferMethod: HyperwalletTransferMethod) {
        view.showProcessing()
        if let bankAccount = transferMethod as? HyperwalletBankAccount {
            Hyperwallet.shared.createBankAccount(account: bankAccount,
                                                 completion: createTransferMethodHandler())
        } else if let bankCard = transferMethod as? HyperwalletBankCard {
            Hyperwallet.shared.createBankCard(account: bankCard,
                                              completion: createTransferMethodHandler())
        } else if let payPalAccount = transferMethod as? HyperwalletPayPalAccount {
            Hyperwallet.shared.createPayPalAccount(account: payPalAccount,
                                                   completion: createTransferMethodHandler())
        }
    }

    private func createTransferMethodHandler() -> (HyperwalletTransferMethod?, HyperwalletErrorType?) -> Void {
        return { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                if let error = error {
                    let errorHandler = {
                        strongSelf.errorHandler(for: error)
                    }
                    strongSelf.view.dismissProcessing(handler: errorHandler)
                } else {
                    let processingHandler = {
                        if let transferMethod = result {
                            strongSelf.view.notifyTransferMethodAdded(transferMethod)
                        }
                    }
                    strongSelf.view.showConfirmation(handler: processingHandler)
                }
            }
        }
    }

    private func errorHandler(for error: HyperwalletErrorType) {
        switch error.group {
        case .business:
            //reset all the error messages for all the sections
            resetErrorMessages()
            guard let errors = error.getHyperwalletErrors()?.errorList, errors.isNotEmpty() else {
                return
            }

            // show alert dialog if there is any error that does not contain `fieldName`
            if errors.contains(where: { $0.fieldName == nil }) {
                view.showBusinessError(error, { [weak self] () -> Void in self?.updateFooterContent(errors) })
            } else { // update footer content when all the errors contain `fieldName`
                updateFooterContent(errors)
            }

        default:
            let handler = { [weak self] () -> Void in self?.createTransferMethod() }
            view.showError(error, handler)
        }
    }

    private func updateFooterContent(_ errors: [HyperwalletError]) {
        let errorsWithFieldName = errors.filter({ $0.fieldName != nil })

        if errorsWithFieldName.isNotEmpty(),
            let section = sectionData.first(where: { section in widgetsContainError(for: section, errors)
                .isNotEmpty() }) {
            section.containsFocusedField = true
        }

        for section in sectionData {
            if errorsWithFieldName.isNotEmpty() {
                updateSectionData(for: section, errorsWithFieldName)
            }
        }
        view.showFooterViewWithUpdatedSectionData(for: sectionData.reversed())
    }

    private func updateSectionData(for section: AddTransferMethodSectionData,
                                   _ errorsWithFieldName: [HyperwalletError]) {
        let errorWidgets = widgetsContainError(for: section, errorsWithFieldName)
        if let focusWidget = errorWidgets.first, let row = section.cells.firstIndex(of: focusWidget) {
            prepareSectionForScrolling(section, row, focusWidget)
            prepareErrorMessage(section, errorsWithFieldName, errorWidgets)
        }
    }

    private func prepareErrorMessage(_ section: AddTransferMethodSectionData,
                                     _ errors: [HyperwalletError],
                                     _ errorWidgets: [AbstractWidget]) {
        var errorMessages = [String]()
        for widget in errorWidgets {
            // get the errorMessage by widget name and update widget UI
            if let error = errors.first(where: { error in widget.name() == error.fieldName }) {
                widget.showError()
                errorMessages.append(error.message)
            }
        }
        section.errorMessage = errorMessages.joined(separator: "\n")
    }

    private func widgetsContainError(for section: AddTransferMethodSectionData,
                                     _ errors: [HyperwalletError]) -> [AbstractWidget] {
        return allWidgets(of: section).filter { widget in errors
            .contains(where: { error in widget.name() == error.fieldName })
        }
    }

    private func allWidgets(of section: AddTransferMethodSectionData) -> [AbstractWidget] {
        return section.cells.compactMap { $0 as? AbstractWidget }
    }

    private func resetErrorMessages() {
        sectionData.forEach { $0.errorMessage = nil }
    }
}
