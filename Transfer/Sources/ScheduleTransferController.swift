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

/// Schedule a transfer that was previously created
final class ScheduleTransferController: UITableViewController, UITextFieldDelegate {
    private var spinnerView: SpinnerView?
    private var processingView: ProcessingView?
    private var presenter: ScheduleTransferPresenter!

    private let registeredCells: [(type: AnyClass, id: String)] = [
        (TransferDestinationCell.self, TransferDestinationCell.reuseIdentifier),
        (TransferForeignExchangeCell.self, TransferForeignExchangeCell.reuseIdentifier),
        (TransferSummaryCell.self, TransferSummaryCell.reuseIdentifier),
        (TransferNotesCell.self, TransferNotesCell.reuseIdentifier),
        (TransferButtonCell.self, TransferButtonCell.reuseIdentifier)
    ]

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "transfer_funds".localized()
        largeTitle()
        setViewBackgroundColor()
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        initializePresenter()
        // setup table view
        setUpScheduleTransferTableView()
    }

    private func initializePresenter() {
        if let transferMethod = initializationData?[InitializationDataField.transferMethod]
            as? HyperwalletTransferMethod,
            let transfer = initializationData?[InitializationDataField.transfer] as? HyperwalletTransfer {
            presenter = ScheduleTransferPresenter(view: self, transferMethod: transferMethod, transfer: transfer)
        } else {
            fatalError("Required data not provided in initializePresenter")
        }
    }

    private func setUpScheduleTransferTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.accessibilityIdentifier = "scheduleTransferTableView"
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.smallHeight
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
        tableView.register(DividerCell.self, forCellReuseIdentifier: DividerCell.reuseIdentifier)
    }
}

// MARK: - Schedule transfer table data source
extension ScheduleTransferController {
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sectionData[section].title
    }

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
        switch section.scheduleTransferSectionHeader {
        case .destination:
            if let tableViewCell = cell as? TransferDestinationCell,
                let destinationData = section as? ScheduleTransferDestinationData {
                tableViewCell.configure(transferMethod: destinationData.transferMethod)
            }

        case .foreignExchange:
            if let tableViewCell = cell as? TransferForeignExchangeCell,
                let foreignExchangeData = section as? ScheduleTransferForeignExchangeData {
                return tableViewCell.configure(foreignExchangeData, indexPath, tableView)
            }

        case .summary:
            if let tableViewCell = cell as? TransferSummaryCell,
                let summaryData = section as? ScheduleTransferSummaryData {
                tableViewCell.configure(summaryData.rows[indexPath.row].title, summaryData.rows[indexPath.row].value)
            }

        case .notes:
            if let tableViewCell = cell as? TransferNotesCell,
                let notesSection = section as? ScheduleTransferNotesData {
                tableViewCell.configure(notes: notesSection.notes, isEditable: false, { _ in })
            }

        case .button:
            if let tableViewCell = cell as? TransferButtonCell, section is ScheduleTransferButtonData {
                let tapConfirmation = UITapGestureRecognizer(target: self, action: #selector(tapScheduleTransfer))
                tableViewCell.configure(title: "transfer_button_confirm".localized(), action: tapConfirmation)
            }
        }
        return cell
    }

    @objc
    private func tapScheduleTransfer(sender: UITapGestureRecognizer) {
        presenter.scheduleTransfer()
    }
}

// MARK: - Schedule transfer table delegate
extension ScheduleTransferController {
    override public func tableView(_ tableView: UITableView,
                                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Theme.Cell.headerHeight)
    }
}

extension ScheduleTransferController: ScheduleTransferView {
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

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self, error: error)
        errorView.show(retry)
    }

    func notifyTransferScheduled(_ hyperwalletStatusTransition: HyperwalletStatusTransition) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferScheduled,
                                            object: self,
                                            userInfo: [UserInfo.transferScheduled.rawValue: hyperwalletStatusTransition])
        }
        coordinator?.navigateBackFromNextPage(with: hyperwalletStatusTransition)
    }
}
