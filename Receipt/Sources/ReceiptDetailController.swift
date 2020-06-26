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
/// The class to display detail receipt
final class ReceiptDetailController: UITableViewController {
    private let registeredCells: [(type: AnyClass, id: String)] = [
        (ReceiptTransactionCell.self, ReceiptTransactionCell.reuseIdentifier),
        (ReceiptFeeCell.self, ReceiptFeeCell.reuseIdentifier),
        (ReceiptDetailCell.self, ReceiptDetailCell.reuseIdentifier),
        (ReceiptNotesCell.self, ReceiptNotesCell.reuseIdentifier)
    ]

    private var presenter: ReceiptDetailPresenter!
    /// Called after the view controller has loaded its view hierarchy into memory.
    override public func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        setupReceiptDetailTableView()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleDisplayMode(.never, for: "title_receipts_details".localized())
    }

    private func initializePresenter() {
        if let receipt = initializationData?[InitializationDataField.receipt]
            as? HyperwalletReceipt { presenter = ReceiptDetailPresenter(with: receipt) } else {
            fatalError("Required data not provided in initializePresenter")
        }
    }

    private func setupReceiptDetailTableView() {
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Theme.Cell.smallHeight
        tableView.separatorStyle = .singleLine
        tableView.accessibilityIdentifier = "receiptDetailTableView"
        tableView.cellLayoutMarginsFollowReadableWidth = false
        registeredCells.forEach {
            tableView.register($0.type, forCellReuseIdentifier: $0.id)
        }
    }

    private func getCellConfiguration(_ indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = presenter.sectionData[indexPath.section].cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let section = presenter.sectionData[indexPath.section]
        switch section.receiptDetailSectionHeader {
        case .transaction:
            if let tableViewCell = cell as? ReceiptTransactionCell,
                let transactionSection = section as? ReceiptDetailSectionTransactionData {
                tableViewCell.configure(transactionSection.receipt)
            }

        case .details:
            if let tableViewCell = cell as? ReceiptDetailCell,
                let detailSection = section as? ReceiptDetailSectionDetailData {
                let row = detailSection.rows[indexPath.row]
                tableViewCell.configure(row)
            }

        case .fee:
            if let tableViewCell = cell as? ReceiptFeeCell,
                let feeSection = section as? ReceiptDetailSectionFeeData {
                let row = feeSection.rows[indexPath.row]
                tableViewCell.configure(row)
           }

        case .notes:
            if let tableViewCell = cell as? ReceiptNotesCell,
                let notesSection = section as? ReceiptDetailSectionNotesData {
                tableViewCell.textLabel?.text = notesSection.notes
                tableViewCell.textLabel?.numberOfLines = 0
                tableViewCell.textLabel?.lineBreakMode = .byWordWrapping
                tableViewCell.textLabel?.adjustsFontForContentSizeCategory = true
            }
        }
        return cell
    }
}
/// The receipt detail controller
extension ReceiptDetailController {
    /// Returns tableview section count
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.sectionData.count
    }
    /// Returns title for header
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.sectionData[section].title
    }
    /// Returns the count of receipt detail fields
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.sectionData[section].rowCount
    }
    /// Display the receipt details
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCellConfiguration(indexPath)
    }
    /// Estimated height of header
    override public func tableView(_ tableView: UITableView,
                                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(Theme.Cell.headerHeight)
    }
}
