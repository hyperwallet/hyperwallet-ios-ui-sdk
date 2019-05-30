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

import UIKit

struct ListReceiptCellConfiguration {
    let type: String
    let entry: String
    let amount: String
    let currency: String
    let createdOn: String
    let iconFont: String
}

final class ListReceiptTableViewCell: UITableViewCell {
    private var iconColor: UIColor!
    private var iconBackgroundColor: UIColor!
    // MARK: Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

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
        set { detailTextLabel?.font = newValue
            detailTextLabel?.font = newValue }
    }

    @objc dynamic var subTitleLabelColor: UIColor! {
        get { return detailTextLabel?.textColor }
        set { detailTextLabel?.textColor = newValue }
    }
}

extension ListReceiptTableViewCell {
    func configure(configuration: ListReceiptCellConfiguration?) {
        if let configuration = configuration {
            textLabel?.attributedText = formatTextLabel(type: configuration.type,
                                                        createdOn: configuration.createdOn)
            detailTextLabel?.attributedText = formatDetailTextLabel(amount: configuration.amount,
                                                                    currency: configuration.currency,
                                                                    entry: configuration.entry)
            textLabel?.numberOfLines = 0
            textLabel?.lineBreakMode = .byWordWrapping
            detailTextLabel?.numberOfLines = 0
            detailTextLabel?.lineBreakMode = .byWordWrapping

            iconColor = configuration.entry == "CREDIT" ? Theme.Icon.secondaryColor : Theme.Icon.thirdColor
            iconBackgroundColor = configuration.entry == "CREDIT" ? Theme.Icon.secondaryBackgroundColor
                : Theme.Icon.thirdBackgroundColor

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

        attributedText.append(value: String(format: "%@\n", type), font: titleLabelFont, color: titleLabelColor)
        attributedText.append(value: createdOn,
                              font: Theme.Label.captionOne,
                              color: Theme.Label.subTitleColor)
        return attributedText
    }

    private func formatDetailTextLabel(amount: String, currency: String, entry: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        if entry == "CREDIT" {
            attributedText.append(value: String(format: "+%@\n", amount),
                                  font: titleLabelFont,
                                  color: Theme.Number.positiveColor)
        } else {
            attributedText.append(value: String(format: "-%@\n", amount),
                                  font: titleLabelFont,
                                  color: Theme.Number.negativeColor)
        }

        attributedText.append(value: currency, font: Theme.Label.captionOne, color: Theme.Label.subTitleColor )
        return attributedText
    }
}
