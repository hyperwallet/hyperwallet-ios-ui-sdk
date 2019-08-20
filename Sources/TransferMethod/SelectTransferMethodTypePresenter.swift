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
    typealias SelectItemHandler = (_ value: CountryCurrencyCellConfiguration) -> Void
    typealias MarkCellHandler = (_ value: CountryCurrencyCellConfiguration) -> Bool
    typealias FilterContentHandler = ((_ items: [CountryCurrencyCellConfiguration],
        _ searchText: String) -> [CountryCurrencyCellConfiguration])

    func showGenericTableView(items: [CountryCurrencyCellConfiguration],
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
    private var transferMethodConfigurationKey: HyperwalletTransferMethodConfigurationKey?
    private (set) var sectionData = [HyperwalletTransferMethodType]()
    private (set) var countryCurrencySectionData = [String]()
    private (set) var selectedCountry = ""
    private (set) var selectedCurrency = ""

    /// Initialize SelectTransferMethodPresenter
    init(view: SelectTransferMethodTypeView) {
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
    func getCountryCurrencyConfiguration(indexPath: IndexPath) -> CountryCurrencyCellConfiguration? {
        guard let title = countryCurrencySectionData[safe: indexPath.row] else {
            return nil
        }
        return CountryCurrencyCellConfiguration(title: title.localized(),
                                                value: countryCurrencyValues(at: indexPath.row))
    }

    /// Display all the select Country or Currency based on the index
    func performShowSelectCountryOrCurrencyView(index: Int) {
        if index == 0 {
            guard let countries = self.loadTranferMethodConfigurationCountries() else {
                view.showAlert(message: "no_country_available_error_message".localized())
                return
            }

            showSelectCountryView(countries)
        } else {
            guard !selectedCountry.isEmpty else {
                self.view.showAlert(message: "select_a_country_message".localized())
                return
            }

            guard let currencies = self.loadTranferMethodConfigurationCurrencies(for: selectedCountry) else {
                view.showAlert(message: String(format: "no_currency_available_error_message".localized(),
                                               selectedCountry.localized()))
                return
            }

            showSelectCurrencyView(currencies)
        }
    }

    /// Loads the transferMethodKeys from core SDK and display the default transfer methods
    func loadTransferMethodKeys() {
        view.showLoading()

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

            Hyperwallet.shared.retrieveTransferMethodConfigurationKeys(
                request: HyperwalletTransferMethodConfigurationKeysQuery(),
                completion: strongSelf.transferMethodConfigurationKeyResultHandler())
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

    private func loadCountry() {
        guard let countries = loadTranferMethodConfigurationCountries() else {
            view.showAlert(message: "no_country_available_error_message".localized())
            return
        }

        if let userCountry = user?.country, countries.contains(where: { $0.value == userCountry }) {
            selectedCountry = userCountry
        } else if let country = countries.first {
            selectedCountry = country.value
        }
    }

    private func transferMethodConfigurationKeyResultHandler()
        -> (HyperwalletTransferMethodConfigurationKey?, HyperwalletErrorType?) -> Void {
            return { [weak self] (result, error) in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.view.hideLoading()

                    if let error = error {
                        strongSelf.view.showError(error, { strongSelf.loadTransferMethodKeys() })
                        return
                    }
                    strongSelf.countryCurrencySectionData = ["Country", "Currency"]
                    strongSelf.transferMethodConfigurationKey = result
                    strongSelf.loadCountry()
                    strongSelf.loadCurrency(for: strongSelf.selectedCountry)
                    strongSelf.loadTransferMethodTypes(country: strongSelf.selectedCountry,
                                                       currency: strongSelf.selectedCurrency)
                }
            }
    }

    /// Shows the Select Country View
    private func showSelectCountryView(_ countries: [CountryCurrencyCellConfiguration]) {
        view.showGenericTableView(items: countries,
                                  title: "select_transfer_method_country".localized(),
                                  selectItemHandler: selectCountryHandler(),
                                  markCellHandler: countryMarkCellHandler(),
                                  filterContentHandler: filterContentHandler())
    }

    /// Shows the Select Currency View
    private func showSelectCurrencyView(_ currencies: [CountryCurrencyCellConfiguration]) {
        view.showGenericTableView(items: currencies,
                                  title: "select_transfer_method_currency".localized(),
                                  selectItemHandler: selectCurrencyHandler(),
                                  markCellHandler: currencyMarkCellHandler(),
                                  filterContentHandler: filterContentHandler())
    }

    /// Handles the selection country event at GenericTableView
    /// when selecting a country, a default currency should be selected automatically as well.
    /// Eventually the transfer methods should be shown correspondingly
    private func selectCountryHandler() -> SelectTransferMethodTypeView.SelectItemHandler {
        return { [weak self] (country) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.selectedCountry = country.value
            strongSelf.loadCurrency(for: country.value)
            strongSelf.loadTransferMethodTypes(country: strongSelf.selectedCountry,
                                               currency: strongSelf.selectedCurrency)
        }
    }

    /// Handles the selection currency event at GenericTableView
    private func selectCurrencyHandler() -> SelectTransferMethodTypeView.SelectItemHandler {
        return { [weak self]  (currency) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.selectedCurrency = currency.value
            strongSelf.loadTransferMethodTypes(country: strongSelf.selectedCountry,
                                               currency: strongSelf.selectedCurrency)
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

    private func loadTransferMethodTypes(country: String, currency: String) {
        sectionData.removeAll()
        guard let result = transferMethodConfigurationKey?.transferMethodTypes(countryCode: country,
                                                                               currencyCode: currency),
            !result.isEmpty else {
                view.showAlert(message: String(format: "no_transfer_method_available_error_message".localized(),
                                               country.localized(),
                                               currency))
                return
        }
        sectionData = result
        view.transferMethodTypeTableViewReloadData()
    }

    private func loadCurrency(for country: String) {
        guard let firstCurrency = transferMethodConfigurationKey?
            .currencies(from: country)?.min(by: { $0.name < $1.name })
            else {
                view.showAlert(message: String(format: "no_currency_available_error_message".localized(),
                                               country.localized()))
                selectedCurrency = ""
                view.countryCurrencyTableViewReloadData()
                return
        }
        selectedCurrency = firstCurrency.code
        view.countryCurrencyTableViewReloadData()
    }

    private func loadTranferMethodConfigurationCountries() -> [CountryCurrencyCellConfiguration]? {
        return transferMethodConfigurationKey?.countries()?
            .map { CountryCurrencyCellConfiguration(title: $0.name, value: $0.code) }
            .sorted { $0.title  < $1.title }
    }

    private func loadTranferMethodConfigurationCurrencies(for countryCode: String)
        -> [CountryCurrencyCellConfiguration]? {
            return transferMethodConfigurationKey?.currencies(from: countryCode)?
                .map { CountryCurrencyCellConfiguration(title: $0.name, value: $0.code) }
                .sorted { $0.title  < $1.title }
    }
}
