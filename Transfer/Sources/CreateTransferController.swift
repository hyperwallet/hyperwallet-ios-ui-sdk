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

/// Allows user to make a transfer.
///
/// Each transfer will be represented by an auto-generated, non-editable token that can be used
/// to retrieve the transfer resource.
final class CreateTransferController: UITableViewController {
    enum FooterSection: Int, CaseIterable {
        case destination, transfer, notes, button
    }

    private let footerIdentifier = "transferTableViewFooterViewIdentifier"
    private var spinnerView: SpinnerView?
    private lazy var selectTransferMethodCoordinator = getSelectTransferMethodCoordinator()
    private var presenter: CreateTransferPresenter!
    private let registeredCells: [(type: AnyClass, id: String)] = [
        (TransferDestinationCell.self, TransferDestinationCell.reuseIdentifier),
        (TransferAllFundsCell.self, TransferAllFundsCell.reuseIdentifier),
        (TransferAmountCell.self, TransferAmountCell.reuseIdentifier),
        (TransferButtonCell.self, TransferButtonCell.reuseIdentifier),
        (TransferNotesCell.self, TransferNotesCell.reuseIdentifier)
    ]

    override public func viewDidLoad() {
        super.viewDidLoad()
        setViewBackgroundColor()
        initializePresenter()
        setUpCreateTransferTableView()
        presenter.loadCreateTransfer()
        hideKeyboardWhenTappedAround()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentNavigationItem: UINavigationItem = tabBarController?.navigationItem ?? navigationItem
        currentNavigationItem.backBarButtonItem = UIBarButtonItem.back
        titleDisplayMode(.always, for: "transfer_funds".localized())
    }

    private func initializePresenter() {
        if let clientTransferId = initializationData?[InitializationDataField.clientTransferId] as? String {
            let sourceToken = initializationData?[InitializationDataField.sourceToken] as? String
            presenter = CreateTransferPresenter(clientTransferId, sourceToken, view: self)
        } else {
            fatalError("Required data not provided in initializePresenter")
        }
    }

    private func setUpCreateTransferTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.accessibilityIdentifier = "createTransferTableView"
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = Theme.Cell.smallHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.smallHeight

        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
        tableView.register(TransferTableViewFooterView.self,
                           forHeaderFooterViewReuseIdentifier: footerIdentifier)
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            removeCoordinator()
        }
    }
}

// MARK: - Create transfer table view dataSource
extension CreateTransferController {
    /// Returns tableview section count
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionData.count
    }
    /// Returns number of rows
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData[section].rowCount
    }
    /// Displays cell configuration
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellConfiguration(indexPath)
    }
    /// Returns the title for header
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sectionData[section].title
    }
    /// Returns the footer view of tableview
    override public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let attributedText = getAttributedFooterText(for: section)
        if attributedText == nil {
            return nil
        }
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: footerIdentifier) as? TransferTableViewFooterView else {
                return nil
        }
        view.footerLabel.adjustsFontForContentSizeCategory = true
        view.footerLabel.lineBreakMode = .byWordWrapping
        view.footerLabel.attributedText = attributedText
        return view
    }

    private func getAttributedFooterText(for section: Int) -> NSAttributedString? {
        let sectionData = presenter.sectionData[section]
        var attributedText: NSAttributedString?
        if  let transferSectionData = sectionData as? CreateTransferSectionTransferData {
            attributedText = format(footer: transferSectionData.footer, error: transferSectionData.errorMessage)
        } else {
            attributedText = format(error: sectionData.errorMessage)
        }
        return attributedText
    }

    private func format(footer: String? = nil, error: String? = nil) -> NSAttributedString? {
        var attributedText: NSMutableAttributedString! = nil
        if let footer = footer {
            attributedText = NSMutableAttributedString()
            attributedText.appendParagraph(value: footer,
                                           font: Theme.Label.footnoteFont,
                                           color: Theme.Label.subtitleColor)
        }
        if let error = error {
            if attributedText == nil {
                attributedText = NSMutableAttributedString()
            }
            attributedText.appendParagraph(value: error,
                                           font: Theme.Label.footnoteFont,
                                           color: Theme.Label.errorColor)
        }
        return attributedText
    }

    private func getCellConfiguration(_ indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifiers = presenter.sectionData[indexPath.section].cellIdentifiers
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifiers[indexPath.row], for: indexPath)
        let section = presenter.sectionData[indexPath.section].createTransferSectionHeader
        switch section {
        case .destination:
            getDestinationSectionCellConfiguration(cell, indexPath)

        case .transfer:
            getTransferSectionCellConfiguration(cell, indexPath)

        case .notes:
            getNotesSectionCellConfiguration(cell)

        case .button:
            getButtonSectionCellConfiguration(cell, indexPath)
        }
        return cell
    }

    private func getDestinationSectionCellConfiguration(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        guard let tableViewCell = cell as? TransferDestinationCell else {
            return
        }
        tableViewCell.accessoryType = .disclosureIndicator
        if let transferMethod = presenter.selectedTransferMethod {
            tableViewCell.configure(transferMethod: transferMethod)
        } else {
            if selectTransferMethodCoordinator == nil {
                tableViewCell.accessoryType = .none
            }
            let title = "transfer_add_account_title".localized()
            let subtitle = "transfer_add_account_subtitle".localized()
            tableViewCell.configure(title, subtitle, HyperwalletIconContent.circle)
        }
    }

    private func getTransferSectionCellConfiguration(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        if let tableViewCell = cell as? TransferAmountCell {
            tableViewCell.configure(amount: presenter.amount,
                                    currency: presenter.destinationCurrency,
                                    isEnabled: !presenter.transferAllFundsIsOn
            ) { [weak presenter] amount in
                if let transferAllFundsIsOn = presenter?.transferAllFundsIsOn, transferAllFundsIsOn == false {
                    presenter?.amount = amount
                }
            }
            return
        }
        if let tableViewCell = cell as? TransferAllFundsCell {
            tableViewCell.configure(setOn: presenter.transferAllFundsIsOn
            ) { [weak presenter] transferAllFundsIsOn in
                presenter?.transferAllFundsIsOn = transferAllFundsIsOn
            }
            return
        }
    }

    private func getNotesSectionCellConfiguration(_ cell: UITableViewCell) {
        if let tableViewCell = cell as? TransferNotesCell {
            tableViewCell.configure(notes: presenter.notes, isEditable: true) { [weak presenter] notes in
                presenter?.notes = notes
            }
        }
    }

    private func getButtonSectionCellConfiguration(_ cell: UITableViewCell, _ indexPath: IndexPath) {
        if let tableViewCell = cell as? TransferButtonCell {
            tableViewCell.configure(title: "transfer_next_button".localized())
        }
    }
}

// MARK: - Create transfer table view delegate
extension CreateTransferController {
    /// - To select the transfer method
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionData = presenter.sectionData[indexPath.section]
        if sectionData.createTransferSectionHeader == .destination,
            presenter.sectionData[indexPath.section] is CreateTransferSectionDestinationData {
            if presenter.selectedTransferMethod != nil {
                navigateToListTransferDestination()
            } else {
                navigateToTransferMethodIfInitialized()
            }
        }
        if sectionData.createTransferSectionHeader == .button {
            presenter.createTransfer()
        }
    }
}

// MARK: - CreateTransferView implementation
extension CreateTransferController: CreateTransferView {
    func areAllFieldsValid() -> Bool {
        presenter.resetErrorMessagesForAllSections()
        for section in presenter.sectionData {
            switch section.createTransferSectionHeader {
            case .destination:
                if presenter.selectedTransferMethod == nil {
                    section.errorMessage = "transfer_error_add_a_transfer_method_first".localized()
                    updateFooter(for: .destination)
                }

            case .transfer:
                if presenter.amount == nil || presenter.amount!.isEmpty || Double(presenter.amount!) == 0.00 {
                    section.errorMessage = "transfer_error_enter_amount_or_transfer_all".localized()
                    updateFooter(for: .transfer)
                }

            default:
                break
            }
        }
        return presenter.sectionData.allSatisfy({ $0.errorMessage?.isEmpty ?? true })
    }

    func updateFooter(for section: FooterSection) {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        if let footerView = tableView.footerView(forSection: section.rawValue) as? TransferTableViewFooterView {
            footerView.footerLabel.attributedText = getAttributedFooterText(for: section.rawValue)
        } else {
            tableView.reloadSections(IndexSet(integer: section.rawValue), with: .none)
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    func updateTransferSection() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: FooterSection.transfer.rawValue)], with: .none)
    }

    func notifyTransferCreated(_ transfer: HyperwalletTransfer) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferCreated,
                                            object: self,
                                            userInfo: [UserInfo.transferCreated: transfer])
        }
    }

    func showLoading() {
        spinnerView = HyperwalletUtilViews.showSpinner(view: view)
    }

    func hideLoading() {
        if let spinnerView = self.spinnerView {
            HyperwalletUtilViews.removeSpinner(spinnerView)
        }
    }

    func showError(_ error: HyperwalletErrorType, pageName: String, pageGroup: String, _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self, error: error, pageName: pageName, pageGroup: pageGroup)
        errorView.show(retry)
    }

    func reloadData() {
        tableView.reloadData()
    }

    private func navigateToListTransferDestination() {
        let listTransferDestinationController = ListTransferDestinationController()
        var initializationData = [InitializationDataField: Any]()
        initializationData[InitializationDataField.transferMethod] = presenter.selectedTransferMethod
        listTransferDestinationController.initializationData = initializationData
        listTransferDestinationController.flowDelegate = self
        show(listTransferDestinationController, sender: self)
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

    func showScheduleTransfer(_ transfer: HyperwalletTransfer) {
        if let transferMethod = presenter.selectedTransferMethod {
            coordinator?.navigateToNextPage(
                initializationData: [
                    InitializationDataField.transfer: transfer,
                    InitializationDataField.transferMethod: transferMethod,
                    InitializationDataField.didFxQuoteChange: presenter.didFxQuoteChange
                ]
            )
        }
    }
}

extension CreateTransferController {
    /// To reload create transfer method
    override public func didFlowComplete(with response: Any) {
        if let transferMethod = response as? HyperwalletTransferMethod {
            coordinator?.navigateBackFromNextPage(with: transferMethod)
            presenter.selectedTransferMethod = transferMethod
            presenter.amount = nil
            presenter.transferAllFundsIsOn = false
            presenter.notes = nil
            presenter.loadCreateTransfer()
        } else if let statusTransition = response as? HyperwalletStatusTransition {
            coordinator?.navigateBackFromNextPage(with: statusTransition)
            removeCoordinator()
            flowDelegate?.didFlowComplete(with: statusTransition)
        }
    }
}
