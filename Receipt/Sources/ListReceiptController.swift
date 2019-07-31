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

/// Lists the user's transaction history
///
/// The user can click a receipt in the list for more information
public final class ListReceiptController: UITableViewController {
    public var subscriptionToken: Any?

    private var spinnerView: SpinnerView?
    private var presenter: ListReceiptPresenter!
    private var defaultHeaderHeight = CGFloat(38.0)
    private let sectionTitleDateFormat = "MMMM yyyy"
    private var loadMoreReceipts = false

    private lazy var emptyListLabel: UILabel = view.setUpEmptyListLabel(text: "empty_list_receipt_message".localized())

    init() {
        super.init(nibName: nil, bundle: nil)
        presenter = ListReceiptPresenter(view: self)
    }

    init(prepaidCardToken: String) {
        super.init(nibName: nil, bundle: nil)
        presenter = ListReceiptPresenter(view: self, prepaidCardToken: prepaidCardToken)
    }

    // swiftlint:disable unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "title_receipts".localized()
        largeTitle()
        setViewBackgroundColor()

        navigationItem.backBarButtonItem = UIBarButtonItem.back
        setupListReceiptTableView()
        presenter.listReceipts()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        subscriptionToken = setupWith(tableView: tableView)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let subscriptionToken = subscriptionToken {
            NotificationCenter.default.removeObserver(subscriptionToken)
        }
    }

    // MARK: list receipt table view data source
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData[section].value.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptTransactionCell.reuseIdentifier,
                                                 for: indexPath)
        if let listReceiptCell = cell as? ReceiptTransactionCell {
            listReceiptCell.configure(presenter.sectionData[indexPath.section].value[indexPath.row])
        }
        return cell
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderIn(section: section)
    }

    // MARK: list receipt table view delegate
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hyperwalletReceipt = presenter.sectionData[indexPath.section].value[indexPath.row]
        let receiptDetailViewController = ReceiptDetailController(with: hyperwalletReceipt)
        navigationController?.pushViewController(receiptDetailViewController, animated: true)
    }

    override public func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
        let lastSectionIndex = presenter.sectionData.count - 1
        if indexPath.section == lastSectionIndex
            && indexPath.row == presenter.sectionData[lastSectionIndex].value.count - 1
            && !presenter.areAllReceiptsLoaded {
            loadMoreReceipts = true
        }
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let header = titleForHeaderIn(section: section),
            header.height(withConstrainedWidth: self.view.frame.width,
                          font: UIFont.preferredFont(forTextStyle: .body)) > defaultHeaderHeight else {
                            return defaultHeaderHeight
        }

        return UITableView.automaticDimension
    }

    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if loadMoreReceipts {
            presenter.listReceipts()
            loadMoreReceipts = false
        }
    }

    // MARK: set up list receipt table view
    private func setupListReceiptTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.tableFooterView = UIView()
        tableView.register(ReceiptTransactionCell.self,
                           forCellReuseIdentifier: ReceiptTransactionCell.reuseIdentifier)
    }

    private func titleForHeaderIn(section: Int) -> String? {
        let date = presenter.sectionData[section].key
        return date.formatDateToString(dateFormat: sectionTitleDateFormat)
    }
}

// MARK: `ListReceiptView` delegate
extension ListReceiptController: ListReceiptView {
    /// Loads the receipts
    func loadReceipts() {
        if presenter.sectionData.isNotEmpty {
            toggleEmptyListView(hideLabel: true)
        } else {
            toggleEmptyListView(hideLabel: false)
        }

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

    private func toggleEmptyListView(hideLabel: Bool) {
        emptyListLabel.isHidden = hideLabel
    }
}

extension ListReceiptController: ContentSizeCategoryAdjustable {
    public var defaultCellHeight: CGFloat {
        return Theme.Cell.mediumHeight
    }
}
