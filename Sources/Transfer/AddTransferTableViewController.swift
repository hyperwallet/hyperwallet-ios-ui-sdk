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
public final class AddTransferTableViewController: UITableViewController, UITextFieldDelegate {
    private var presenter: AddTransferPresenter!
    private var selectedTransferMethod: HyperwalletTransferMethod!

    private let registeredCells: [(type: AnyClass, id: String)] = [
        (ListTransferMethodTableViewCell.self, ListTransferMethodTableViewCell.reuseIdentifier),
        (AddTransferUserInputCell.self, AddTransferUserInputCell.reuseIdentifier),
        (AddTransferNextCell.self, AddTransferNextCell.reuseIdentifier)
    ]

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "transfer_funds".localized()
        largeTitle()
        setViewBackgroundColor()
        navigationItem.backBarButtonItem = UIBarButtonItem.back

        // setup table view
        setUpAddTransferTableView()

        presenter = AddTransferPresenter(view: self)
        presenter.loadTransferMethods()
    }

    override public func viewWillAppear(_ animated: Bool) {
        hideKeyboardWhenTappedAround()
    }

    // MARK: - Transfer method list table view dataSource and delegate
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData[section].rowCount
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellConfiguration(indexPath)
    }

    private func getCellConfiguration(_ indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = presenter.sectionData[indexPath.section].cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let section = presenter.sectionData[indexPath.section]
        switch section.addTransferSectionHeader {
        case .destination:
            if let tableViewCell = cell as? ListTransferMethodTableViewCell,
                let destinationData = section as? AddTransferDestinationData,
                let configuration = destinationData.configuration {
                tableViewCell.accessoryType = .disclosureIndicator
                tableViewCell.configure(configuration: configuration)
            }

        case .amount:
            if let tableViewCell = cell as? AddTransferUserInputCell,
                let userInputData = section as? AddTransferUserInputData {
                let row = userInputData.rows[indexPath.row]

                tableViewCell.selectionStyle = UITableViewCell.SelectionStyle.none
                if indexPath.row == 0 {
                    if let textField = tableViewCell.subviews.first(where: { $0 is UITextField }) as? UITextField {
                        textField.text = ""
                    } else {
                        let amountTextField = createAmountTextField(tableViewCell)
                        tableViewCell.addSubview(amountTextField)
                    }

                    tableViewCell.detailTextLabel?.text = row.value
                } else {
                    tableViewCell.textLabel?.text = row.title
                }
            }

        case .button:
            if let tableViewCell = cell as? AddTransferNextCell, section is AddTransferButtonData {
                tableViewCell.textLabel?.text = "add_transfer_next_button".localized()
                tableViewCell.textLabel?.textAlignment = .center
                let tap = UITapGestureRecognizer(target: self, action: #selector(clickNext))
                tableViewCell.textLabel?.isUserInteractionEnabled = true
                tableViewCell.textLabel?.addGestureRecognizer(tap)
            }
        }
        return cell
    }

    @objc
    private func clickNext(sender: UITapGestureRecognizer) {
        // TODO we should implement a callback to navigate to the next page once the response is returned from server,
        // we just mock it for now since the core is not ready yet.
        let foreignExchangeOne = HyperwalletForeignExchange(sourceAmount: "100.00",
                                                            sourceCurrency: "CAD",
                                                            destinationAmount: "70.00",
                                                            destinationCurrency: "USD",
                                                            rate: "0.7")
        let foreignExchangeTwo = HyperwalletForeignExchange(sourceAmount: "120.00",
                                                            sourceCurrency: "CAD",
                                                            destinationAmount: "110.00",
                                                            destinationCurrency: "USD",
                                                            rate: "0.86")

        let transefer = HyperwalletTransfer(amount: "100.00",
                                            fee: "2.00",
                                            destinationCurrency: "USD",
                                            foreignExchanges: [foreignExchangeOne, foreignExchangeTwo])
        let confirmTransferController = ConfirmTransferTableViewController(transferMethod: selectedTransferMethod,
                                                                           transfer: transefer)
        navigationController?.pushViewController(confirmTransferController, animated: true)
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if presenter.sectionData[indexPath.section].addTransferSectionHeader == AddTransferSectionHeader.destination,
            let addTransferDestinationData = presenter.sectionData[indexPath.section] as? AddTransferDestinationData {
            let viewController = SelectTransferMethodTableViewController(transferMethods: presenter.transferMethods)
            viewController.shouldMarkCellAction = { transferMethodToken in
                addTransferDestinationData.configuration?.transferMethodToken == transferMethodToken }
            viewController.selectedHandler = { transferMethod in
                self.showAddTransfer(with: transferMethod)
            }
            navigationController?.pushViewController(viewController, animated: true)

            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sectionData[section].title
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return Theme.Cell.largeHeight

        default:
            return Theme.Cell.smallHeight
        }
    }

    private func setUpAddTransferTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.accessibilityIdentifier = "addTransferTableView"
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
    }

    private func createAmountTextField(_ tableViewCell: AddTransferUserInputCell) -> UITextField {
        //TODO text field alignment is not working for landscape mode, consider using customized cell instead of .value1
        let amountTextField = UITextField(frame: CGRect(x: tableViewCell.separatorInset.left,
                                                        y: 0,
                                                        width: tableViewCell.bounds.width / 2,
                                                        height: tableViewCell.bounds.height))
        amountTextField.font = tableViewCell.textLabel?.font
        amountTextField.keyboardType = UIKeyboardType.numberPad
        amountTextField.placeholder = "transfer_amount".localized()
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
        return amountTextField
    }

    @objc
    private func amountTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
}

extension AddTransferTableViewController: AddTransferView {
    func showLoading() {
//        if let view = self.navigationController?.view {
//            spinnerView = HyperwalletUtilViews.showSpinner(view: view)
//        }
    }

    func hideLoading() {
//        if let spinnerView = self.spinnerView {
//            HyperwalletUtilViews.removeSpinner(spinnerView)
//        }
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self, error: error)
        errorView.show(retry)
    }

    func showProcessing() {
       // processingView = HyperwalletUtilViews.showProcessing()
    }

    func dismissProcessing(handler: @escaping () -> Void) {
    }

    func showConfirmation(handler: @escaping (() -> Void)) {
    }

    func showAddTransfer(with transferMethod: HyperwalletTransferMethod) {
        selectedTransferMethod = transferMethod
        presenter.initializeSections(with: transferMethod)
        tableView.reloadData()
    }

    func notifyTransferMethodDeactivated(_ hyperwalletStatusTransition: HyperwalletStatusTransition) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferMethodDeactivated,
                                            object: self,
                                            userInfo: [UserInfo.statusTransition: hyperwalletStatusTransition])
        }
    }
}
