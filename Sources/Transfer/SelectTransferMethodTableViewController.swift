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
public final class SelectTransferMethodTableViewController: UITableViewController {
    private var transferMethods: [HyperwalletTransferMethod]
    /// Event handler to indicate if the item cell should be marked
    var shouldMarkCellAction: ((_ value: String) -> Bool)?

    typealias SelectedHandler = (_ value: HyperwalletTransferMethod) -> Void
    /// Event handler to return the item selected
    var selectedHandler: SelectedHandler?

    init(transferMethods: [HyperwalletTransferMethod]) {
        self.transferMethods = transferMethods
        super.init(nibName: nil, bundle: nil)
    }

    // swiftlint:disable unavailable_function
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "title_accounts".localized()
        largeTitle()
        setViewBackgroundColor()

        navigationItem.backBarButtonItem = UIBarButtonItem.back

        setupTransferMethodTableView()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        scrollToSelectedRow()
    }

    // MARK: - Transfer method list table view dataSource and delegate
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transferMethods.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTransferMethodTableViewCell.reuseIdentifier,
                                                 for: indexPath)
        cell.accessoryType = .none
        if let listTransferMethodCell = cell as? ListTransferMethodTableViewCell,
            let cellConfiguration = getCellConfiguration(indexPath: indexPath) {
            listTransferMethodCell.configure(configuration: cellConfiguration)
            if shouldMarkCellAction?(cellConfiguration.transferMethodToken) ?? false {
                cell.accessoryType = .checkmark
            }
        }

        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Retrieve the item selected
        if let performTransferMethodSelected = selectedHandler {
            let transferMethod = transferMethods[indexPath.row]
            performTransferMethodSelected(transferMethod)
        }
        navigationController?.popViewController(animated: true)
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

    private func setupTransferMethodTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableFooterView = UIView()
        tableView.register(ListTransferMethodTableViewCell.self,
                           forCellReuseIdentifier: ListTransferMethodTableViewCell.reuseIdentifier)
    }

    func getCellConfiguration(indexPath: IndexPath) -> ListTransferMethodCellConfiguration? {
        if let transferMethod = transferMethods[safe: indexPath.row],
            let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
            let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
            return ListTransferMethodCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                additionalInfo: getAdditionalInfo(transferMethod),
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue,
                transferMethodToken: transferMethod.getField(fieldName: .token) as? String ?? "")
        }
        return nil
    }

    func getAdditionalInfo(_ transferMethod: HyperwalletTransferMethod) -> String? {
        var additionlInfo: String?
        switch transferMethod.getField(fieldName: .type) as? String {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .bankAccountId) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "BANK_CARD":
            additionlInfo = transferMethod.getField(fieldName: .cardNumber) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "PAYPAL_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .email) as? String

        default:
            break
        }
        return additionlInfo
    }

    func scrollToSelectedRow() {
        //TODO scrolling is not working properly, need to be fixed
        var selectedTransferMethod: Int?

        for index in transferMethods.indices {
            if shouldMarkCellAction?(transferMethods[index].getField(fieldName: .token) as? String ?? "") ?? false {
                selectedTransferMethod = index
                break
            }
        }

        guard let indexToScrollTo = selectedTransferMethod, indexToScrollTo < transferMethods.count else {
            return
        }
        self.tableView.scrollToRow(at: IndexPath(row: indexToScrollTo, section: 0), at: .middle, animated: false)
    }
}
