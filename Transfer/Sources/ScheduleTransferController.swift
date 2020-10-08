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
    private var presenter: ScheduleTransferPresenter!
    private let footerIdentifier = "scheduleTransferFooterViewIdentifier"
    private let registeredCells: [(type: AnyClass, id: String)] = [
        (TransferSourceCell.self, TransferSourceCell.reuseIdentifier),
        (TransferDestinationCell.self, TransferDestinationCell.reuseIdentifier),
        (TransferForeignExchangeCell.self, TransferForeignExchangeCell.reuseIdentifier),
        (TransferSummaryCell.self, TransferSummaryCell.reuseIdentifier),
        (TransferNotesCell.self, TransferNotesCell.reuseIdentifier),
        (TransferButtonCell.self, TransferButtonCell.reuseIdentifier)
    ]

    override public func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        // setup table view
        setUpScheduleTransferTableView()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentNavigationItem: UINavigationItem = tabBarController?.navigationItem ?? navigationItem
        currentNavigationItem.backBarButtonItem = UIBarButtonItem.back
        titleDisplayMode(.always, for: "mobileConfirmationHeader".localized())
    }

    private func initializePresenter() {
        if let transferMethod = initializationData?[InitializationDataField.transferMethod]
            as? HyperwalletTransferMethod,
            let transfer = initializationData?[InitializationDataField.transfer] as? HyperwalletTransfer,
            let didFxQuoteChange = initializationData?[InitializationDataField.didFxQuoteChange] as? Bool,
            let transferSourceCellConfiguration = initializationData?[InitializationDataField.selectedTransferSource]
                as? TransferSourceCellConfiguration {
                presenter = ScheduleTransferPresenter(
                    view: self,
                    transferMethod: transferMethod,
                    transfer: transfer,
                    didFxQuoteChange: didFxQuoteChange,
                    transferSourceCellConfiguration: transferSourceCellConfiguration)
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
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = Theme.Cell.smallHeight
        tableView.backgroundColor = Theme.UITableViewController.backgroundColor
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
        tableView.register(DividerCell.self, forCellReuseIdentifier: DividerCell.reuseIdentifier)
        tableView.register(TransferTableViewFooterView.self,
                           forHeaderFooterViewReuseIdentifier: footerIdentifier)
    }
}

// MARK: - Schedule transfer table data source
extension ScheduleTransferController {
    /// Returns the title for header
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sectionData[section].title
    }
    /// Estimated height of header
    override public func tableView(_ tableView: UITableView,
                                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Theme.Cell.headerHeight)
    }
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
        view.footerLabel.attributedText = attributedText
        return view
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = presenter.sectionData[indexPath.section].scheduleTransferSectionHeader
        switch section {
        case .destination, .source:
            return Theme.Cell.largeHeight

        case .foreignExchange:
            return UITableView.automaticDimension

        default:
            return Theme.Cell.smallHeight
        }
    }

    private func getAttributedFooterText(for section: Int) -> NSAttributedString? {
        let sectionData = presenter.sectionData[section]
        var attributedText: NSAttributedString?
        if let transferSectionData = sectionData as? ScheduleTransferSummaryData {
            attributedText = format(footer: transferSectionData.footer)
        }
        return attributedText
    }

    private func format(footer: String? = nil) -> NSAttributedString? {
        var attributedText: NSMutableAttributedString! = nil
        if let footer = footer {
            attributedText = NSMutableAttributedString()
            attributedText.appendParagraph(value: footer,
                                           font: Theme.Label.footnoteFont,
                                           color: Theme.Label.subtitleColor)
        }
        return attributedText
    }

    private func getDestinationCellConfiguration(_ cellIdentifier: String,
                                                 _ indexPath: IndexPath,
                                                 _ section: ScheduleTransferSectionData) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let tableViewCell = cell as? TransferDestinationCell,
            let destinationData = section as? ScheduleTransferDestinationData {
            tableViewCell.configure(transferMethod: destinationData.transferMethod)
        }
        return cell
    }

    private func getForeignExchangeCellConfiguration(_ cellIdentifier: String,
                                                     _ indexPath: IndexPath,
                                                     _ section: ScheduleTransferSectionData) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if let tableViewCell = cell as? TransferForeignExchangeCell,
            let foreignExchangeData = section as? ScheduleTransferForeignExchangeData {
            return tableViewCell.configure(foreignExchangeData, indexPath, tableView)
        }
        return cell ?? UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: cellIdentifier)
    }

    private func getSummaryCellConfiguration(_ cellIdentifier: String,
                                             _ indexPath: IndexPath,
                                             _ section: ScheduleTransferSectionData) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let tableViewCell = cell as? TransferSummaryCell,
            let summaryData = section as? ScheduleTransferSummaryData {
            tableViewCell.configure(summaryData.rows[indexPath.row].title, summaryData.rows[indexPath.row].value)
        }
        return cell
    }

    private func getNotesCellConfiguration(_ cellIdentifier: String,
                                           _ indexPath: IndexPath,
                                           _ section: ScheduleTransferSectionData) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let tableViewCell = cell as? TransferNotesCell,
            let notesSection = section as? ScheduleTransferNotesData {
            tableViewCell.configure(notes: notesSection.notes, isEditable: false, hideBorder: false, { _ in })
        }
        return cell
    }

    private func getButtonCellConfiguration(_ cellIdentifier: String,
                                            _ indexPath: IndexPath,
                                            _ section: ScheduleTransferSectionData) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let tableViewCell = cell as? TransferButtonCell, section is ScheduleTransferButtonData {
            let tapConfirmation = UITapGestureRecognizer(target: self, action: #selector(tapScheduleTransfer))
            tableViewCell.configure(title: "transfer".localized(), action: tapConfirmation)
        }
        return cell
    }

    private func getSourceCellConfiguration(_ cellIdentifier: String,
                                            _ indexPath: IndexPath,
                                            _ section: ScheduleTransferSectionData) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let tableViewCell = cell as? TransferSourceCell,
            let sourceData = section as? ScheduleTransferSectionSourceData {
            tableViewCell.configure(transferSourceCellConfiguration: sourceData.transferSourceCellConfiguration)
        }
        return cell
    }

    private func getCellConfiguration(_ indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = presenter.sectionData[indexPath.section].cellIdentifier
        let section = presenter.sectionData[indexPath.section]
        switch section.scheduleTransferSectionHeader {
        case .destination:
            return getDestinationCellConfiguration(cellIdentifier, indexPath, section)

        case .foreignExchange:
            return getForeignExchangeCellConfiguration(cellIdentifier, indexPath, section)

        case .summary:
            return getSummaryCellConfiguration(cellIdentifier, indexPath, section)

        case .notes:
            return getNotesCellConfiguration(cellIdentifier, indexPath, section)

        case .button:
            return getButtonCellConfiguration(cellIdentifier, indexPath, section)

        case .source:
            return getSourceCellConfiguration(cellIdentifier, indexPath, section)
        }
    }

    @objc
    private func tapScheduleTransfer(sender: UITapGestureRecognizer) {
        presenter.scheduleTransfer()
    }
}

extension ScheduleTransferController: ScheduleTransferView {
    func showLoading() {
        spinnerView = HyperwalletUtilViews.showSpinner(view: view)
    }

    func hideLoading() {
        if let spinnerView = self.spinnerView {
            HyperwalletUtilViews.removeSpinner(spinnerView)
        }
    }

    func showConfirmation(handler: @escaping (() -> Void)) {
        let destinationData = presenter.sectionData[1] as? ScheduleTransferDestinationData
        HyperwalletUtilViews.showAlert(self,
                                       title: "mobileTransferSuccessMsg".localized(),
                                       message: String(format: "mobileTransferSuccessDetails".localized(),
                                                       destinationData?.transferMethod.title ?? " "),
                                       actions: UIAlertAction.close({ (_) in
                                            handler()
                                       }))
    }

    func showError(_ error: HyperwalletErrorType, pageName: String, pageGroup: String, _ retry: (() -> Void)?) {
        let errorView = ErrorView(viewController: self, error: error, pageName: pageName, pageGroup: pageGroup)
        errorView.show(retry)
    }

    func notifyTransferScheduled(_ hyperwalletStatusTransition: HyperwalletStatusTransition) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferScheduled,
                                            object: self,
                                            userInfo: [UserInfo.transferScheduled: hyperwalletStatusTransition])
        }
        flowDelegate?.didFlowComplete(with: hyperwalletStatusTransition)
    }
}
