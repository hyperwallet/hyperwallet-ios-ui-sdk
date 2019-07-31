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
public final class CreateTransferController: UITableViewController {
    private var spinnerView: SpinnerView?
    private var presenter: CreateTransferPresenter!
    private let registeredCells: [(type: AnyClass, id: String)] = [
        (TransferDestinationCell.self, TransferDestinationCell.reuseIdentifier),
        (TransferAllFundsCell.self, TransferAllFundsCell.reuseIdentifier),
        (TransferAmountCell.self, TransferAmountCell.reuseIdentifier),
        (TransferButtonCell.self, TransferButtonCell.reuseIdentifier),
        (TransferNotesCell.self, TransferNotesCell.reuseIdentifier)
    ]
    var createTransferMethodHandler: ((HyperwalletTransferMethod) -> Void)?
    var createTransferHandler: ((HyperwalletTransfer) -> Void)?

    public init(clientTransferId: String, sourceToken: String?) {
        super.init(nibName: nil, bundle: nil)
        presenter = CreateTransferPresenter(clientTransferId, sourceToken, view: self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "transfer_funds".localized()
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        largeTitle()
        setViewBackgroundColor()

        presenter.loadCreateTransfer()

        setUpCreateTransferTableView()
        hideKeyboardWhenTappedAround()
    }

    private func setUpCreateTransferTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.accessibilityIdentifier = "createTransferTableView"
        tableView.cellLayoutMarginsFollowReadableWidth = false
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
    }
}

// MARK: - Create transfer table view dataSource
extension CreateTransferController {
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

    override public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let transferSection = presenter.sectionData[section] as? CreateTransferSectionTransferData {
            return transferSection.footer
        }
        return nil
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
        guard let sectionData = presenter.sectionData[indexPath.section] as? CreateTransferSectionDestinationData,
            let tableViewCell = cell as? TransferDestinationCell else {
                return
        }
        tableViewCell.accessoryType = .disclosureIndicator
        if sectionData.isTransferMethodAvailable {
            tableViewCell.configure(transferMethod: presenter.selectedTransferMethod)
        } else {
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
            tableViewCell.configure(notes: presenter.notes) { [weak presenter] notes in
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
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionData = presenter.sectionData[indexPath.section]
        if sectionData.createTransferSectionHeader == .destination,
            presenter.sectionData[indexPath.section] is CreateTransferSectionDestinationData {
            presenter.showSelectDestinationAccountView()
        }
        if sectionData.createTransferSectionHeader == .button {
            presenter.createTransfer()
        }
    }
}

// MARK: - CreateTransferView implementation
extension CreateTransferController: CreateTransferView {
    func updateTransferSection() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    }

    func notifyTransferCreated(_ transfer: HyperwalletTransfer) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferCreated,
                                            object: self,
                                            userInfo: [UserInfo.transferCreated: transfer])
        }
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

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self, error: error)
        errorView.show(retry)
    }

    func showCreateTransfer() {
        presenter.initializeSections()
        tableView.reloadData()
    }

    func showGenericTableView(items: [HyperwalletTransferMethod],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler) {
        let genericTableView = GenericController<TransferDestinationCell, HyperwalletTransferMethod>()

        genericTableView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                             target: self,
                                                                             action: #selector(didTapAddButton))

        genericTableView.title = title
        genericTableView.items = items
        genericTableView.selectedHandler = selectItemHandler
        genericTableView.shouldMarkCellAction = markCellHandler
        show(genericTableView, sender: self)
    }

    @objc
    private func didTapAddButton(sender: AnyObject) {
        //        let controller = SelectTransferMethodTypeController(forceUpdate: false) ///TO DO true or false
        //        controller.largeTitle()
        //        controller.createTransferMethodHandler = {
        //            [weak self] (transferMethod: HyperwalletTransferMethod) -> Void in
        //            // refresh transfer method list
        //            self?.navigationController?.popViewController(animated: true)
        //            self?.presenter.selectedTransferMethod = transferMethod
        //            self?.presenter.loadCreateTransfer()
        //        }
        //        navigationController?.pushViewController(controller, animated: true)
    }

    func showScheduleTransfer(_ transfer: HyperwalletTransfer) {
        // TO DO navigate to schedule
    }
}