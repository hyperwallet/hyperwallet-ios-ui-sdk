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
public final class ScheduleTransferTableViewController: UITableViewController, UITextFieldDelegate {
    private var spinnerView: SpinnerView?
    private var presenter: ScheduleTransferViewPresenter!
    private var transferMethod: HyperwalletTransferMethod
    private var transfer: HyperwalletTransfer

    private let registeredCells: [(type: AnyClass, id: String)] = [
        (ListTransferMethodTableViewCell.self, ListTransferMethodTableViewCell.reuseIdentifier),
        (ScheduleTransferForeignExchangeCell.self, ScheduleTransferForeignExchangeCell.reuseIdentifier),
        (ScheduleTransferSummaryCell.self, ScheduleTransferSummaryCell.reuseIdentifier),
        (ScheduleTransferNotesCell.self, ScheduleTransferNotesCell.reuseIdentifier),
        (ScheduleTransferButtonCell.self, ScheduleTransferButtonCell.reuseIdentifier)
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
        setUpScheduleTransferTableView()
        presenter = ScheduleTransferViewPresenter(view: self, transferMethod: transferMethod, transfer: transfer)
        presenter.loadScheduleTransfer()
    }

    private func setUpScheduleTransferTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.accessibilityIdentifier = "scheduleTransferTableView"
        tableView.allowsSelection = false
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
        tableView.register(DividerCell.self, forCellReuseIdentifier: DividerCell.reuseIdentifier)
    }
}

// MARK: - Schedule transfer table data source
extension ScheduleTransferTableViewController {
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
            if let tableViewCell = cell as? ListTransferMethodTableViewCell,
                let destinationData = section as? ScheduleTransferDestinationData,
                let configuration = destinationData.configuration {
                tableViewCell.configure(configuration: configuration)
            }

        case .foreignExchange:
            if let tableViewCell = cell as? ScheduleTransferForeignExchangeCell,
                let foreignExchangeData = section as? ScheduleTransferForeignExchangeData {
                // Insert a divider row when the title is an empty string
                if foreignExchangeData.rows[indexPath.row].title.isEmpty {
                    return tableView.dequeueReusableCell(withIdentifier: DividerCell.reuseIdentifier, for: indexPath)
                } else {
                    tableViewCell.textLabel?.text = foreignExchangeData.rows[indexPath.row].title
                    tableViewCell.detailTextLabel?.text = foreignExchangeData.rows[indexPath.row].value
                    // modify separatorInset length when there is another foreign exanchange after this row
                    if let nextRow = foreignExchangeData.rows[safe: indexPath.row + 1], nextRow.title.isEmpty {
                        cell.separatorInset = UIEdgeInsets.zero
                    }
                }
            }

        case .summary:
            if let tableViewCell = cell as? ScheduleTransferSummaryCell,
                let summaryData = section as? ScheduleTransferSummaryData {
                tableViewCell.textLabel?.text = summaryData.rows[indexPath.row].title
                tableViewCell.detailTextLabel?.text = summaryData.rows[indexPath.row].value
            }

        case .notes:
            if let tableViewCell = cell as? ScheduleTransferNotesCell,
                let notesSection = section as? ScheduleTransferNotesData {
                tableViewCell.textLabel?.text = notesSection.notes
            }

        case .button:
            if let tableViewCell = cell as? ScheduleTransferButtonCell, section is ScheduleTransferButtonData {
                tableViewCell.textLabel?.text = "schedule_transfer_button".localized()
                tableViewCell.textLabel?.textAlignment = .center
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapScheduleTransfer))
                tableViewCell.textLabel?.isUserInteractionEnabled = true
                tableViewCell.textLabel?.addGestureRecognizer(tap)
            }
        }
        return cell
    }

    @objc
    private func tapScheduleTransfer(sender: UITapGestureRecognizer) {
        print("Schedule Transer Fund!")
    }
}

// MARK: - Schedule transfer table delegate
extension ScheduleTransferTableViewController {
    override public func tableView(_ tableView: UITableView,
                                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Theme.Cell.headerHeight)
    }
}

extension ScheduleTransferTableViewController: ScheduleTransferView {
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
        // TODO show error
    }

    func showScheduleTransfer() {
        //        presenter.initializeSections()
        tableView.reloadData()
    }

    func notifyTransferScheduled(_ transfer: HyperwalletTransfer) {
        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(name: .transferScheduled,
                                            object: self,
                                            userInfo: [UserInfo.transferScheduled: transfer])
        }
    }
}
