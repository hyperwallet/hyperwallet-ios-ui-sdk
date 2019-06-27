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
public final class CreateTransferTableViewController: UITableViewController {
    typealias SelectItemHandler = (_ value: SelectDestinationCellConfiguration) -> Void
    typealias MarkCellHandler = (_ value: SelectDestinationCellConfiguration) -> Bool
    private var presenter: CreateTransferViewPresenter!
    private var spinnerView: SpinnerView?
    private var sourceToken: String
    private var clientTransferId: String
    private var transferAmount: String?
    private var transferDescription: String?

    private let registeredCells: [(type: AnyClass, id: String)] = [
        (SelectDestinationTableViewCell.self, SelectDestinationTableViewCell.reuseIdentifier),
        (CreateTransferUserInputCell.self, CreateTransferUserInputCell.reuseIdentifier),
        (CreateTransferButtonCell.self, CreateTransferButtonCell.reuseIdentifier)
    ]

    public init(sourceToken: String, clientTransferId: String) {
        self.sourceToken = sourceToken
        self.clientTransferId = clientTransferId
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
        setUpCreateTransferTableView()
        hideKeyboardWhenTappedAround()

        presenter = CreateTransferViewPresenter(view: self)
        presenter.loadTransferMethods()
    }

    private func setUpCreateTransferTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.accessibilityIdentifier = "createTransferTableView"
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
    }
}

// MARK: - Create transfer table view dataSource
extension CreateTransferTableViewController {
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionData.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData[section].rowCount
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellConfiguration(indexPath)
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sectionData[section].title
    }

    private func getCellConfiguration(_ indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = presenter.sectionData[indexPath.section].cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let section = presenter.sectionData[indexPath.section]
        switch section.createTransferSectionHeader {
        case .destination:
            if let tableViewCell = cell as? SelectDestinationTableViewCell,
                let destinationData = section as? CreateTransferDestinationData,
                let configuration = destinationData.configuration {
                tableViewCell.accessoryType = .disclosureIndicator
                tableViewCell.configure(configuration: configuration)
            }

        case .amount:
            if let tableViewCell = cell as? CreateTransferUserInputCell,
                let userInputData = section as? CreateTransferUserInputData {
                let row = userInputData.rows[indexPath.row]

                tableViewCell.selectionStyle = UITableViewCell.SelectionStyle.none
                if indexPath.row == 0 {
                    if let textField = tableViewCell.subviews.first(where: { $0 is UITextField }) as? UITextField {
                        textField.text = ""
                    } else {
                        addAmountTextFieldTo(tableViewCell)
                    }

                    tableViewCell.detailTextLabel?.attributedText = formatDetailTextLabel(currency: row.value!)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(tapTransferAll))
                    tableViewCell.detailTextLabel?.isUserInteractionEnabled = true
                    tableViewCell.detailTextLabel?.addGestureRecognizer(tap)
                } else {
                    if let textField = tableViewCell.subviews.first(where: { $0 is UITextField }) as? UITextField {
                        textField.text = ""
                    } else {
                        addDescriptionTextFieldTo(tableViewCell)
                    }
                }
            }

        case .button:
            if let tableViewCell = cell as? CreateTransferButtonCell, section is CreateTransferButtonData {
                tableViewCell.textLabel?.text = "add_transfer_next_button".localized()
                tableViewCell.textLabel?.textAlignment = .center
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapNext))
                tableViewCell.textLabel?.isUserInteractionEnabled = true
                tableViewCell.textLabel?.addGestureRecognizer(tap)
            }
        }
        return cell
    }

    private func addAmountTextFieldTo(_ tableViewCell: CreateTransferUserInputCell) {
        //TODO text field alignment is not working for landscape mode, consider using customized cell instead of .value1
        let amountTextField = UITextField(frame: CGRect(x: tableViewCell.separatorInset.left,
                                                        y: 0,
                                                        width: tableViewCell.bounds.width / 2,
                                                        height: tableViewCell.bounds.height))
        amountTextField.font = tableViewCell.textLabel?.font
        amountTextField.keyboardType = UIKeyboardType.numberPad
        amountTextField.placeholder = "transfer_amount".localized()
        amountTextField.addTarget(self, action: #selector(amountDidChange), for: .editingChanged)
        tableViewCell.addSubview(amountTextField)
    }

    private func addDescriptionTextFieldTo(_ tableViewCell: CreateTransferUserInputCell) {
        //TODO text field alignment is not working for landscape mode, consider using customized cell instead of .value1
        let descriptionTextField = UITextField(frame: CGRect(x: tableViewCell.separatorInset.left,
                                                        y: 0,
                                                        width: tableViewCell.bounds.width,
                                                        height: tableViewCell.bounds.height))
        descriptionTextField.font = tableViewCell.textLabel?.font
        descriptionTextField.placeholder = "transfer_description".localized()
        descriptionTextField.addTarget(self, action: #selector(descriptionDidChange), for: .editingChanged)
        tableViewCell.addSubview(descriptionTextField)
    }

    @objc
    private func amountDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
            transferAmount = amountString
        }
    }

    @objc
    private func descriptionDidChange(_ textField: UITextField) {
        transferDescription = textField.text
    }

    private func formatDetailTextLabel(currency: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        attributedText.append(value: currency,
                              font: Theme.Label.bodyFontMedium,
                              color: Theme.Label.subTitleColor)

        attributedText.append(value: "\tTransfer All",
                              font: Theme.Label.bodyFontMedium,
                              color: Theme.Label.subTitleColor)

        return attributedText
    }

    @objc
    private func tapTransferAll(sender: UITapGestureRecognizer) {
        // TODO remove the mocked response
        let transefer = HyperwalletTransfer(sourceToken: sourceToken,
                                            destinationToken: presenter.selectedTransferMethod
                                                .getField(fieldName: .token) as? String,
                                            clientTransferId: clientTransferId,
                                            sourceAmount: nil,
                                            destinationAmount: nil,
                                            destinationFeeAmount: nil,
                                            notes: nil,
                                            destinationCurrency: nil,
                                            foreignExchanges: nil,
                                            token: "trf-12345")

        presenter.createTransfer(transefer)
    }

    @objc
    private func tapNext(sender: UITapGestureRecognizer) {
        // TODO remove the mocked response
//        let foreignExchangeOne = HyperwalletForeignExchange(sourceAmount: "100.00",
//                                                            sourceCurrency: "CAD",
//                                                            destinationAmount: "70.00",
//                                                            destinationCurrency: "USD",
//                                                            rate: "0.7")
//        let foreignExchangeTwo = HyperwalletForeignExchange(sourceAmount: "120.00",
//                                                            sourceCurrency: "CAD",
//                                                            destinationAmount: "110.00",
//                                                            destinationCurrency: "USD",
//                                                            rate: "0.86")

        let transefer = HyperwalletTransfer(sourceToken: sourceToken,
                                            destinationToken: presenter.selectedTransferMethod
                                                             .getField(fieldName: .token) as? String,
                                            clientTransferId: clientTransferId,
                                            sourceAmount: transferAmount,
                                            destinationAmount: "20.00",
                                            destinationFeeAmount: nil,
                                            notes: transferDescription,
                                            destinationCurrency: presenter.selectedTransferMethod
                                                .getField(fieldName: .transferMethodCurrency) as? String,
                                            foreignExchanges: nil,
//                                            [foreignExchangeOne, foreignExchangeTwo],
                                            token: "trf-12345")

        presenter.createTransfer(transefer)
    }
}

// MARK: - Create transfer table view delegate
extension CreateTransferTableViewController {
    override public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // TODO error will display here
        return nil
    }

    override public func tableView(_ tableView: UITableView,
                                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Theme.Cell.headerHeight)
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return Theme.Cell.largeHeight

        default:
            return Theme.Cell.smallHeight
        }
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if presenter.sectionData[indexPath.section].createTransferSectionHeader == CreateTransferSectionHeader.destination,
            let addTransferDestinationData = presenter.sectionData[indexPath.section] as? CreateTransferDestinationData {
//            let viewController = SelectTransferMethodTableViewController(transferMethods: presenter.transferMethods)
//            viewController.shouldMarkCellAction = { transferMethodToken in
//                addTransferDestinationData.configuration?.transferMethodToken == transferMethodToken }
//            viewController.selectedHandler = { transferMethod in
//                self.showCreateTransfer(with: transferMethod)
//            }
//            navigationController?.pushViewController(viewController, animated: true)
            presenter.performShowDestinationAccountView()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: - CreateTransferView implementation
extension CreateTransferTableViewController: CreateTransferView {
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

    func showBusinessError(_ error: HyperwalletErrorType, _ handler: @escaping () -> Void) {
        // TODO show business error in footer 
    }

    func showCreateTransfer(with transferMethod: HyperwalletTransferMethod) {
//        selectedTransferMethod = transferMethod
        presenter.initializeSections()
        tableView.reloadData()
    }

    func showGenericTableView(items: [SelectDestinationCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler) {
        let genericTableView = GenericTableViewController<SelectDestinationTableViewCell, SelectDestinationCellConfiguration>()

        genericTableView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: nil)

        genericTableView.title = title
        genericTableView.items = items
        genericTableView.selectedHandler = selectItemHandler
        genericTableView.shouldMarkCellAction = markCellHandler
        show(genericTableView, sender: self)
    }

    func showScheduleTransfer(_ transfer: HyperwalletTransfer) {
        let scheduleTransferController = ScheduleTransferTableViewController(transferMethod: presenter.selectedTransferMethod,
                                                                             transfer: transfer)
        navigationController?.pushViewController(scheduleTransferController, animated: true)
    }

    func notifyTransferCreated(_ transfer: HyperwalletTransfer) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferCreated,
                                            object: self,
                                            userInfo: [UserInfo.transferCreated: transfer])
        }
    }
}
