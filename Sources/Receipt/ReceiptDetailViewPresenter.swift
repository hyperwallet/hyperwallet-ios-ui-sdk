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

final class ReceiptDetailViewPresenter {
    private var sections: [ReceiptSection] = []

    init(with receipt: HyperwalletReceipt) {
        initializeSections(with: receipt)
    }

    private func initializeSections(with receipt: HyperwalletReceipt) {
        let receiptTransactionSection = ReceiptTransactionSection(from: receipt)
        sections.append(receiptTransactionSection)

        let receiptDetailSection = ReceiptDetailSection(from: receipt)
        sections.append(receiptDetailSection)

        if let receiptNotesSection = ReceiptNotesSection(from: receipt) {
            sections.append(receiptNotesSection)
        }
        let receiptFeeSection = ReceiptFeeSection(from: receipt)
        sections.append(receiptFeeSection)
    }

    func numberOfSections() -> Int {
        return sections.count
    }

    func titleForHeaderInSection(_ index: Int) -> String {
        return sections[index].title
    }

    func numberOfRowsInSection(_ index: Int) -> Int {
        return sections[index].rowCount
    }

    func cellIdentifierForRowInSection(_ section: Int) -> String {
        return sections[section].cellIdentifier
    }

    func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        let section = sections[indexPath.section]
        switch section.sectionType {
        case .transaction:
            if let tableViewCell = cell as? ReceiptTransactionTableViewCell,
                let transactionSection = section as? ReceiptTransactionSection {
                 tableViewCell.configure(configuration: transactionSection.tableViewCellConfiguration)
            }

        case .detail:
            if let tableViewCell = cell as? ReceiptDetailTableViewCell,
                let detailSection = section as? ReceiptDetailSection {
                let row = detailSection.rows[indexPath.row]
                tableViewCell.textLabel?.text = row.title
                tableViewCell.detailTextLabel?.text = row.value
            }

        case .fee:
            if let tableViewCell = cell as? ReceiptFeeTableViewCell,
                let feeSection = section as? ReceiptFeeSection {
                let row = feeSection.rows[indexPath.row]
                tableViewCell.textLabel?.text = row.title
                tableViewCell.detailTextLabel?.text = row.value
            }

        case .notes:
            if let tableViewCell = cell as? ReceiptNotesTableViewCell,
                let feeSection = section as? ReceiptNotesSection {
                tableViewCell.textLabel?.text = feeSection.notes!
            }
        }
    }
}
