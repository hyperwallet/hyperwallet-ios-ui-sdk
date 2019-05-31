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

/// Lists the user's transaction historys
///
/// The user can click a receipt in the list for more information
public final class ListReceiptViewController: UITableViewController {
    private var spinnerView: SpinnerView?
    private var presenter: ListReceiptViewPresenter!
    private let listReceiptCellIdentifier = "ListReceiptCellIdentifier"
    private var defaultHeaderHeight = CGFloat(38.0)
    private let sectionTitleDateFormat = "MMMM yyyy"
    private var fetchMoreData: Bool = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "title_receipts".localized()
        largeTitle()
        setViewBackgroundColor()

        navigationItem.backBarButtonItem = UIBarButtonItem.back
        presenter = ListReceiptViewPresenter(view: self)
        setupListReceiptTableView()
        presenter.listReceipt()
    }

    // MARK: list receipt table view data source
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.groupedSectionArray[section].value.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listReceiptCellIdentifier, for: indexPath)
        if let listReceiptCell = cell as? ListReceiptTableViewCell {
            listReceiptCell.configure(configuration: presenter.getCellConfiguration(for: indexPath.row,
                                                                                    in: indexPath.section))
        }
        return cell
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.groupedSectionArray.count
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = presenter.groupedSectionArray[section].key
        return date.formatDateToStringWith(format: sectionTitleDateFormat)
    }

    // MARK: list receipt table view delegate
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO will navigate to the recepit detail page
    }

    override public func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
        let lastSectionIndex = presenter.groupedSectionArray.count - 1
        if indexPath.section == lastSectionIndex
            && indexPath.row == presenter.groupedSectionArray[lastSectionIndex].value.count - 1
            && !presenter.isFetchCompleted {
            fetchMoreData = true
        }
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultHeaderHeight
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.mediumHeight
    }

    // MARK: set up list receipt table view
    private func setupListReceiptTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableFooterView = UIView()
        tableView.register(ListReceiptTableViewCell.self,
                           forCellReuseIdentifier: listReceiptCellIdentifier)
    }

    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if fetchMoreData {
            presenter.listReceipt()
            fetchMoreData = false
        }
    }
}

// MARK: `ListReceiptView` delegate
extension ListReceiptViewController: ListReceiptView {
    func loadReceipts() {
        tableView.reloadData()
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
}
