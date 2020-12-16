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

/// Lists the user's transfer methods (bank account, bank card, PayPal account, prepaid card, paper check).
///
/// The user can deactivate and add a new transfer method.
final class ListTransferMethodController: UITableViewController {
    private var spinnerView: SpinnerView?
    private var processingView: ProcessingView?
    private var presenter: ListTransferMethodPresenter!

    private lazy var emptyListLabel: UILabel = view.setUpEmptyListLabel(text: "emptyStateAddTransferMethod"
        .localized())
    private lazy var addAccountButton: UIButton =
        view.setUpEmptyListButton(text: "mobileAddTransferMethodHeader".localized(), firstItem: emptyListLabel)

    override public func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        // setup table view
        setupTransferMethodTableView()
        presenter.listTransferMethods()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentNavigationItem: UINavigationItem = tabBarController?.navigationItem ?? navigationItem
        currentNavigationItem.backBarButtonItem = UIBarButtonItem.back
        currentNavigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                   target: self,
                                                                   action: #selector(didTapAddButton))
        titleDisplayMode(.always, for: "mobileTransferMethodsHeader".localized())
        self.navigationController?.presentationController?.delegate = self
    }

    private func initializePresenter() {
        presenter = ListTransferMethodPresenter(view: self)
    }

    @objc
    private func didTapAddButton(sender: AnyObject) {
        addTransferMethod()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            removeCoordinator()
        }
    }

    // MARK: - Transfer method list table view dataSource and delegate
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTransferMethodCell.reuseIdentifier,
                                                 for: indexPath)
        if let listTransferMethodCell = cell as? ListTransferMethodCell {
            listTransferMethodCell.configure(transferMethod: presenter.sectionData[indexPath.row])

            listTransferMethodCell.accessoryView = nil
        }
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(presenter.sectionData[indexPath.row].isPrepaidCard()) {
            let cellRect = tableView.rectForRow(at: indexPath)
            let actionSheetController = UIAlertController(title: nil,
                                                          message: nil,
                                                          preferredStyle: .actionSheet)
            actionSheetController.addAction(UIAlertAction(title: "edit".localized(),
                                                          style: .default,
                                                          handler: { _ -> Void in
                                                            let coordinator = HyperwalletUI
                                                                .shared
                                                                .updateTransferMethodCoordinator(
                                                                self.presenter.sectionData[indexPath.row].token ?? "",
                                                                parentController: self)
                                                            coordinator.navigate()
                                                            }))
            actionSheetController.addAction(UIAlertAction(title: "remove".localized(),
                                                          style: .default,
                                                          handler: { _ -> Void in
                                                            self.showConfirmationAlert(
                                                                title: "mobileAreYouSure".localized(),
                                                                message: "",
                                                                transferMethodIndex: indexPath.row
                                                            )}))
            actionSheetController.addAction(UIAlertAction(title: "cancelButtonLabel".localized(),
                                                          style: .cancel,
                                                          handler: nil))

            actionSheetController.popoverPresentationController?.sourceView = tableView
            actionSheetController.popoverPresentationController?.sourceRect = cellRect
            actionSheetController.popoverPresentationController?.permittedArrowDirections = .up
            navigationController?.present(actionSheetController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    private func addTransferMethod() {
        coordinator?.navigateToNextPage(initializationData: nil)
    }

    private func setupTransferMethodTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableFooterView = UIView()
        tableView.register(ListTransferMethodCell.self,
                           forCellReuseIdentifier: ListTransferMethodCell.reuseIdentifier)
         if #available(iOS 11, *) {
             tableView.rowHeight = UITableView.automaticDimension
         } else {
            tableView.rowHeight = Theme.Cell.largeHeight
         }
        tableView.estimatedRowHeight = Theme.Cell.smallHeight
        tableView.backgroundColor = Theme.UITableViewController.backgroundColor
    }

    private func showConfirmationAlert(title: String?, message: String, transferMethodIndex: Int) {
        let removeHandler = { [weak self] (alertAction: UIAlertAction) -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.presenter.deactivateTransferMethod(at: transferMethodIndex)
        }

        HyperwalletUtilViews.showAlert(self,
                                       title: title,
                                       message: message,
                                       actions: UIAlertAction.remove(removeHandler),
                                       UIAlertAction.cancel())
    }
}

extension ListTransferMethodController: ListTransferMethodView {
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

    func showProcessing() {
        processingView = HyperwalletUtilViews.showProcessing()
    }

    func dismissProcessing(handler: @escaping () -> Void) {
        processingView?.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            handler()
        }
    }

    func showConfirmation(handler: @escaping () -> Void) {
        processingView?.hide(with: .complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            handler()
        }
    }

    func reloadData() {
        if presenter.sectionData.isNotEmpty {
            toggleEmptyListView()
        } else {
            addAccountButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
            toggleEmptyListView(hideLabel: false, hideButton: false)
        }

        tableView.reloadData()
    }

    func notifyTransferMethodDeactivated(_ hyperwalletStatusTransition: HyperwalletStatusTransition) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferMethodDeactivated,
                                            object: self,
                                            userInfo: [UserInfo.transferMethodDeactivated: hyperwalletStatusTransition])
        }
    }

    private func toggleEmptyListView(hideLabel: Bool = true, hideButton: Bool = true) {
        emptyListLabel.isHidden = hideLabel
        addAccountButton.isHidden = hideButton
    }
}

extension ListTransferMethodController {
    /// The callback to refresh transfer method list
    override public func didFlowComplete(with response: Any) {
        if response as? HyperwalletTransferMethod != nil {
            coordinator?.navigateBackFromNextPage(with: response)
            // refresh transfer method list
            presenter.listTransferMethods()
        }
    }
}
