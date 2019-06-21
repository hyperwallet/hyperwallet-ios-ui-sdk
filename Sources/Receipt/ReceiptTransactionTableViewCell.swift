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

struct ReceiptTransactionCellConfiguration {
    let type: String
    let entry: String
    let amount: String
    let currency: String
    let createdOn: String
    let iconFont: String
}

final class ReceiptTransactionTableViewCell: UITableViewCell {
    static let reuseIdentifier = "receiptTransactionTableViewCellReuseIdentifier"
    private var iconColor: UIColor!
    private var iconBackgroundColor: UIColor!
    private let credit = HyperwalletReceipt.HyperwalletEntryType.credit.rawValue
    // MARK: Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ReceiptTransactionTableViewCell {
    func configure(configuration: ReceiptTransactionCellConfiguration?) {
        if let configuration = configuration {
            textLabel?.attributedText = formatTextLabel(type: configuration.type,
                                                        createdOn: configuration.createdOn)
            detailTextLabel?.attributedText = formatDetailTextLabel(amount: configuration.amount,
                                                                    currency: configuration.currency,
                                                                    entry: configuration.entry)
            textLabel?.numberOfLines = 0
            textLabel?.lineBreakMode = .byWordWrapping
            textLabel?.accessibilityIdentifier = "ListReceiptTableViewCellTextLabel"
            detailTextLabel?.numberOfLines = 0
            detailTextLabel?.lineBreakMode = .byWordWrapping
            detailTextLabel?.accessibilityIdentifier = "ListReceiptTableViewCellDetailTextLabel"

            iconColor = configuration.entry == credit ? Theme.Icon.creditColor : Theme.Icon.debitColor
            iconBackgroundColor = configuration.entry == credit ? Theme.Icon.creditBackgroundColor
                : Theme.Icon.debitBackgroundColor

            let icon = UIImage.fontIcon(configuration.iconFont,
                                        Theme.Icon.frame,
                                        CGFloat(Theme.Icon.size),
                                        iconColor)
            imageView?.image = icon
            imageView?.layer.cornerRadius = CGFloat(Theme.Icon.frame.width / 2)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imageView?.backgroundColor = iconBackgroundColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        imageView?.backgroundColor = iconBackgroundColor
    }

    private func formatTextLabel(type: String, createdOn: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()

        attributedText.append(value: String(format: "%@\n", type),
                              font: Theme.Label.bodyFontMedium,
                              color: Theme.Label.color)
        attributedText.append(value: createdOn,
                              font: Theme.Label.captionOne,
                              color: Theme.Label.subTitleColor)
        return attributedText
    }

    private func formatDetailTextLabel(amount: String, currency: String, entry: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        if entry == credit {
            attributedText.append(value: String(format: "+%@\n", amount.currencyFormatter(by: currency)),
                                  font: Theme.Label.bodyFontMedium,
                                  color: Theme.Amount.creditColor)
        } else {
            attributedText.append(value: String(format: "-%@\n", amount.currencyFormatter(by: currency)),
                                  font: Theme.Label.bodyFontMedium,
                                  color: Theme.Amount.debitColor)
        }

        attributedText.append(value: currency, font: Theme.Label.captionOne, color: Theme.Label.subTitleColor)
        return attributedText
    }
}
