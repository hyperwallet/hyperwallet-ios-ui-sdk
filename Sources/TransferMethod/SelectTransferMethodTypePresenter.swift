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

protocol SelectTransferMethodTypeView: class {
    func showGenericTableView(items: [CountryCurrencyCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping (_ value: CountryCurrencyCellConfiguration) -> Void,
                              markCellHandler: @escaping (_ value: CountryCurrencyCellConfiguration) -> Bool,
                              filterContentHandler: @escaping ((_ items: [CountryCurrencyCellConfiguration],
        _ searchText: String)
        -> [CountryCurrencyCellConfiguration]))

    func navigateToAddTransferMethodController(country: String,
                                               currency: String,
                                               profileType: String,
                                               detail: TransferMethodTypeDetail)
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
    private var transferMethodConfigurationKeyResult: HyperwalletTransferMethodConfigurationKeyResult?
    private var transferMethodTypes = [TransferMethodTypeDetail]()
    private var countryCurrencyTitles = [String]()
    private (set) var selectedCountry: String = "" {
        didSet {
            view.countryCurrencyTableViewReloadData()
            loadCurrency(for: selectedCountry)
        }
    }
    private (set) var selectedCurrency: String = "" {
        didSet {
            view.countryCurrencyTableViewReloadData()

            loadTransferMethodTypes(country: selectedCountry,
                                    currency: selectedCurrency)
        }
    }
    /// Returns the amount of items in `countryCurrencyTitles`
    var countryCurrencyCount: Int {
        return countryCurrencyTitles.count
    }

    /// Returns the amount of items in `transferMethodTypes`
    var transferMethodTypesCount: Int {
        return transferMethodTypes.count
    }

    /// Initialize SelectTransferMethodPresenter
    init(view: SelectTransferMethodTypeView) {
        self.view = view
    }

    /// Return the `TransferMethodTypeDetail` based on the index
    func getCellConfiguration(for index: Int) -> SelectTransferMethodTypeConfiguration {
        let detail = transferMethodTypes[index]
        let feesProcessingTime = detail.formatFeesProcessingTime()
        let transferMethodIcon = HyperwalletIcon.of(detail.transferMethodType).rawValue

        return SelectTransferMethodTypeConfiguration(transferMethodType: detail.transferMethodType.lowercased(),
                                                     feesProcessingTime: feesProcessingTime,
                                                     transferMethodIconFont: transferMethodIcon)
    }

    /// Return the countryCurrency item composed by the tuple (title and value)
    func getCountryCurrencyCellConfiguration(for index: Int) -> CountryCurrencyCellConfiguration {
        return CountryCurrencyCellConfiguration(title: countryCurrencyTitles[index].localized(),
                                                value: countryCurrencyValues(at: index))
    }

    /// Display all the select Country or Currency based on the index
    func performShowSelectCountryOrCurrencyView(index: Int) {
        if index == 0 {
            showSelectCountryView()
        } else {
            showSelectCurrencyView()
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
                                                   detail: transferMethodTypes[index])
    }

    private func countryCurrencyValues(at index: Int) -> String {
        return (index == 0 ? selectedCountry.localized() : selectedCurrency )
    }

    private func defaultCountry() -> String? {
        let countries = loadTranferMethodConfigurationCountries()

        guard countries.isNotEmpty() else {
            return nil
        }

        if let userCountry = user?.country, countries.contains(where: { $0.value == userCountry }) {
            return userCountry
        }

        return countries.first?.value
    }

    private func transferMethodConfigurationKeyResultHandler()
        -> (HyperwalletTransferMethodConfigurationKeyResult?, HyperwalletErrorType?) -> Void {
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
                    strongSelf.countryCurrencyTitles = ["Country", "Currency"]
                    strongSelf.transferMethodConfigurationKeyResult = result

                    guard let country = strongSelf.defaultCountry() else {
                        strongSelf.view.showAlert(message: "no_country_available_error_message".localized())
                        return
                    }
                    strongSelf.selectedCountry = country
                }
            }
    }

    /// Shows the Select Country View
    private func showSelectCountryView() {
        view.showGenericTableView(items: self.loadTranferMethodConfigurationCountries(),
                                  title: "select_transfer_method_country".localized(),
                                  selectItemHandler: selectCountryHandler(),
                                  markCellHandler: countryMarkCellHandler(),
                                  filterContentHandler: filterContentHandler())
    }

    /// Shows the Select Currency View
    private func showSelectCurrencyView() {
        if selectedCountry.isEmpty {
            self.view.showAlert(message: "select_a_country_message".localized())
            return
        }
        view.showGenericTableView(items: self.loadTranferMethodConfigurationCurrencies(for: selectedCountry),
                                  title: "select_transfer_method_currency".localized(),
                                  selectItemHandler: selectCurrencyHandler(),
                                  markCellHandler: currencyMarkCellHandler(),
                                  filterContentHandler: filterContentHandler())
    }

    /// Handles the selection country event at GenericTableView
    /// when selecting a country, a default currency should be selected automatically as well.
    /// Eventually the transfer methods should be shown correspondingly
    private func selectCountryHandler() -> (_ value: CountryCurrencyCellConfiguration) -> Void {
        return { [weak self] (country) in
            self?.selectedCountry = country.value
        }
    }

    /// Handles the selection currency event at GenericTableView
    private func selectCurrencyHandler() -> (_ value: CountryCurrencyCellConfiguration) -> Void {
        return { [weak self]  (currency) in
            self?.selectedCurrency = currency.value
        }
    }

    private func filterContentHandler() -> ((_ items: [CountryCurrencyCellConfiguration], _ searchText: String)
        -> [CountryCurrencyCellConfiguration]) {
            return {(items, searchText) in
                items.filter {
                    // search by decription
                    $0.title.lowercased().contains(searchText.lowercased()) ||
                        //or code
                        $0.value.lowercased().contains(searchText.lowercased())
                }
            }
    }

    private func countryMarkCellHandler() -> ((_ value: CountryCurrencyCellConfiguration) -> Bool) {
        return { [weak self] item in
            self?.selectedCountry == item.value
        }
    }

    private func currencyMarkCellHandler() -> ((_ value: CountryCurrencyCellConfiguration) -> Bool) {
        return { [weak self] item in
            self?.selectedCurrency == item.value
        }
    }

    private func loadTransferMethodTypes(country: String, currency: String) {
        transferMethodTypes = [TransferMethodTypeDetail]()
        guard let profileType = user?.profileType?.rawValue,
            let result = transferMethodConfigurationKeyResult?.transferMethodTypes(country: country,
                                                                                   currency: currency,
                                                                                   profileType: profileType),
            !result.isEmpty else {
                view.showAlert(message: String(format: "no_transfer_method_available_error_message".localized(),
                                               country.localized(),
                                               currency))
                return
        }

        for transferMethodType in result {
            let transferMethodTypeDetail = transferMethodConfigurationKeyResult!
                .populateTransferMethodTypeDetail(country: country,
                                                  currency: currency,
                                                  profileType: profileType,
                                                  transferMethodType: transferMethodType)
            transferMethodTypes.append(transferMethodTypeDetail)
        }
        view.transferMethodTypeTableViewReloadData()
    }

    private func loadCurrency(for country: String) {
        let currencies = loadTranferMethodConfigurationCurrencies(for: country)
        guard let firstCurrency = currencies.first else {
            view.showAlert(message: String(format: "no_currency_available_error_message".localized(),
                                           country.localized()))
            selectedCurrency = ""
            return
        }
        selectedCurrency = firstCurrency.value
    }

    private func loadTranferMethodConfigurationCountries() -> [CountryCurrencyCellConfiguration] {
        guard let keyResult = transferMethodConfigurationKeyResult else {
            return [CountryCurrencyCellConfiguration]()
        }

        return keyResult.countries()
            .map { CountryCurrencyCellConfiguration(title: $0.localized(), value: $0) }
            .sorted { $0.title  < $1.title }
    }

    private func loadTranferMethodConfigurationCurrencies(for countryCode: String)
        -> [CountryCurrencyCellConfiguration] {
            var currencies = [CountryCurrencyCellConfiguration]()

            if let keyResult = transferMethodConfigurationKeyResult {
                currencies = keyResult.currencies(from: countryCode)
                    .map { CountryCurrencyCellConfiguration(title: $0.localized(), value: $0) }
                    .sorted { $0.title  < $1.title }
            }

            return currencies
    }
}

