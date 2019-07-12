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
public final class ListTransferMethodTableViewController: UITableViewController {
    private var spinnerView: SpinnerView?
    private var processingView: ProcessingView?
    private var presenter: ListTransferMethodPresenter!

    /// The completion handler will be performed after a new transfer method has been created.
    public var createTransferMethodHandler: ((HyperwalletTransferMethod) -> Void)?

    private lazy var emptyListLabel: UILabel = view.setUpEmptyListLabel(text: "empty_list_transfer_method_message"
                                                                              .localized())
    private lazy var addAccountButton: UIButton = view.setUpEmptyListButton(text: "add_account_title".localized(),
                                                                            firstItem: emptyListLabel)

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "title_accounts".localized()
        largeTitle()
        setViewBackgroundColor()

        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAddButton))

        // setup table view
        presenter = ListTransferMethodPresenter(view: self)
        presenter.listTransferMethod()
        setupTransferMethodTableView()
    }

    @objc
    private func didTapAddButton(sender: AnyObject) {
        addTransferMethod()
    }

    // MARK: - Transfer method list table view dataSource and delegate
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTransferMethodTableViewCell.reuseIdentifier,
                                                 for: indexPath)
        if let listTransferMethodCell = cell as? ListTransferMethodTableViewCell {
            listTransferMethodCell.configure(transferMethod: presenter.sectionData[indexPath.row])
        }
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if presenter.transferMethodExists(at: indexPath.row) {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            let removeHandler = { (alertAction: UIAlertAction) -> Void in
                self.showConfirmationAlert(title: "remove_transfer_method_confirmation_title".localized(),
                                           message: "remove_transfer_method_confirmation_message".localized(),
                                           transferMethodIndex: indexPath.row)
            }

            let removeAction = UIAlertAction.remove(removeHandler,
                                                    "remove_transfer_method_confirmation_title".localized())
                .addIcon(imageName: "trash")

            optionMenu.addAction(removeAction)
            optionMenu.addAction(UIAlertAction.cancel())

            navigationController?.present(optionMenu, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Theme.Cell.largeHeight
    }

    private func addTransferMethod() {
        let controller = SelectTransferMethodTypeTableViewController()
        controller.createTransferMethodHandler = {
            [weak self] (transferMethod: HyperwalletTransferMethod) -> Void in
            // refresh transfer method list
            self?.presenter.listTransferMethod()
            self?.createTransferMethodHandler?(transferMethod)
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    private func setupTransferMethodTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableFooterView = UIView()
        tableView.register(ListTransferMethodTableViewCell.self,
                           forCellReuseIdentifier: ListTransferMethodTableViewCell.reuseIdentifier)
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

extension ListTransferMethodTableViewController: ListTransferMethodView {
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

    func showProcessing() {
        processingView = HyperwalletUtilViews.showProcessing()
    }

    func dismissProcessing(handler: @escaping () -> Void) {
        processingView?.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            handler()
        }
    }

    func showConfirmation(handler: @escaping (() -> Void)) {
        processingView?.hide(with: .complete)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            handler()
        }
    }

    func showTransferMethods() {
        if presenter.sectionData.isNotEmpty() {
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
                                            userInfo: [UserInfo.statusTransition: hyperwalletStatusTransition])
        }
    }

    private func toggleEmptyListView(hideLabel: Bool = true, hideButton: Bool = true) {
        emptyListLabel.isHidden = hideLabel
        addAccountButton.isHidden = hideButton
    }
}
