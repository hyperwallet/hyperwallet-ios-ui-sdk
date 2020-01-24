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

/// Lists user's transfer methods
final class ListTransferDestinationController: UITableViewController {
    private var spinnerView: SpinnerView?
    private var presenter: ListTransferDestinationPresenter!
    private var processingView: ProcessingView?
    private lazy var selectTransferMethodCoordinator = getSelectTransferMethodCoordinator()

    override public func viewDidLoad() {
        super.viewDidLoad()
        setViewBackgroundColor()
        initializePresenter()
        presenter.listTransferMethods()
        setupTransferMethodTableView()
    }

    override public func didFlowComplete(with response: Any) {
        if response as? HyperwalletTransferMethod != nil {
            coordinator?.navigateBackFromNextPage(with: response)
            flowDelegate?.didFlowComplete(with: response)
        }
    }

    @objc
    private func didTapAddButton(sender: AnyObject) {
        navigateToTransferMethodIfInitialized()
    }

    private func navigateToTransferMethodIfInitialized() {
        if let transferMethodCoordinator = selectTransferMethodCoordinator {
            transferMethodCoordinator.start(initializationData: nil, parentController: self)
            transferMethodCoordinator.navigate()
        } else {
            HyperwalletUtilViews.showAlert(self,
                                           title: "error".localized(),
                                           message: "transfer_error_no_transfer_method_module_initialized".localized())
        }
    }

    private func getSelectTransferMethodCoordinator() -> HyperwalletCoordinator? {
        return HyperwalletCoordinatorFactory.shared.getHyperwalletCoordinator(hyperwalletCoordinatorType:
            .selectTransferMethodType)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentNavigationItem: UINavigationItem = tabBarController?.navigationItem ?? navigationItem
        currentNavigationItem.backBarButtonItem = UIBarButtonItem.back
        titleDisplayMode(.always, for: "transfer_select_destination".localized())
    }

    private func initializePresenter() {
        presenter = ListTransferDestinationPresenter(view: self)
    }

    // MARK: set up list of transfer methods table view
    private func setupTransferMethodTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.smallHeight
        tableView.register(ListTransferDestinationCell.self,
                           forCellReuseIdentifier: ListTransferDestinationCell.reuseIdentifier)
    }
}

// MARK: `ListTransferDestinationView` delegate
extension ListTransferDestinationController: ListTransferDestinationView {
    /// Loads the transfer methods
    func showTransferMethods() {
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
}
