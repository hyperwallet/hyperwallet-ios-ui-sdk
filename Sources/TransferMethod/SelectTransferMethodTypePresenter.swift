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
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func showLoading()
    func hideLoading()
    func transferMethodTypeTableViewReloadData()
    func countryCurrencyTableViewReloadData()
}

final class SelectTransferMethodTypePresenter {
    // MARK: properties
    private unowned let view: SelectTransferMethodTypeView
    private var user: HyperwalletUser?
    private (set) var countryCurrencySectionData = [String]()
    private (set) var selectedCountry = ""
    private (set) var selectedCurrency = ""
    private var transferMethodConfigurationDataManager: TransferMethodConfigurationDataManagerProtocol {
        return TransferMethodConfigurationDataManager.shared
    }

    private var currencyFromSelectedCountry: [HyperwalletCurrency]? {
        return transferMethodConfigurationDataManager.currencies(from: selectedCountry)
    }

    var sectionData: [HyperwalletTransferMethodType] {
        return transferMethodConfigurationDataManager.transferMethodTypes(selectedCountry, selectedCurrency) ??
            [HyperwalletTransferMethodType]()
    }

    /// Initialize SelectTransferMethodPresenter
    init(_ view: SelectTransferMethodTypeView) {
        self.view = view
    }

    /// Return the `SelectTransferMethodTypeConfiguration` based on the index
    func getCellConfiguration(indexPath: IndexPath) -> SelectTransferMethodTypeConfiguration? {
        guard let transferMethodType = sectionData[safe: indexPath.row] else {
            return nil
        }

        let feesProcessingTime = transferMethodType.formatFeesProcessingTime()
        let transferMethodIcon = HyperwalletIcon.of(transferMethodType.code!).rawValue

        return SelectTransferMethodTypeConfiguration(
            transferMethodTypeCode: transferMethodType.code,
            transferMethodTypeName: transferMethodType.name,
            feesProcessingTime: feesProcessingTime,
            transferMethodIconFont: transferMethodIcon)
    }

    /// Return the countryCurrency item composed by the tuple (title and value)
    func getCountryCurrencyConfiguration(indexPath: IndexPath) -> GenericCellConfiguration? {
        guard let title = countryCurrencySectionData[safe: indexPath.row] else {
            return nil
        }
        return SelectedContryCurrencyCellConfiguration(title: title.localized(),
                                                       value: countryCurrencyValues(at: indexPath.row))
    }

    /// Display all the select Country or Currency based on the index
    func performShowSelectCountryOrCurrencyView(index: Int) {
        if index == 0 {
            showSelectCountryView(transferMethodConfigurationDataManager.countries())
        } else {
            guard !selectedCountry.isEmpty else {
                view.showAlert(message: "select_a_country_message".localized())
                return
            }
            showSelectCurrencyView(currencyFromSelectedCountry)
        }
    }

    /// Loads the transferMethodKeys from core SDK and display the default transfer methods
    func loadTransferMethodKeys(_ forceUpdate: Bool = false) {
        view.showLoading()

        if forceUpdate {
            transferMethodConfigurationDataManager.refreshKeys()
        }

        Hyperwallet.shared.getUser {[weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                DispatchQueue.main.async { [weak self]  in
                    self?.view.hideLoading()
                    self?.view.showError(error, { self?.loadTransferMethodKeys() })
                }
                return
            }

            strongSelf.user = result
            //TODO Review the DispatchQueue after to implement the UserRepository
            DispatchQueue.main.async {
                strongSelf.transferMethodConfigurationDataManager.getKeys(completion: strongSelf.getKeysHandler())
            }
        }
    }

    /// Navigate to AddTransferMethodController
    func navigateToAddTransferMethod(_ index: Int) {
        guard let profileType = user?.profileType?.rawValue else {
            return
        }
        view.navigateToAddTransferMethodController(country: selectedCountry,
                                                   currency: selectedCurrency,
                                                   profileType: profileType,
                                                   transferMethodTypeCode: sectionData[index].code!)
    }

    private func countryCurrencyValues(at index: Int) -> String {
        return (index == 0 ? selectedCountry.localized() : selectedCurrency)
    }

    private func getKeysHandler() -> (HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType?) -> Void {
        return { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view.hideLoading()

            if let error = error {
                strongSelf.view.showError(error, { strongSelf.loadTransferMethodKeys() })
                return
            }
            strongSelf.countryCurrencySectionData = ["Country", "Currency"]
            strongSelf.setSelectedCountry(countries: result?.countries())
            strongSelf.loadSelectedCurrencyValue()
            strongSelf.reloadTransferMethodTypesIfNeeded()
        }
    }

    /// Shows the Select Country View
    private func showSelectCountryView(_ countries: [GenericCellConfiguration]?) {
        guard let countries = countries else {
            view.showAlert(message: "no_country_available_error_message".localized())
            return
        }

        view.showGenericTableView(items: countries,
                                  title: "select_transfer_method_country".localized(),
                                  selectItemHandler: selectCountryHandler(),
                                  markCellHandler: countryMarkCellHandler(),
                                  filterContentHandler: filterContentHandler())
    }

    /// Shows the Select Currency View
    private func showSelectCurrencyView(_ currencies: [GenericCellConfiguration]?) {
        guard let currencies = currencies  else {
            view.showAlert(message: String(format: "no_currency_available_error_message".localized(),
                                           selectedCountry.localized()))
            return
        }

        view.showGenericTableView(items: currencies,
                                  title: "select_transfer_method_currency".localized(),
                                  selectItemHandler: selectCurrencyHandler(),
                                  markCellHandler: currencyMarkCellHandler(),
                                  filterContentHandler: filterContentHandler())
    }

    private func selectCountryHandler() -> SelectTransferMethodTypeView.SelectItemHandler {
        return { [weak self] (country) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.selectedCountry = country.value
            strongSelf.loadSelectedCurrencyValue()
            strongSelf.reloadTransferMethodTypesIfNeeded()
        }
    }

    private func selectCurrencyHandler() -> SelectTransferMethodTypeView.SelectItemHandler {
        return { [weak self]  (currency) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.selectedCurrency = currency.value
            strongSelf.reloadTransferMethodTypesIfNeeded()
            strongSelf.view.countryCurrencyTableViewReloadData()
        }
    }

    private func filterContentHandler() -> SelectTransferMethodTypeView.FilterContentHandler {
        return {(items, searchText) in
            items.filter {
                // search by decription
                $0.title.lowercased().contains(searchText.lowercased()) ||
                    //or code
                    $0.value.lowercased().contains(searchText.lowercased())
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

    private func setSelectedCountry(countries: [HyperwalletCountry]? ) {
        guard let countries = countries else {
            view.showAlert(message: "no_country_available_error_message".localized())
            return
        }

        if let userCountry = user?.country, countries.contains(where: { $0.value == userCountry }) {
            selectedCountry = userCountry
        } else if let country = countries.first {
            selectedCountry = country.value
        }
    }

    private func loadSelectedCurrencyValue() {
        guard let firstCurrency = currencyFromSelectedCountry?.min(by: { $0.name < $1.name }) else {
            view.showAlert(message: String(format: "no_currency_available_error_message".localized(),
                                           selectedCountry.localized()))
            selectedCurrency = ""
            view.countryCurrencyTableViewReloadData()
            return
        }
        selectedCurrency = firstCurrency.code
        view.countryCurrencyTableViewReloadData()
    }

    private func reloadTransferMethodTypesIfNeeded() {
        guard !sectionData.isEmpty else {
            view.showAlert(message: String(format: "no_transfer_method_available_error_message".localized(),
                                           selectedCountry,
                                           selectedCurrency))
            return
        }
        view.transferMethodTypeTableViewReloadData()
    }
}

// MARK: - HyperwalletCountry
extension HyperwalletCountry: GenericCellConfiguration {
    var title: String {
        return name
    }

    var value: String {
        return code
    }
}

// MARK: - HyperwalletCountry
extension HyperwalletCurrency: GenericCellConfiguration {
    var title: String {
        return name
    }

    var value: String {
        return code
    }
}
