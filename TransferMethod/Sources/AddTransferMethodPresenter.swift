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
#if !COCOAPODS
import Common
import TransferMethodRepository
#endif

protocol AddTransferMethodView: class {
    func fieldValues() -> [(name: String, value: String)]
    func dismissProcessing(handler: @escaping () -> Void)
    func hideLoading()
    func areAllFieldsValid() -> Bool
    func notifyTransferMethodAdded(_ transferMethod: HyperwalletTransferMethod)
    func showConfirmation(handler: @escaping () -> Void)
    func showError( title: String, message: String)
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func showLoading()
    func showProcessing()
    func showTransferMethodFields(_ fieldGroups: [HyperwalletFieldGroup],
                                  _ transferMethodType: HyperwalletTransferMethodType)
    func showFooterViewWithUpdatedSectionData(for sections: [AddTransferMethodSectionData])
}

final class AddTransferMethodPresenter {
    private unowned var view: AddTransferMethodView
    private let errorTypeApi = "API"
    private let profileType: String
    private let createdConfirmationPageName = "transfer-method:add:transfer-method-created"
    private let pageLink = "create-transfer-method"
    private let transferMethodCreatedGoal = "transfer-method-created"
    static let addTransferMethodPageGroup = "transfer-method"
    static let addTransferMethodPageName = "transfer-method:add:collect-transfer-method-information"
    private let hyperwalletInsights: HyperwalletInsightsProtocol
    let country: String
    let currency: String
    let transferMethodTypeCode: String
    var sectionData = [AddTransferMethodSectionData]()

    private lazy var transferMethodConfigurationRepository = {
        TransferMethodRepositoryFactory.shared.transferMethodConfigurationRepository()
    }()

    private lazy var transferMethodRepository = {
        TransferMethodRepositoryFactory.shared.transferMethodRepository()
    }()

    init(_ view: AddTransferMethodView,
         _ country: String,
         _ currency: String,
         _ profileType: String,
         _ transferMethodTypeCode: String,
         _ hyperwalletInsights: HyperwalletInsightsProtocol = HyperwalletInsights.shared) {
        self.view = view
        self.country = country
        self.currency = currency
        self.profileType = profileType
        self.transferMethodTypeCode = transferMethodTypeCode
        self.hyperwalletInsights = hyperwalletInsights
    }

    func loadTransferMethodConfigurationFields(_ forceUpdate: Bool = false) {
        view.showLoading()

        if forceUpdate {
            transferMethodConfigurationRepository.refreshFields()
        }

        transferMethodConfigurationRepository
            .getFields(country,
                       currency,
                       transferMethodTypeCode,
                       profileType) { [weak self] (result) in
                        guard let strongSelf = self else {
                            return
                        }

                        strongSelf.view.hideLoading()

                        switch result {
                        case .failure(let error):
                            strongSelf.view.showError(
                                error,
                                pageName: AddTransferMethodPresenter.addTransferMethodPageName,
                                pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup) {
                                    strongSelf.loadTransferMethodConfigurationFields()
                            }

                        case .success(let fieldResult):
                            if let fieldGroups = fieldResult?.fieldGroups(),
                                let transferMethodType = fieldResult?.transferMethodType() {
                                strongSelf.trackUILoadImpression()
                                strongSelf.view.showTransferMethodFields(fieldGroups, transferMethodType)
                            }
                        }
            }
    }

    func createTransferMethod() {
        trackConfirmClick()
        guard view.areAllFieldsValid() else {
            return
        }

        guard let hyperwalletTransferMethod = buildHyperwalletTransferMethod() else {
            view.showError(title: "error".localized(), message: "transfer_method_not_supported_message".localized())
            return
        }
        view.fieldValues().forEach { hyperwalletTransferMethod.setField(key: $0.name, value: $0.value) }

        view.showProcessing()
        transferMethodRepository.createTransferMethod(hyperwalletTransferMethod) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .failure(let error):
                strongSelf.view.dismissProcessing(handler: {
                    strongSelf.errorHandler(for: error)
                })

            case .success(let transferMethodResult):
                strongSelf.view.showConfirmation(handler: {
                    if let transferMethod = transferMethodResult {
                        strongSelf.trackTransferMethodCreatedConfirmationImpression()
                        strongSelf.view.notifyTransferMethodAdded(transferMethod)
                    }
                })
            }
        }
    }

    func prepareSectionForScrolling(_ section: AddTransferMethodSectionData,
                                    _ row: Int,
                                    _ focusWidget: AbstractWidget) {
        section.rowShouldBeScrolledTo = row
        section.fieldToBeFocused = focusWidget
    }

    private func errorHandler(for error: HyperwalletErrorType) {
        switch error.group {
        case .business:
            resetErrorMessagesForAllSections()
            if let errors = error.getHyperwalletErrors()?.errorList, errors.isNotEmpty {
                updateFooterContent(errors)
                if errors.contains(where: { $0.fieldName == nil }) {
                    view.showError(error,
                                   pageName: AddTransferMethodPresenter.addTransferMethodPageName,
                                   pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup,
                                   nil)
                }
            }

        default:
            view.showError(error,
                           pageName: AddTransferMethodPresenter.addTransferMethodPageName,
                           pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup) { [weak self] in
                            self?.createTransferMethod()
            }
        }
    }

    private func buildHyperwalletTransferMethod() -> HyperwalletTransferMethod? {
        switch transferMethodTypeCode {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT" :
            return HyperwalletBankAccount.Builder(transferMethodCountry: country,
                                                  transferMethodCurrency: currency,
                                                  transferMethodProfileType: profileType,
                                                  transferMethodType: transferMethodTypeCode)
                .build()
        case "BANK_CARD" :
            return HyperwalletBankCard.Builder(transferMethodCountry: country,
                                               transferMethodCurrency: currency,
                                               transferMethodProfileType: profileType)
                .build()
        case "PAYPAL_ACCOUNT":
            return HyperwalletPayPalAccount.Builder(transferMethodCountry: country,
                                                    transferMethodCurrency: currency,
                                                    transferMethodProfileType: profileType)
                .build()

        default:
            return nil
        }
    }

    private func updateFooterContent(_ errors: [HyperwalletError]) {
        let errorsWithFieldName = errors.filter({ $0.fieldName != nil })

        if errorsWithFieldName.isNotEmpty {
            if let section = sectionData
                .first(where: { section in widgetsContainError(for: section, errors).isNotEmpty }) {
                section.containsFocusedField = true
            }

            for section in sectionData {
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
                trackError(errorMessage: error.message,
                           errorCode: error.code,
                           errorType: errorTypeApi,
                           fieldName: widget.name())
                widget.showError()
                errorMessages.append(error.message)
            }
        }
        section.errorMessage = errorMessages.joined(separator: "\n")
    }

    private func trackError(errorMessage: String,
                            errorCode: String,
                            errorType: String,
                            fieldName: String) {
        let errorInfo = ErrorInfoBuilder(type: errorType, message: errorMessage)
            .fieldName(fieldName)
            .code(errorCode)
            .build()
        hyperwalletInsights.trackError(pageName: AddTransferMethodPresenter.addTransferMethodPageName,
                                       pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup,
                                       errorInfo: errorInfo)
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

    private func resetErrorMessagesForAllSections() {
        sectionData.forEach { $0.errorMessage = nil }
    }

    private func trackUILoadImpression () {
        hyperwalletInsights.trackImpression(pageName: AddTransferMethodPresenter.addTransferMethodPageName,
                                            pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup,
                                            params: insightsParam())
    }

    private func trackConfirmClick() {
        hyperwalletInsights.trackClick(
            pageName: AddTransferMethodPresenter.addTransferMethodPageName,
            pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup,
            link: pageLink,
            params: insightsParam())
    }

    private func trackTransferMethodCreatedConfirmationImpression() {
        hyperwalletInsights.trackImpression(pageName: createdConfirmationPageName,
                                            pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup,
                                            params: [
                                                InsightsTags.country: country,
                                                InsightsTags.currency: currency,
                                                InsightsTags.transferMethodType: transferMethodTypeCode,
                                                InsightsTags.profileType: profileType,
                                                InsightsTags.goal: transferMethodCreatedGoal
                                            ])
    }

    private func insightsParam () -> [String: String] {
        return [
            InsightsTags.country: country,
            InsightsTags.currency: currency,
            InsightsTags.transferMethodType: transferMethodTypeCode,
            InsightsTags.profileType: profileType
        ]
    }
}
