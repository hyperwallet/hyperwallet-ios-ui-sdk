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
import TransferMethodRepository
import TransferRepository
import UserRepository
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
        case allSourcesReceipts
        case transferFunds
        case transferFundsSource
        case transferFundsPPC

        var title: String {
            switch self {
            case .paymentDetails: return "Payment Details"
            case .listTransferMethod: return "List Transfer Methods"
            case .selectTransferMethod: return "Select Transfer Method"
            case .addTransferMethod: return "Add Transfer Method"
            case .userReceipts: return "List User Receipts"
            case .prepaidCardReceipts: return "List Prepaid Card Receipts"
            case .allSourcesReceipts: return "List All Receipts"
            case .transferFunds: return "Transfer Funds"
            case .transferFundsSource: return "Transfer Funds Source"
            case .transferFundsPPC: return "Transfer Funds PPC"
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
            case .allSourcesReceipts: return "List All Receipts"
            case .transferFunds: return "Transfer Funds"
            case .transferFundsSource: return "Transfer Funds Source"
            case .transferFundsPPC: return "Transfer Funds PPC"
            }
        }
    }

    private var exampleList: [Example: () -> Void]!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem.back

        let baseUrl = Bundle.main.infoDictionary!["BASE_URL"] as! String
        let userToken = Bundle.main.infoDictionary!["USER_TOKEN"] as! String

        createTransferMethodObserver()
        removeTransferMethodObserver()

        // Setup
        HyperwalletUI.setup(IntegratorAuthenticationProvider(baseUrl, userToken))

        exampleList = [
            .listTransferMethod: showExampleListTransferMethod,
            .selectTransferMethod: showExampleSelectTransferMethod,
            .addTransferMethod: showExampleAddTransferMethod,
            .userReceipts: showExampleUserReceipts,
            .prepaidCardReceipts: showExamplePrepaidCardReceipts,
            .allSourcesReceipts: showExampleAllAvailableReceipts,
            .transferFunds: showExampleTransferFunds,
            .transferFundsSource: showExampleTransferFundsSource,
            .transferFundsPPC: showExampleTransferFundsPPC
        ]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.item {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopCell", for: indexPath)
                as! TopCell
            cell.emailLabel.text = "johndoe@domain.com"
            cell.nameLabel.text = "John Doe"
            cell.phoneLabel.text = "+1 123-122-3213"
            cell.nameLabel.textColor = Theme.Label.subtitleColor
            cell.emailLabel.textColor = Theme.Label.subtitleColor
            cell.phoneLabel.textColor = Theme.Label.subtitleColor
            cell.iconLabel.font = UIFont(name: "hw_mobile_ui_sdk_icons", size: 51)
            cell.iconLabel.text = "\u{E023}"
            cell.iconLabel.textColor = Theme.Label.subtitleColor
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
                as! HeadlineCell
            cell.headlineTextLabel.textColor = Theme.Label.subtitleColor
            cell.headlineTitleLabel.textColor = Theme.Label.subtitleColor
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let example = Example(rawValue: indexPath.item),
            let showExample = exampleList[example] else {
                return
        }
        showExample()
    }

    // MARK: - Main menu actions
    private func showExampleTransferFundsPPC() {
        let prepaidCardToken = Bundle.main.infoDictionary!["PREPAID_CARD_TOKEN"] as! String
        let clientTransferId = UUID().uuidString.lowercased()
        let coordinator = HyperwalletUI.shared
            .createTransferFromPrepaidCardCoordinator(clientTransferId: clientTransferId,
                                                      sourceToken: prepaidCardToken,
                                                      parentController: self)
        coordinator.navigate()
    }

    private func showExampleTransferFunds() {
        let clientTransferId = UUID().uuidString.lowercased()
        let coordinator = HyperwalletUI.shared
            .createTransferFromUserCoordinator(clientTransferId: clientTransferId, parentController: self)
        coordinator.navigate()
    }

    private func showExampleTransferFundsSource() {
        let clientTransferId = UUID().uuidString.lowercased()
        let coordinator = HyperwalletUI.shared
            .createTransferFromAllAvailableSourcesCoordinator(clientTransferId: clientTransferId,
                                                              parentController: self)
        coordinator.navigate()
    }

    private func showExamplePrepaidCardReceipts() {
        let prepaidCardToken = Bundle.main.infoDictionary!["PREPAID_CARD_TOKEN"] as! String
        let coordinator = HyperwalletUI.shared
            .listPrepaidCardReceiptCoordinator(parentController: self, prepaidCardToken: prepaidCardToken)
        coordinator.navigate()
    }

    private func showExampleUserReceipts() {
        let coordinator = HyperwalletUI.shared.listUserReceiptCoordinator(parentController: self)
        coordinator.navigate()
    }

    private func showExampleAllAvailableReceipts() {
        let coordinator = HyperwalletUI.shared.listAllAvailableSourcesReceiptCoordinator(parentController: self)
        coordinator.navigate()
    }

    private func showExampleAddTransferMethod() {
        if let country = ProcessInfo.processInfo.environment["COUNTRY"],
            let currency = ProcessInfo.processInfo.environment["CURRENCY"],
            let accountType = ProcessInfo.processInfo.environment["ACCOUNT_TYPE"],
            let profileType = ProcessInfo.processInfo.environment["PROFILE_TYPE"] {
            let coordinator = HyperwalletUI.shared
                .addTransferMethodCoordinator(country, currency, profileType, accountType, parentController: self)
            coordinator.navigate()
        } else {
            let coordinator = HyperwalletUI.shared.addTransferMethodCoordinator(
                "US", "USD", "INDIVIDUAL", "BANK_ACCOUNT", parentController: self)
            coordinator.navigate()
        }
    }

    private func showExampleSelectTransferMethod() {
        let coordinator = HyperwalletUI.shared.selectTransferMethodTypeCoordinator(parentController: self)
        coordinator.navigate()
    }

    private func showExampleListTransferMethod() {
        let coordinator = HyperwalletUI.shared.listTransferMethodCoordinator(parentController: self)
        coordinator.navigate()
    }

    // MARK: - Notifications
    func createTransferMethodObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(transferMethodAdded(notification:)),
                                               name: Notification.Name.transferMethodAdded,
                                               object: nil)
    }

    func removeTransferMethodObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(transferMethodDeactivated(notification:)),
                                               name: Notification.Name.transferMethodDeactivated,
                                               object: nil)
    }

    func didCreateTransferMethod(transferMethod: HyperwalletTransferMethod) {
        print("Transfer method has been created successfully")
    }

    func didCreateTransfer(transfer: HyperwalletTransfer) {
        print("Transfer has been created successfully")
    }

    @objc
    func transferMethodAdded(notification: Notification) {
        print("Transfer method has been added successfully")
    }

    @objc
    func transferMethodDeactivated(notification: Notification) {
        print("Transfer method has been deleted successfully")
    }

    override public func didFlowComplete(with response: Any) {
        if let transferMethod = response as? HyperwalletTransferMethod {
            navigationController?.popViewController(animated: false)
            self.didCreateTransferMethod(transferMethod: transferMethod)
        } else if let transfer = response as? HyperwalletTransfer {
            didCreateTransfer(transfer: transfer)
        } else if let statusTransition = response as? HyperwalletStatusTransition,
            let transition = statusTransition.transition {
            if transition == HyperwalletStatusTransition.Status.scheduled {
                navigationController?.popViewController(animated: false)
            }
        }
    }
}
