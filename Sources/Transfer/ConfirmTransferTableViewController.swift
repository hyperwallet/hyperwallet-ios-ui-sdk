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
public final class ConfirmTransferTableViewController: UITableViewController, UITextFieldDelegate {
    private var presenter: ConfirmTransferPresenter!
    private var transferMethod: HyperwalletTransferMethod
    private var transfer: HyperwalletTransfer

    private let registeredCells: [(type: AnyClass, id: String)] = [
        (ListTransferMethodTableViewCell.self, ListTransferMethodTableViewCell.reuseIdentifier),
        (ConfirmTransferForeignExchangeCell.self, ConfirmTransferForeignExchangeCell.reuseIdentifier),
        (ConfirmTransferButtonCell.self, ConfirmTransferButtonCell.reuseIdentifier)
    ]

    init(transferMethod: HyperwalletTransferMethod, transfer: HyperwalletTransfer) {
        self.transferMethod = transferMethod
        self.transfer = transfer
        super.init(nibName: nil, bundle: nil)
    }

    // swiftlint:disable unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "transfer_funds".localized()
        largeTitle()
        setViewBackgroundColor()
        navigationItem.backBarButtonItem = UIBarButtonItem.back

        // setup table view
        setUpAddTransferTableView()

        presenter = ConfirmTransferPresenter(view: self)
        presenter.initializeSections(transferMethod: transferMethod, transfer: transfer)
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
        switch section.confirmTransferSectionHeader {
        case .destination:
            if let tableViewCell = cell as? ListTransferMethodTableViewCell,
                let destinationData = section as? ConfirmTransferDestinationData,
                let configuration = destinationData.configuration {
                tableViewCell.configure(configuration: configuration)
            }

        case .foreignExchange:
            if let tableViewCell = cell as? ConfirmTransferForeignExchangeCell,
                let foreignExchangeData = section as? ConfirmTransferForeignExchangeData {
                tableViewCell.textLabel?.text = foreignExchangeData.rows[indexPath.row].title
                tableViewCell.detailTextLabel?.text = foreignExchangeData.rows[indexPath.row].value
            }

        case .summary:
            print("summary")

        case .notes:
            print("notes")

        case .button:
            if let tableViewCell = cell as? ConfirmTransferButtonCell, section is ConfirmTransferButtonData {
                tableViewCell.textLabel?.text = "confirm_transfer_button".localized()
                tableViewCell.textLabel?.textAlignment = .center
                let tap = UITapGestureRecognizer(target: self, action: #selector(clickTransferFunds))
                tableViewCell.textLabel?.isUserInteractionEnabled = true
                tableViewCell.textLabel?.addGestureRecognizer(tap)
            }
        }
            return cell
    }

    @objc
    private func clickTransferFunds(sender: UITapGestureRecognizer) {
        print("Transer Fund!")
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
        tableView.accessibilityIdentifier = "confirmTransferTableView"
        tableView.allowsSelection = false
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

extension ConfirmTransferTableViewController: ConfirmTransferView {
}
