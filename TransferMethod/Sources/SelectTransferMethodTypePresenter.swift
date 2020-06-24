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
import UserRepository
#endif

protocol SelectTransferMethodTypeView: class {
    typealias SelectItemHandler = (_ value: GenericCellConfiguration) -> Void
    typealias MarkCellHandler = (_ value: GenericCellConfiguration) -> Bool
    typealias FilterContentHandler = ((_ items: [GenericCellConfiguration],
        _ searchText: String) -> [GenericCellConfiguration])

    func showGenericTableView(items: [GenericCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler,
                              filterContentHandler: @escaping FilterContentHandler)

    func navigateToAddTransferMethodController(country: String,
                                               currency: String,
                                               profileType: String,
                                               transferMethodTypeCode: String)
    func showAlert(message: String?)
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func showLoading()
    func hideLoading()
    func reloadTransferMethodTypeData()
    func reloadCountryCurrencyData()
}

final class SelectTransferMethodTypePresenter {
    // MARK: properties
    private weak var view: SelectTransferMethodTypeView?
    private (set) var countryCurrencySectionData = [String]()
    private (set) var selectedCountry = ""
    private (set) var selectedCurrency = ""
    private let pageName = "transfer-method:add:select-transfer-method"
    private let pageGroup = "transfer-method"
    private let linkCountry = "select-country"
    private let linkCurrency = "select-currency"
    private let linkTransferMethod = "select-transfer-method"
    private var selectedTransferMethodType = ""
    private var hyperwalletInsights: HyperwalletInsightsProtocol

    private lazy var transferMethodConfigurationRepository = {
        TransferMethodRepositoryFactory.shared.transferMethodConfigurationRepository()
    }()

    private lazy var userRepository: UserRepository = {
        UserRepositoryFactory.shared.userRepository()
    }()

    private (set) var sectionData = [HyperwalletTransferMethodType]()

    /// Initialize SelectTransferMethodPresenter
    init(_ view: SelectTransferMethodTypeView,
         _ hyperwalletInsights: HyperwalletInsightsProtocol = HyperwalletInsights.shared) {
        self.view = view
        self.hyperwalletInsights = hyperwalletInsights
    }

    /// Return the countryCurrency item composed by the tuple (title and value)
    func getCountryCurrencyConfiguration(indexPath: IndexPath) -> GenericCellConfiguration {
        let title = countryCurrencySectionData[indexPath.row]
        return SelectedCountryCurrencyCellConfiguration(title: title.localized(),
                                                        value: countryCurrencyValues(at: indexPath.row))
    }

    /// Display all the select Country or Currency based on the index
    func performShowSelectCountryOrCurrencyView(index: Int) {
        transferMethodConfigurationRepository.getKeys(completion: self.getKeysHandler(
            success: { (result) in
                if index == 0 {
                    self.showSelectCountryView(result?.countries())
                } else {
                    self.showSelectCurrencyView(result?.currencies(from: self.selectedCountry))
                }
            }))
    }

    /// Loads the transferMethodKeys from core SDK and display the default transfer methods
    ///
    /// - Parameter forceUpdate: Forces to refresh the data
    func loadTransferMethodKeys(_ forceUpdate: Bool = false) {
        view?.showLoading()

        if forceUpdate {
            userRepository.refreshUser()
            transferMethodConfigurationRepository.refreshKeys()
        }

        userRepository.getUser { [weak self] getUserResult in
            guard let strongSelf = self else {
                return
            }
            switch getUserResult {
            case .failure(let error):
                strongSelf.view?.hideLoading()
                strongSelf.view?.showError(error,
                                           pageName: strongSelf.pageName,
                                           pageGroup: strongSelf.pageGroup) {
                    strongSelf.loadTransferMethodKeys()
                }

            case .success(let user):
                strongSelf.transferMethodConfigurationRepository
                    .getKeys(completion: strongSelf.getKeysHandler(
                        success: { (result) in
                            guard let countries = result?.countries(), countries.isNotEmpty  else {
                                strongSelf.view?.showAlert(message: "no_country_available_error_message".localized())
                                return
                            }
                            strongSelf.countryCurrencySectionData = ["Country", "Currency"]
                            strongSelf.loadSelectedCountry(countries, with: user?.country)
                            strongSelf.loadCurrency(result)
                            strongSelf.loadTransferMethodTypes(result)
                        },
                        failure: { strongSelf.loadTransferMethodKeys() })
                )
            }
        }
    }

    /// Navigate to AddTransferMethodController
    func navigateToAddTransferMethod(_ index: Int) {
        if let transferMethodTypeCode = self.sectionData[index].code {
            self.selectedTransferMethodType = transferMethodTypeCode
            self.trackTransferMethodClick()
        }
        userRepository.getUser {[weak self] (getUserResult) in
            guard let strongSelf = self else {
                return
            }

            if case let .success(user) = getUserResult,
                let profileType = user?.profileType?.rawValue {
                strongSelf.view?
                    .navigateToAddTransferMethodController(
                        country: strongSelf.selectedCountry,
                        currency: strongSelf.selectedCurrency,
                        profileType: profileType,
                        transferMethodTypeCode: strongSelf.selectedTransferMethodType
                )
            }
        }
    }

    private func countryCurrencyValues(at index: Int) -> String {
        return (index == 0
            ? Locale.current.localizedString(forRegionCode: selectedCountry) ?? selectedCountry
            : selectedCurrency)
    }

    private func getKeysHandler(
        success: @escaping ((HyperwalletTransferMethodConfigurationKey?) -> Void),
        failure: (() -> Void)? = nil)
        -> (Result<HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType>) -> Void {
        return { [weak self] (result) in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }

            view.hideLoading()

            switch result {
            case .failure(let error):
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup, failure)

            case .success(let keyResult):
                success(keyResult)
            }
        }
    }

    /// Shows the Select Country View
    private func showSelectCountryView(_ countries: [GenericCellConfiguration]?) {
        if let countries = countries {
            view?.showGenericTableView(items: countries,
                                       title: "select_transfer_method_country".localized(),
                                       selectItemHandler: selectCountryHandler(),
                                       markCellHandler: countryMarkCellHandler(),
                                       filterContentHandler: filterContentHandler())
        }
    }

    /// Shows the Select Currency View
    private func showSelectCurrencyView(_ currencies: [GenericCellConfiguration]?) {
        if let currencies = currencies {
            view?.showGenericTableView(items: currencies,
                                       title: "select_transfer_method_currency".localized(),
                                       selectItemHandler: selectCurrencyHandler(),
                                       markCellHandler: currencyMarkCellHandler(),
                                       filterContentHandler: filterContentHandler())
        }
    }

    private func selectCountryHandler() -> SelectTransferMethodTypeView.SelectItemHandler {
        return { (country) in
            if let country = country.value {
                self.selectedCountry = country
                self.trackCountryClick()
            }
            self.transferMethodConfigurationRepository
                .getKeys(completion: self.getKeysHandler(success: { (result) in
                    self.loadCurrency(result)
                    self.loadTransferMethodTypes(result)
                }))
        }
    }

    private func selectCurrencyHandler() -> SelectTransferMethodTypeView.SelectItemHandler {
        return { (currency) in
            if let currency = currency.value {
                self.selectedCurrency = currency
                self.trackCurrencyClick()
            }
            self.transferMethodConfigurationRepository.getKeys(completion: self.getKeysHandler(
                success: { (result) in
                    self.loadTransferMethodTypes(result)
                    self.view?.reloadCountryCurrencyData()
                }))
        }
    }

    private func filterContentHandler() -> SelectTransferMethodTypeView.FilterContentHandler {
        return {(items, searchText) in
            items.filter {
                $0.title?.lowercased().contains(searchText.lowercased()) ?? false ||
                    $0.value?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }

    private func countryMarkCellHandler() -> SelectTransferMethodTypeView.MarkCellHandler {
        return { [weak self] item in
            self?.selectedCountry == item.value
        }
    }

    private func currencyMarkCellHandler() -> SelectTransferMethodTypeView.MarkCellHandler {
        return { [weak self] item in
            self?.selectedCurrency == item.value
        }
    }

    private func loadSelectedCountry(_ countries: [HyperwalletCountry],
                                     with userCountry: String?) {
        if let userCountry = userCountry, countries.contains(where: { $0.value == userCountry }) {
            selectedCountry = userCountry
        } else if let country = countries.first, let countryValue = country.value {
            selectedCountry = countryValue
        }
    }

    private func loadCurrency(_ keys: HyperwalletTransferMethodConfigurationKey?) {
        guard let firstCurrency = keys?.currencies(from: selectedCountry)?.first,
            let currencyCode = firstCurrency.code else {
            view?.showAlert(message: String(format: "no_currency_available_error_message".localized(), selectedCountry))
            return
        }
        selectedCurrency = currencyCode
        view?.reloadCountryCurrencyData()
    }

    private func loadTransferMethodTypes(_ keys: HyperwalletTransferMethodConfigurationKey?) {
        guard let transferMethodTypes = keys?.transferMethodTypes(countryCode: selectedCountry,
                                                                  currencyCode: selectedCurrency),
            transferMethodTypes.isNotEmpty  else {
            view?.showAlert(message: String(format: "no_transfer_method_available_error_message".localized(),
                                            selectedCountry,
                                            selectedCurrency))
            return
        }

        sectionData = transferMethodTypes
        view?.reloadTransferMethodTypeData()
        trackUILoadImpression()
    }

    private func trackUILoadImpression() {
        let params = [InsightsTags.country: selectedCountry, InsightsTags.currency: selectedCurrency]
        hyperwalletInsights.trackImpression(pageName: pageName, pageGroup: pageGroup, params: params)
    }

    private func trackTransferMethodClick() {
       let clickParams = [
               InsightsTags.country:
                   self.selectedCountry,
               InsightsTags.currency:
                   self.selectedCurrency,
               InsightsTags.transferMethodType:
                   self.selectedTransferMethodType
       ]
         hyperwalletInsights
            .trackClick(pageName: pageName, pageGroup: pageGroup, link: linkTransferMethod, params: clickParams)
     }

    private func trackCountryClick() {
        hyperwalletInsights
            .trackClick(pageName: pageName,
                        pageGroup: pageGroup,
                        link: linkCountry,
                        params: [InsightsTags.country: self.selectedCountry])
     }

    private func trackCurrencyClick() {
        hyperwalletInsights
            .trackClick(pageName: pageName,
                        pageGroup: pageGroup,
                        link: linkCurrency,
                        params: [InsightsTags.currency: self.selectedCurrency])
       }
}
