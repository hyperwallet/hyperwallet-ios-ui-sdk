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
final class ListReceiptController: UITableViewController {
    private var spinnerView: SpinnerView?
    private var presenter: ListReceiptPresenter!
    private let sectionTitleDateFormat = "MMMM yyyy"
    private var loadMoreReceipts = false
    private lazy var emptyListLabel: UILabel = view.setUpEmptyListLabel(text: "mobileNoTransactions".localized())
    private lazy var emptyPPCListLabel: UILabel =
        view.setUpEmptyListLabel(text: "mobilePrepaidCardNoTransactions".localized())
    private var uiSegmentedControl: UISegmentedControl?
    private var selectedSegmentedControl = 0

    override public func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        setupListReceiptTableView()
        presenter.listReceipts()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentNavigationItem: UINavigationItem = tabBarController?.navigationItem ?? navigationItem
        currentNavigationItem.backBarButtonItem = UIBarButtonItem.back
        titleDisplayMode(.always, for: "transactions".localized())
    }

    private func initializePresenter() {
        presenter = ListReceiptPresenter(view: self,
                                         prepaidCardToken:
            initializationData?[InitializationDataField.prepaidCardToken] as? String,
                                         showAllAvailableSources:
            initializationData?[InitializationDataField.showAllAvailableSources] as? Bool)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            removeCoordinator()
        }
    }

    @objc
    func segmentControlHandler(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        presenter.selectedSegmentControlItem = presenter.segmentedControlItems[index]
        selectedSegmentedControl = index
        presenter.loadReceiptsForSelectedToken()
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
            listReceiptCell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.height
    }

    /// Returns title for header
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = presenter.sectionData[section].key
        return date.formatDateToString(dateFormat: sectionTitleDateFormat)
    }

    // MARK: list receipt table view delegate
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hyperwalletReceipt = presenter.sectionData[indexPath.section].value[indexPath.row]
        coordinator?.navigateToNextPage(initializationData: [InitializationDataField.receipt: hyperwalletReceipt])
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

    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.height
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.backgroundColor = Theme.UITableViewController.backgroundColor
        tableView.separatorColor = Theme.Cell.separatorColor
        tableView.register(ReceiptTransactionCell.self,
                           forCellReuseIdentifier: ReceiptTransactionCell.reuseIdentifier)
    }
}

// MARK: `ListReceiptView` delegate
extension ListReceiptController: ListReceiptView {
    /// Loads the receipts
    func reloadData() {
        if presenter.selectedSegmentControlItem?.receiptSourceType == .prepaidCard {
            emptyListLabel = view.setUpEmptyListLabel(text: "mobilePrepaidCardNoTransactions".localized())
        } else {
            emptyListLabel = view.setUpEmptyListLabel(text: "mobileNoTransactions".localized())
        }
        if presenter.sectionData.isNotEmpty {
            toggleEmptyListView(hideLabel: true)
        } else {
            toggleEmptyListView(hideLabel: false)
        }

        tableView.reloadData()
    }

    func showLoading() {
        spinnerView = HyperwalletUtilViews.showSpinner(view: view)
        spinnerView?.backgroundColor = UIColor.clear
    }

    func reloadTableViewHeader() {
        if presenter.showAllAvailableSources && presenter.segmentedControlItems.count > 1 {
            let segementedControl = UISegmentedControl(frame: CGRect(x: 30,
                                                                    y: 40,
                                                                    width: tableView.frame.size.width,
                                                                    height: 36))
            var index = 0
            presenter.segmentedControlItems.forEach { segementedControlItem in
               segementedControl.insertSegment(withTitle: segementedControlItem.segmentedControlHeader,
                                               at: index,
                                               animated: true)
               index += 1
            }
            segementedControl.addTarget(self,
                                       action: #selector(segmentControlHandler(sender:)),
                                       for: .valueChanged)
            segementedControl.selectedSegmentIndex = selectedSegmentedControl
            tableView.tableHeaderView = segementedControl
        }
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

    private func toggleEmptyListView(hideLabel: Bool) {
        if presenter.selectedSegmentControlItem?.receiptSourceType == .prepaidCard {
            emptyPPCListLabel.isHidden = hideLabel
            emptyListLabel.isHidden = true
        } else {
            emptyListLabel.isHidden = hideLabel
            emptyPPCListLabel.isHidden = true
        }
    }
}
