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

protocol UpdateTransferMethodView: class {
    func fieldValues() -> [(name: String, value: String)]
    func dismissProcessing(handler: @escaping () -> Void)
    func hideLoading()
    func areAllUpdatedFieldsValid() -> Bool
    func notifyTransferMethodUpdated(_ transferMethod: HyperwalletTransferMethod)
    func showConfirmation(handler: @escaping () -> Void)
    func showError( title: String, message: String)
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func showLoading()
    func showProcessing()
    func reloadData(_ fieldGroups: [HyperwalletFieldGroup])
    func showFooterViewWithUpdatedSectionData(for sections: [UpdateTransferMethodSectionData])
}

final class UpdateTransferMethodPresenter {
    private weak var view: UpdateTransferMethodView?
    private let errorTypeApi = "API"
    private let createdConfirmationPageName = "transfer-method:update:transfer-method-updated"
    private let pageLink = "update-transfer-method"
    private let transferMethodUpdatedGoal = "transfer-method-updated"
    static let updateTransferMethodPageGroup = "update-transfer-method"
    static let updateTransferMethodPageName = "transfer-method:update:collect-transfer-method-information"
    private let hyperwalletInsights: HyperwalletInsightsProtocol
    var transferMethodConfiguration: HyperwalletTransferMethodConfiguration?
    let transferMethodToken: String
    var sectionData = [UpdateTransferMethodSectionData]()

    private lazy var transferMethodUpdateConfigurationRepository = {
        TransferMethodRepositoryFactory.shared.transferMethodUpdateConfigurationRepository()
    }()

    private lazy var transferMethodRepository = {
        TransferMethodRepositoryFactory.shared.transferMethodRepository()
    }()

    init(_ view: UpdateTransferMethodView,
         _ transferMethodToken: String,
         _ hyperwalletInsights: HyperwalletInsightsProtocol = HyperwalletInsights.shared) {
        self.view = view
        self.transferMethodToken = transferMethodToken
        self.hyperwalletInsights = hyperwalletInsights
    }

    func loadTransferMethodUpdateConfigurationFields(_ forceUpdate: Bool = false) {
        view?.showLoading()

        transferMethodUpdateConfigurationRepository
            .getFields(transferMethodToken) { [weak self] (result) in
                guard let strongSelf = self, let view = strongSelf.view else {
                    return
                }
                view.hideLoading()

                switch result {
                case .failure(let error):
                    view.showError(
                        error,
                        pageName: UpdateTransferMethodPresenter.updateTransferMethodPageName,
                        pageGroup: UpdateTransferMethodPresenter.updateTransferMethodPageGroup) {
                            strongSelf.loadTransferMethodUpdateConfigurationFields()
                    }

                case .success(let result):
                    self?.transferMethodConfiguration = result?.transferMethodUpdateConfiguration()
                    if let fieldGroups = self?.transferMethodConfiguration?.fieldGroups?.nodes {
                        strongSelf.trackUILoadImpression()
                        view.reloadData(fieldGroups)
                    }
                }
            }
    }

    func updateTransferMethod() {
        trackConfirmClick()
        guard let view = view, view.areAllUpdatedFieldsValid() else {
            return
        }

        guard let hyperwalletTransferMethod = buildHyperwalletTransferMethod() else {
            view.showError(title: "error".localized(), message: "transfer_method_not_supported_message".localized())
            return
        }
        view.fieldValues().forEach { hyperwalletTransferMethod.setField(key: $0.name, value: $0.value) }

        view.showProcessing()
        transferMethodRepository.updateTransferMethods(hyperwalletTransferMethod) { [weak self] (result) in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            switch result {
            case .failure(let error):
                view.dismissProcessing(handler: {
                    strongSelf.errorHandler(for: error)
                })

            case .success(let transferMethodResult):
                view.showConfirmation(handler: {
                    if let transferMethod = transferMethodResult {
                        strongSelf.trackTransferMethodUpdateConfirmationImpression()
                        view.notifyTransferMethodUpdated(transferMethod)
                    }
                })
            }
        }
    }

    func prepareSectionForScrolling(_ section: UpdateTransferMethodSectionData,
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
                    view?.showError(error,
                                    pageName: UpdateTransferMethodPresenter.updateTransferMethodPageName,
                                    pageGroup: UpdateTransferMethodPresenter.updateTransferMethodPageGroup,
                                    nil)
                }
            }

        default:
            view?.showError(error,
                            pageName: UpdateTransferMethodPresenter.updateTransferMethodPageName,
                            pageGroup: UpdateTransferMethodPresenter.updateTransferMethodPageGroup) { [weak self] in
                                self?.updateTransferMethod()
            }
        }
    }

    private func buildHyperwalletTransferMethod()
        -> HyperwalletTransferMethod? {
        let transferMethodTypeCode = transferMethodConfiguration?.transferMethodType ?? ""
        switch transferMethodTypeCode {
        case HyperwalletTransferMethod.TransferMethodType.bankAccount.rawValue,
             HyperwalletTransferMethod.TransferMethodType.wireAccount.rawValue :
            let bankAccount = HyperwalletBankAccount.Builder(token: transferMethodToken)
                .build()
            return bankAccount

        case HyperwalletTransferMethod.TransferMethodType.bankCard.rawValue :
            let bankCard = HyperwalletBankCard.Builder(token: transferMethodToken)
                .build()
            return bankCard

        case HyperwalletTransferMethod.TransferMethodType.payPalAccount.rawValue:
            let payPal = HyperwalletPayPalAccount.Builder(token: transferMethodToken)
                .build()
            return payPal

        case HyperwalletTransferMethod.TransferMethodType.venmoAccount.rawValue:
            let venmo = HyperwalletVenmoAccount.Builder(token: transferMethodToken)
                .build()
            return venmo

        case HyperwalletTransferMethod.TransferMethodType.paperCheck.rawValue:
            let paperCheck = HyperwalletPaperCheck.Builder(token: transferMethodToken)
                .build()
            return paperCheck

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

        view?.showFooterViewWithUpdatedSectionData(for: sectionData.reversed())
    }

    private func updateSectionData(for section: UpdateTransferMethodSectionData,
                                   _ errorsWithFieldName: [HyperwalletError]) {
        let errorWidgets = widgetsContainError(for: section, errorsWithFieldName)
        if let focusWidget = errorWidgets.first, let row = section.cells.firstIndex(of: focusWidget) {
            prepareSectionForScrolling(section, row, focusWidget)
            prepareErrorMessage(section, errorsWithFieldName, errorWidgets)
        }
    }

    private func prepareErrorMessage(_ section: UpdateTransferMethodSectionData,
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
        hyperwalletInsights.trackError(pageName: UpdateTransferMethodPresenter.updateTransferMethodPageName,
                                       pageGroup: UpdateTransferMethodPresenter.updateTransferMethodPageGroup,
                                       errorInfo: errorInfo)
    }

    private func widgetsContainError(for section: UpdateTransferMethodSectionData,
                                     _ errors: [HyperwalletError]) -> [AbstractWidget] {
        return allWidgets(of: section).filter { widget in errors
            .contains(where: { error in widget.name() == error.fieldName })
        }
    }

    private func allWidgets(of section: UpdateTransferMethodSectionData) -> [AbstractWidget] {
        return section.cells.compactMap { $0 as? AbstractWidget }
    }

    func resetErrorMessagesForAllSections() {
        sectionData.forEach { $0.errorMessage = nil }
    }

    private func trackUILoadImpression () {
        hyperwalletInsights.trackImpression(pageName: UpdateTransferMethodPresenter.updateTransferMethodPageName,
                                            pageGroup: UpdateTransferMethodPresenter.updateTransferMethodPageGroup,
                                            params: insightsParam())
    }

    private func trackConfirmClick() {
        hyperwalletInsights.trackClick(
            pageName: UpdateTransferMethodPresenter.updateTransferMethodPageName,
            pageGroup: UpdateTransferMethodPresenter.updateTransferMethodPageGroup,
            link: pageLink,
            params: insightsParam())
    }

    // Todo - Update
    private func trackTransferMethodUpdateConfirmationImpression() {
        hyperwalletInsights.trackImpression(pageName: createdConfirmationPageName,
                                            pageGroup: UpdateTransferMethodPresenter.updateTransferMethodPageGroup,
                                            params: [
                                                InsightsTags.country: transferMethodConfiguration?.country ?? "",
                                                InsightsTags.currency: transferMethodConfiguration?.currency ?? "",
                                                InsightsTags.transferMethodType: transferMethodConfiguration?
                                                    .transferMethodType ?? "",
                                                InsightsTags.profileType: transferMethodConfiguration?.profile ?? "",
                                                InsightsTags.goal: transferMethodUpdatedGoal
                                            ])
    }

    // Todo - Update InsightTags
    private func insightsParam () -> [String: String] {
        return [
            InsightsTags.country: transferMethodConfiguration?.country ?? "",
            InsightsTags.currency: transferMethodConfiguration?.currency ?? "",
            InsightsTags.transferMethodType: transferMethodConfiguration?.transferMethodType ?? "",
            InsightsTags.profileType: transferMethodConfiguration?.profile ?? ""
        ]
    }
}
