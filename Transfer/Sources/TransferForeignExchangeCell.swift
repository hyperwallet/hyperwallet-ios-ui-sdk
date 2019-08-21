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

final class TransferForeignExchangeCell: UITableViewCell {
    static let reuseIdentifier = "scheduleTransferForeignExchangeCellIdentifier"
    private var shouldHideSeparator = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        textLabel?.accessibilityIdentifier = "scheduleTransferForeignExchangeTextLabel"
        detailTextLabel?.accessibilityIdentifier = "scheduleTransferForeignExchangeTextValue"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension TransferForeignExchangeCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return textLabel?.font }
        set { textLabel?.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return textLabel?.textColor }
        set { textLabel?.textColor = newValue }
    }

    @objc dynamic var subTitleLabelFont: UIFont! {
        get { return detailTextLabel?.font }
        set { detailTextLabel?.font = newValue }
    }

    @objc dynamic var subTitleLabelColor: UIColor! {
        get { return detailTextLabel?.textColor }
        set { detailTextLabel?.textColor = newValue }
    }

    func configure(_ sectionData: ScheduleTransferForeignExchangeData,
                   _ indexPath: IndexPath,
                   _ tableView: UITableView) -> UITableViewCell {
        let rowIndex = indexPath.row
        if sectionData.rows[rowIndex].title == nil {
            return tableView.dequeueReusableCell(withIdentifier: DividerCell.reuseIdentifier, for: indexPath)
        } else {
            textLabel?.text = sectionData.rows[rowIndex].title
            detailTextLabel?.text = sectionData.rows[rowIndex].value
            // modify separatorInset length when there is another foreign exchange after this row
            if let nextRow = sectionData.rows[safe: rowIndex + 1], nextRow.title == nil {
               shouldHideSeparator = true
            }
            return self
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldHideSeparator {
            let separatorView = subviews.first(where: { $0.isSeparatorView() })
            separatorView?.isHidden = true
            shouldHideSeparator = false
        }
    }
}
