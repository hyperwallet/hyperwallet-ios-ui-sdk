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

    lazy var receiptTypeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Theme.Label.bodyFontMedium
        label.textColor = Theme.Label.color
        label.accessibilityIdentifier = "receiptTransactionTypeLabel"
        return label
    }()

    lazy var amountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Theme.Label.bodyFontMedium
        label.textAlignment = .right
        label.accessibilityIdentifier = "receiptTransactionAmountLabel"
        return label
    }()

    lazy var createdOnLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Theme.Label.captionOne
        label.textColor = Theme.Label.subTitleColor
        label.accessibilityIdentifier = "receiptTransactionCreatedOnLabel"
        return label
    }()

    lazy var currencyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Theme.Label.captionOne
        label.textColor = Theme.Label.subTitleColor
        label.textAlignment = .right
        label.accessibilityIdentifier = "receiptTransactionCurrencyLabel"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        defaultInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultInit()
    }

    private func defaultInit() {
        let titleStackView = UIStackView(frame: .zero)
        setup(titleStackView, with: receiptTypeLabel, and: amountLabel)

        let subTitleStackView = UIStackView(frame: .zero)
        setup(subTitleStackView, with: createdOnLabel, and: currencyLabel)

        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2

        stackView.addArrangedSubview(titleStackView)
        stackView.addArrangedSubview(subTitleStackView)

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: imageView!.trailingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    private func setup(_ stackView: UIStackView, with leftLabel: UILabel, and rightLabel: UILabel) {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8

        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(rightLabel)

        setHuggingResistancePriorities(for: leftLabel, and: rightLabel)
    }

    private func setHuggingResistancePriorities(for leftLabel: UILabel, and rightLabel: UILabel) {
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false

        leftLabel.widthAnchor.constraint(equalTo: rightLabel.widthAnchor).isActive = true

        leftLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        leftLabel.setContentHuggingPriority(.required, for: .vertical)
        leftLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        leftLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        rightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightLabel.setContentHuggingPriority(.required, for: .vertical)
        rightLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
}

extension ReceiptTransactionTableViewCell {
    func configure(_ configuration: ReceiptTransactionCellConfiguration?) {
        if let configuration = configuration {
            receiptTypeLabel.text = configuration.type
            amountLabel.text = configuration.entry == credit
                ? configuration.amount
                : String(format: "-%@", configuration.amount)
            amountLabel.textColor = configuration.entry == credit
                ? Theme.Amount.creditColor
                : Theme.Amount.debitColor
            createdOnLabel.text = configuration.createdOn
            currencyLabel.text = configuration.currency

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
}
