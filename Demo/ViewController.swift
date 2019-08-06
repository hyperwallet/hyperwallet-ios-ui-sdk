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
import Receipt
import Transfer
import TransferMethod
#endif
import HyperwalletSDK
import os.log

import UIKit

class HeadlineCell: UITableViewCell {
    @IBOutlet var headlineTitleLabel: UILabel!
    @IBOutlet var headlineTextLabel: UILabel!
}

class TopCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var iconLabel: UILabel!
}

//swiftlint:disable force_cast
class ViewController: UITableViewController {
    enum Example: Int, CaseIterable {
        case paymentDetails
        case listTransferMethod
        case selectTransferMethod
        case addTransferMethod
        case userReceipts
        case prepaidCardReceipts
        case transferFunds
        case transferFundsPPC

        var title: String {
            switch self {
            case .paymentDetails: return "Payment Details"
            case .listTransferMethod: return "List Transfer Methods"
            case .selectTransferMethod: return "Select Transfer Method"
            case .addTransferMethod: return "Add Transfer Method"
            case .userReceipts: return "List User Receipts"
            case .prepaidCardReceipts: return "List Prepaid Card Receipts"
            case .transferFunds: return  "Transfer Funds"
            case .transferFundsPPC: return  "Transfer Funds PPC"
            }
        }

        var detail: String {
            switch self {
            case .paymentDetails: return "Configure how you want to get paid"
            case .listTransferMethod: return "List all the Transfer Methods"
            case .selectTransferMethod: return "Select the Transfer Method you want to add"
            case .addTransferMethod: return "Add the default Transfer Method"
            case .userReceipts: return "List User Receipts"
            case .prepaidCardReceipts: return "List Prepaid Card Receipts"
            case .transferFunds: return  "Transfer Funds"
            case .transferFundsPPC: return "Transfer Funds PPC"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem.back

        let baseUrl = Bundle.main.infoDictionary!["BASE_URL"] as! String
        let userToken = Bundle.main.infoDictionary!["USER_TOKEN"] as! String

        createTransferMethodObserver()
        removeTransferMethodObserver()
        createTransferObserver()

        // Setup
        HyperwalletUI.setup(IntegratorAuthenticationProvider(baseUrl, userToken))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.item {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopCell", for: indexPath)
                as! TopCell
            cell.emailLabel.text = "johndoe@domain.com"
            cell.nameLabel.text = "John Doe"
            cell.phoneLabel.text = "+1 123-122-3213"

            cell.nameLabel.textColor = Theme.Label.subTitleColor
            cell.emailLabel.textColor = Theme.Label.subTitleColor
            cell.phoneLabel.textColor = Theme.Label.subTitleColor
            cell.iconLabel.font = UIFont(name: "icomoon", size: 51)
            cell.iconLabel.text = "\u{E023}"
            cell.iconLabel.textColor = Theme.Label.subTitleColor

            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
                as! HeadlineCell
            cell.headlineTextLabel.textColor = Theme.Label.subTitleColor
            cell.headlineTitleLabel.textColor = Theme.Label.subTitleColor
            if let example = Example(rawValue: indexPath.item) {
                cell.headlineTextLabel?.text = example.title
                cell.headlineTitleLabel?.text = example.detail
            }

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            return 120.0

        default:
            return 80
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Example.allCases.count
    }

    //swiftlint:disable function_body_length
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: false)
        }
        guard let example = Example(rawValue: indexPath.item) else {
            return
        }
        switch example {
        case .listTransferMethod:
            let viewController = HyperwalletUI.shared.listTransferMethodController()

            navigationController?.pushViewController(viewController, animated: true)

        case .selectTransferMethod:
            let viewController = HyperwalletUI.shared.selectTransferMethodTypeController()
            viewController.createTransferMethodHandler = {
                (transferMethod: HyperwalletTransferMethod) -> Void in
                self.createTransferMethodHandler(transferMethod: transferMethod)
            }

            navigationController?.pushViewController(viewController, animated: true)

        case .addTransferMethod:
            if let country = ProcessInfo.processInfo.environment["COUNTRY"],
                let currency = ProcessInfo.processInfo.environment["CURRENCY"],
                let accountType = ProcessInfo.processInfo.environment["ACCOUNT_TYPE"],
                let profileType = ProcessInfo.processInfo.environment["PROFILE_TYPE"] {
                let viewController = HyperwalletUI.shared.addTransferMethodController(
                    country, currency, profileType, accountType)

                navigationController?.pushViewController(viewController, animated: true)
            } else {
                let viewController = HyperwalletUI.shared.addTransferMethodController(
                    "US", "USD", "INDIVIDUAL", "BANK_ACCOUNT")

                navigationController?.pushViewController(viewController, animated: true)
            }

        case .userReceipts:
            let viewController = HyperwalletUI.shared.listUserReceiptController()

            navigationController?.pushViewController(viewController, animated: true)

        case .prepaidCardReceipts:
            let prepaidCardToken = Bundle.main.infoDictionary!["PREPAID_CARD_TOKEN"] as! String
            let viewController = HyperwalletUI.shared.listPrepaidCardReceiptController(
                prepaidCardToken)

            navigationController?.pushViewController(viewController, animated: true)

        case .transferFunds:
            let clientTransferId = UUID().uuidString.lowercased()
            let viewController = HyperwalletUI.shared
                .createTransferFromUserController(clientTransferId: clientTransferId)

            navigationController?.pushViewController(viewController, animated: true)

        case .transferFundsPPC:
            let prepaidCardToken = Bundle.main.infoDictionary!["PREPAID_CARD_TOKEN"] as! String
            let clientTransferId = UUID().uuidString.lowercased()
            let viewController = HyperwalletUI.shared
                .createTransferFromPrepaidCardController(clientTransferId: clientTransferId, prepaidCardToken: prepaidCardToken)
            navigationController?.pushViewController(viewController, animated: true)

        default:
            let viewController = HyperwalletUI.shared.listTransferMethodController()

            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    // MARK: - Handlers
    func createTransferMethodHandler(transferMethod: HyperwalletTransferMethod) {
        print("Handler: Transfer method has been created successfully")
    }

    // MARK: - Notifications
    func createTransferMethodObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transferMethodAddedNotificationObserverHandler(notification:)),
            name: Notification.Name.transferMethodAdded,
            object: nil)
    }

    func removeTransferMethodObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transferMethodDeactivatedNotificationObserverHandler(notification:)),
            name: Notification.Name.transferMethodDeactivated,
            object: nil)
    }

    func createTransferObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transferCreatedNotificationObserverHandler(notification:)),
            name: Notification.Name.transferCreated,
            object: nil)
    }

    @objc
    func transferMethodAddedNotificationObserverHandler(notification: Notification) {
        print("Notification: Transfer method has been created successfully")
    }

    @objc
    func transferMethodDeactivatedNotificationObserverHandler(notification: Notification) {
        print("Notification: Transfer method has been deleted successfully")
    }

    @objc
    func transferCreatedNotificationObserverHandler(notification: Notification) {
        print("Notification: Transfer of funds has been created successfully")
    }
}
