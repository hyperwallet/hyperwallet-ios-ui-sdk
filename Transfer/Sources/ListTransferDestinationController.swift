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

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAddButton))
        titleDisplayMode(.always, for: "transfer_select_destination".localized())
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

    private func initializePresenter() {
        presenter = ListTransferDestinationPresenter(view: self)
    }

    // MARK: - Transfer method list table view dataSource and delegate
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTransferDestinationCell.reuseIdentifier,
                                                 for: indexPath)
        cell.accessoryType = .none

        if let transferMethod = initializationData?[InitializationDataField.transferMethod]
            as? HyperwalletTransferMethod, transferMethod.token == presenter.sectionData[indexPath.row].token {
            cell.accessoryType = .checkmark
        }

        if let listTransferDestinationCell = cell as? ListTransferDestinationCell {
            listTransferDestinationCell.configure(transferMethod: presenter.sectionData[indexPath.row])
        }
        return cell
    }

    /// To select the transfer method
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hyperwalletTransferMethod = presenter.sectionData[indexPath.row]
        navigationController?.popViewController(animated: true)
        flowDelegate?.didFlowComplete(with: hyperwalletTransferMethod)
    }

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
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
