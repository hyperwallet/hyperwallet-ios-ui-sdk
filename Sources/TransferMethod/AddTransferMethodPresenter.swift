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
import UIKit

protocol AddTransferMethodView: class {
    func fieldValues() -> [(name: String, value: String)]
    func dismissProcessing(handler: @escaping () -> Void)
    func hideLoading()
    func areAllFieldsValid() -> Bool
    func notifyTransferMethodAdded(_ transferMethod: HyperwalletTransferMethod)
    func showConfirmation(handler: @escaping () -> Void)
    func showError(_ error: HyperwalletErrorType, _ handler: (() -> Void)?)
    func showBusinessError(_ error: HyperwalletErrorType, _ handler: @escaping () -> Void)
    func showLoading()
    func showProcessing()
    func showTransferMethodFields(_ fields: [HyperwalletField], _ transferMethodTypeDetail: TransferMethodTypeDetail)
    func showFooterViewWithUpdatedSectionData(for sections: [AddTransferMethodSectionData])
}

final class AddTransferMethodPresenter {
    private unowned var view: AddTransferMethodView
    private let country: String
    private let currency: String
    private let profileType: String
    private let transferMethodType: String
    var sections: [AddTransferMethodSectionData] = []

    init(_ view: AddTransferMethodView,
         _ country: String,
         _ currency: String,
         _ profileType: String,
         _ transferMethodType: String) {
        self.view = view
        self.country = country
        self.currency = currency
        self.profileType = profileType
        self.transferMethodType = transferMethodType
    }

    func loadTransferMethodConfigurationFields() {
        let fieldsQuery = HyperwalletTransferMethodConfigurationFieldQuery(
            country: country,
            currency: currency,
            transferMethodType: transferMethodType,
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

                    guard let result = result else {
                        return
                    }
                    let transferTypeDetail = result.populateTransferMethodTypeDetail(
                        country: strongSelf.country,
                        currency: strongSelf.currency,
                        profileType: strongSelf.profileType,
                        transferMethodType: strongSelf.transferMethodType)
                    strongSelf.view.showTransferMethodFields(result.fields(), transferTypeDetail)
                }
            })
    }

    func createTransferMethod() {
        guard view.areAllFieldsValid()
            else {
                return
        }
        var hyperwalletTransferMethod: HyperwalletTransferMethod
        switch transferMethodType {
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

        default:
            hyperwalletTransferMethod = HyperwalletTransferMethod()
            hyperwalletTransferMethod.setField(key: "transferMethodCountry", value: country)
            hyperwalletTransferMethod.setField(key: "transferMethodCurrency", value: currency)
            hyperwalletTransferMethod.setField(key: "type", value: transferMethodType)
            hyperwalletTransferMethod.setField(key: "profileType", value: profileType)
        }

        for field in view.fieldValues() {
            hyperwalletTransferMethod.setField(key: field.name, value: field.value)
        }
        createTransferMethod(transferMethod: hyperwalletTransferMethod)
    }

    private func createTransferMethod(transferMethod: HyperwalletTransferMethod) {
        view.showProcessing()
        if let bankAccount = transferMethod as? HyperwalletBankAccount {
            Hyperwallet.shared.createBankAccount(account: bankAccount,
                                                 completion: createTransferMethodHandler())
        } else if let bankCard = transferMethod as? HyperwalletBankCard {
            Hyperwallet.shared.createBankCard(account: bankCard,
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
                        strongSelf.handle(for: error)
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

    private func handle(for error: HyperwalletErrorType) {
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
            let section = sections.first(where: { section in widgetsContainError(for: section, errors).isNotEmpty() }) {
            section.containsFocusedField = true
        }

        for section in sections.reversed() {
            if errorsWithFieldName.isNotEmpty() {
                updateSectionData(for: section, errorsWithFieldName)
            }
        }
        view.showFooterViewWithUpdatedSectionData(for: sections)
    }

    private func updateSectionData(for section: AddTransferMethodSectionData,
                                   _ errorsWithFieldName: [HyperwalletError]) {
        let errorWidgets = widgetsContainError(for: section, errorsWithFieldName)
        if let focusWidget = errorWidgets.first, let row = section.cells.firstIndex(of: focusWidget) {
            section.rowShouldBeScrolledTo = row
            section.fieldToBeFocused = focusWidget
            section.errorMessage = prepareErrorMessage(errors: errorsWithFieldName, errorWidgets: errorWidgets)
        }
    }

    private func prepareErrorMessage(errors: [HyperwalletError], errorWidgets: [AbstractWidget]) -> String {
        var errorMessages = [String]()
        for widget in errorWidgets {
            // get the errorMessage by widget name and update widget UI
            if let error = errors.first(where: { error in widget.name() == error.fieldName }) {
                widget.showError()
                errorMessages.append(error.message)
            }
        }
        return errorMessages.joined(separator: "\n")
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
        sections.forEach { $0.errorMessage = nil }
    }

    func getSectionContainingFocusedField() -> AddTransferMethodSectionData? {
        return sections.first(where: { $0.containsFocusedField == true })
    }

    func getSectionIndex(by category: String) -> Int? {
        return sections.firstIndex(where: { $0.category == category })
    }

    func focusField(in section: AddTransferMethodSectionData) {
        if section.containsFocusedField {
            section.fieldToBeFocused?.focus()
        }
    }
}
