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

/// Lists the user's transfer methods (bank account, bank card, PayPal account, prepaid card, paper check).
///
/// The user can deactivate and add a new transfer method.
public final class ListTransactionViewController: UITableViewController {
    private var spinnerView: SpinnerView?
    private var presenter: ListTransactionViewPresenter!
    private var isLoadingFirstTime = true
    private let listTransactionCellIdentifier = "ListTransactionCellIdentifier"
    private var lastContentOffset: CGFloat = 0

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "title_accounts".localized()
        largeTitle()
        setViewBackgroundColor()

        navigationItem.backBarButtonItem = UIBarButtonItem.back
        // setup table view
        presenter = ListTransactionViewPresenter(view: self)
        setupTransactionTableView()
        presenter.listTransferMethod()
    }

    // MARK: - Transfer method list table view dataSource and delegate
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count is: \(presenter.currentNumberOfCells)")
        return presenter.currentNumberOfCells
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: listTransactionCellIdentifier, for: indexPath)

        if let listTransferMethodCell = cell as? ListTransactionTableViewCell {
//            if isLoadingCell(for: indexPath) {
//                listTransferMethodCell.configure(configuration: .none)
//            } else {
                listTransferMethodCell.configure(configuration: presenter.getCellConfiguration(for: indexPath.row))
//            }
        }
        return cell
    }

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.height
    }

    private func setupTransactionTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableFooterView = UIView()
        tableView.isHidden = true
        tableView.register(ListTransactionTableViewCell.self,
                           forCellReuseIdentifier: listTransactionCellIdentifier)
    }
}

extension ListTransactionViewController: ListTransactionView {
    func loadTransactions(with newIndexPathsToReload: [IndexPath]?) {
        // 1
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            tableView.isHidden = false
            tableView.reloadData()
            return
        }
        // 2
        //let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        tableView.beginUpdates()
        tableView.insertRows(at: newIndexPathsToReload, with: .automatic)
        tableView.endUpdates()
        //tableView.reloadRows(at: indexPathsToReload, with: .automatic)
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

extension ListTransactionViewController {
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height &&
            presenter.transferMethodPagination?.links.contains(where: { $0.params.rel == "next" }) ?? false {
            presenter.listTransferMethod()
        }
        //print("Scroll: \(distanceFromBottom)")
    }

//    override public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if (self.lastContentOffset > scrollView.contentOffset.y) {
//            if presenter.transferMethodPagination?.links.contains(where: { $0.params.rel == "previous" }) ?? false {
//                presenter.listTransferMethod(false)
//            }
//        } else if (self.lastContentOffset < scrollView.contentOffset.y) {
//            if presenter.transferMethodPagination?.links.contains(where: { $0.params.rel == "next" }) ?? false {
//                presenter.listTransferMethod()
//            }
//        }
//
//        // update the new position acquired
//        self.lastContentOffset = scrollView.contentOffset.y
//    }

//    override public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if presenter.transferMethodPagination?.links.contains(where: { $0.params.rel == "next" }) ?? false {
//            presenter.listTransferMethod()
//        }
//    }

}

private extension ListTransactionViewController {
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        print("indexPath.row is \(indexPath.row)")
        print("presenter.currentCount is \(presenter.currentNumberOfCells)")
        return indexPath.row >= presenter.currentNumberOfCells
    }

    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}
