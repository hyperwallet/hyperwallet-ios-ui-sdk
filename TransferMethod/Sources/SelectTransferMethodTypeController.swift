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
#endif
import HyperwalletSDK
import UIKit

/// Lists all transfer method types available based on the country, currency and profile type to create a new transfer
/// method (bank account, bank card, PayPal account, prepaid card, paper check).
final class SelectTransferMethodTypeController: UITableViewController {
    // MARK: - Outlets
    private var countryCurrencyTableView: UITableView!
    private var spinnerView: SpinnerView?
    private var presenter: SelectTransferMethodTypePresenter!
    private var countryCurrencyView: CountryCurrencyTableView!
    private var forceUpdate: Bool = false

    private func initializeData() {
        if let forceUpdate = initializationData?[InitializationDataField.forceUpdateData] as? Bool {
            self.forceUpdate = forceUpdate
        }
    }
    // MARK: - Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        initializeData()
        initializePresenter()
        setupCountryCurrencyTableView()
        setupTransferMethodTypeTableView()
        presenter.loadTransferMethodKeys(forceUpdate)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentNavigationItem: UINavigationItem = tabBarController?.navigationItem ?? navigationItem
        currentNavigationItem.backBarButtonItem = UIBarButtonItem.back
        titleDisplayMode(.always, for: "add_account_title".localized())
    }

    private func initializePresenter() {
        presenter = SelectTransferMethodTypePresenter(self)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            removeCoordinator()
        }
    }

    // MARK: - Setup Layout
    private func setupTransferMethodTypeTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.accessibilityIdentifier = "selectTransferMethodTypeTable"
        tableView.register(SelectTransferMethodTypeCell.self,
                           forCellReuseIdentifier: SelectTransferMethodTypeCell.reuseIdentifier)
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.smallHeight
        footerView.backgroundColor = tableView.separatorColor
        tableView.tableFooterView = footerView
    }

    func setupCountryCurrencyTableView() {
        countryCurrencyTableView = UITableView(frame: .zero, style: .grouped)
        countryCurrencyView = CountryCurrencyTableView(presenter)
        countryCurrencyTableView.register(CountryCurrencyCell.self,
                                          forCellReuseIdentifier: CountryCurrencyCell.reuseIdentifier)
        countryCurrencyTableView.backgroundColor = Theme.UITableViewController.backgroundColor
        countryCurrencyTableView.rowHeight = UITableView.automaticDimension
        countryCurrencyTableView.estimatedRowHeight = Theme.Cell.smallHeight
        countryCurrencyTableView.dataSource = countryCurrencyView
        countryCurrencyTableView.delegate = countryCurrencyView
        countryCurrencyTableView.isScrollEnabled = false
    }
}

extension SelectTransferMethodTypeController {
    /// Returns  transfer method count
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData.count
    }
    /// Returns tableview section count
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.countryCurrencySectionData.isNotEmpty ? 1:0
    }
    /// Display transfer methods
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectTransferMethodTypeCell.reuseIdentifier,
                                                 for: indexPath)
        if let transferMethodCell = cell as? SelectTransferMethodTypeCell {
            transferMethodCell.configure(configuration: presenter.sectionData[indexPath.row])
        }

        return cell
    }
}
   // MARK: - TableViewController delegate
extension SelectTransferMethodTypeController {
    /// Returns  headerview
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return countryCurrencyTableView
    }
    /// Returns height of headerview
    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let blankHeaderHeight = countryCurrencyTableView.estimatedRowHeight / 2.5
        return countryCurrencyTableView
            .estimatedRowHeight * CGFloat(presenter.countryCurrencySectionData.count) + blankHeaderHeight
    }
    /// To select transfer method
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.navigateToAddTransferMethod(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SelectTransferMethodView
extension SelectTransferMethodTypeController: SelectTransferMethodTypeView {
    func reloadTransferMethodTypeData() {
        tableView.reloadData()
    }

    func reloadCountryCurrencyData() {
        countryCurrencyTableView.reloadData()
    }

    func navigateToAddTransferMethodController(country: String,
                                               currency: String,
                                               profileType: String,
                                               transferMethodTypeCode: String) {
        var initializationData = [InitializationDataField: Any]()
        initializationData[InitializationDataField.country]  = country
        initializationData[InitializationDataField.currency]  = currency
        initializationData[InitializationDataField.profileType]  = profileType
        initializationData[InitializationDataField.transferMethodTypeCode]  = transferMethodTypeCode
        initializationData[InitializationDataField.forceUpdateData] = true
        coordinator?.navigateToNextPage(initializationData: initializationData)
    }

    func showLoading() {
        spinnerView = HyperwalletUtilViews.showSpinner(view: view)
    }

    func hideLoading() {
        if let spinnerView = self.spinnerView {
            HyperwalletUtilViews.removeSpinner(spinnerView)
        }
    }

    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self,
                                  error: error,
                                  pageName: pageName,
                                  pageGroup: pageGroup)
        errorView.show(retry)
    }

    func showAlert(message: String?) {
        HyperwalletUtilViews.showAlert(self, message: message, actions: UIAlertAction.close(self))
    }

    func showGenericTableView(items: [GenericCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler,
                              filterContentHandler: @escaping FilterContentHandler) {
        let genericTableView = GenericController<CountryCurrencyCell, GenericCellConfiguration>()
        genericTableView.title = title
        genericTableView.items = items
        genericTableView.selectedHandler = selectItemHandler
        genericTableView.shouldMarkCellAction = markCellHandler
        genericTableView.filterContentForSearchTextAction = filterContentHandler
        show(genericTableView, sender: self)
    }
}

// MARK: Country and Currency - UITableViewDataSource UITableViewDelegate
/// The TableView to display country and currency
final class CountryCurrencyTableView: NSObject {
    weak var presenter: SelectTransferMethodTypePresenter!

    init(_ presenter: SelectTransferMethodTypePresenter) {
        super.init()
        self.presenter = presenter
    }
}
// MARK: - TableViewController Data source
extension CountryCurrencyTableView: UITableViewDataSource {
    /// Returns number of country and currency
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.countryCurrencySectionData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryCurrencyCell.reuseIdentifier, for: indexPath)

        cell.accessoryType = .disclosureIndicator

        if let countryCurrencyCell = cell as? CountryCurrencyCell {
            countryCurrencyCell.item = presenter.getCountryCurrencyConfiguration(indexPath: indexPath)
        }

        return cell
    }
}
// MARK: - TableViewController delegate
extension CountryCurrencyTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.performShowSelectCountryOrCurrencyView(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension SelectTransferMethodTypeController {
    /// This function will navigate back from next page and pass the control back to it's caller
    override public func didFlowComplete(with response: Any) {
        if response as? HyperwalletTransferMethod != nil {
            coordinator?.navigateBackFromNextPage(with: response)
            removeCoordinator()
            flowDelegate?.didFlowComplete(with: response)
        }
    }
}
