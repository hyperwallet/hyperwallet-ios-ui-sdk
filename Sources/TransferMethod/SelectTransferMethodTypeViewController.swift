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

/// Lists all transfer method types available based on the country, currency and profile type to create a new transfer
/// method (bank account, bank card, PayPal account, prepaid card, paper check).
public final class SelectTransferMethodTypeViewController: UITableViewController {
    // MARK: - Outlets
    private var countryCurrencyTableView: UITableView!

    // MARK: - Properties
    /// The completion handler will be performed after a new transfer method has been created.
    public var createTransferMethodHandler: ((HyperwalletTransferMethod) -> Void)?
    private var spinnerView: SpinnerView?
    private var presenter: SelectTransferMethodTypePresenter!
    private var countryCurrencyView: CountryCurrencyTableView!

    // MARK: - Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "add_account_title".localized()
        largeTitle()
        setViewBackgroundColor()

        navigationItem.backBarButtonItem = UIBarButtonItem.back

        presenter = SelectTransferMethodTypePresenter(view: self)

        setupCountryCurrencyTableView()
        setupTransferMethodTypeTableView()

        presenter.loadTransferMethodKeys()
    }

    // MARK: - Setup Layout
    private func setupTransferMethodTypeTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.accessibilityIdentifier = "transferMethodTableView"
        tableView.register(SelectTransferMethodTypeCell.self,
                           forCellReuseIdentifier: SelectTransferMethodTypeCell.reuseId)
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
        footerView.backgroundColor = tableView.separatorColor
        tableView.tableFooterView = footerView
    }

    func setupCountryCurrencyTableView() {
        countryCurrencyTableView = UITableView(frame: .zero, style: .grouped)
        countryCurrencyView = CountryCurrencyTableView(presenter)
        countryCurrencyTableView.register(CountryCurrencyCell.self,
                                          forCellReuseIdentifier: CountryCurrencyCell.reuseId)
        countryCurrencyTableView.backgroundColor = Theme.ViewController.backgroundColor
        countryCurrencyTableView.dataSource = countryCurrencyView
        countryCurrencyTableView.delegate = countryCurrencyView
        countryCurrencyTableView.isScrollEnabled = false
    }
}

extension SelectTransferMethodTypeViewController {
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.transferMethodTypesCount
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.transferMethodTypesCount > 0 ? 1:0
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectTransferMethodTypeCell.reuseId, for: indexPath)
        if let transferMethodCell = cell as? SelectTransferMethodTypeCell {
            transferMethodCell.configure(configuration: presenter.getCellConfiguration(for: indexPath.row))
        }

        return cell
    }
}

extension SelectTransferMethodTypeViewController {
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return countryCurrencyTableView
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Theme.Cell.rowHeight * CGFloat(presenter.countryCurrencyCount) + Theme.Cell.headerHeight
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.navigateToAddTransferMethod(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.height
    }
}

// MARK: - SelectTransferMethodView
extension SelectTransferMethodTypeViewController: SelectTransferMethodTypeView {
    func transferMethodTypeTableViewReloadData() {
        tableView.reloadData()
    }

    func countryCurrencyTableViewReloadData() {
        countryCurrencyTableView.reloadData()
    }

    func navigateToAddTransferMethodController(country: String,
                                               currency: String,
                                               profileType: String,
                                               transferMethodType: String) {
        let addTransferMethodController = AddTransferMethodViewController(country,
                                                                          currency,
                                                                          profileType,
                                                                          transferMethodType)

        addTransferMethodController.createTransferMethodHandler = {
            (transferMethod: HyperwalletTransferMethod) -> Void in
            self.createTransferMethodHandler?(transferMethod)
        }

        navigationController?.pushViewController(addTransferMethodController, animated: true)
    }

    func showLoading() {
        if let view = self.navigationController?.view {
            spinnerView = HyperwalletUtilViews.showSpinner(view: view)
        }
    }

    func hideLoading() {
        if let spinnerView = self.spinnerView {
            HyperwalletUtilViews.removeSpinner(spinnerView)
        }
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self, error: error)
        errorView.show(retry)
    }

    func showAlert(message: String?) {
        HyperwalletUtilViews.showAlert(self, message: message, actions: UIAlertAction.close(self))
    }

    func showGenericTableView(items: [CountryCurrencyCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping (_ value: CountryCurrencyCellConfiguration) -> Void,
                              markCellHandler: @escaping (_ value: CountryCurrencyCellConfiguration) -> Bool,
                              filterContentHandler: @escaping ((_ items: [CountryCurrencyCellConfiguration],
        _ searchText: String)
        -> [CountryCurrencyCellConfiguration])
        ) {
        let genericTableView = GenericTableViewController<CountryCurrencyCell, CountryCurrencyCellConfiguration>()
        genericTableView.title = title
        genericTableView.items = items
        genericTableView.selectedHandler = selectItemHandler
        genericTableView.shouldMarkCellAction = markCellHandler
        genericTableView.filterContentForSearchTextAction = filterContentHandler
        show(genericTableView, sender: self)
    }
}

// MARK: Country and Currency - UITableViewDataSource UITableViewDelegate
final class CountryCurrencyTableView: NSObject {
    weak var presenter: SelectTransferMethodTypePresenter!

    init(_ presenter: SelectTransferMethodTypePresenter) {
        super.init()
        self.presenter = presenter
    }
}

extension CountryCurrencyTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.countryCurrencyCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryCurrencyCell.reuseId, for: indexPath)

        cell.accessoryType = .disclosureIndicator

        if let countryCurrencyCell = cell as? CountryCurrencyCell {
            countryCurrencyCell.item = presenter.getCountryCurrencyCellConfiguration(for: indexPath.row)
        }

        return cell
    }
}

extension CountryCurrencyTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.rowHeight
    }

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
