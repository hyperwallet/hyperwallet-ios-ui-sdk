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

final class ReceiptTransactionCell: UITableViewCell {
    static let reuseIdentifier = "receiptTransactionTableViewCellReuseIdentifier"
    private var iconColor: UIColor!
    private var iconBackgroundColor: UIColor!
    private let credit = HyperwalletReceipt.HyperwalletEntryType.credit.rawValue

    lazy var receiptTypeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.accessibilityIdentifier = "receiptTransactionTypeLabel"
        return label
    }()

    lazy var amountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.accessibilityIdentifier = "receiptTransactionAmountLabel"
        return label
    }()

    lazy var createdOnLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.accessibilityIdentifier = "receiptTransactionCreatedOnLabel"
        return label
    }()

    lazy var currencyLabel: UILabel = {
        let label = UILabel(frame: .zero)
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
        let stackViewLeadingConstraints: NSLayoutConstraint
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
        stackViewLeadingConstraints = !UIFont.isLargeSizeCategory ? stackView.leadingAnchor
            .constraint(equalTo: imageView!.trailingAnchor, constant: 15) : stackView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 20)
        NSLayoutConstraint.activate([
            stackViewLeadingConstraints,
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 18),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -18)
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

extension ReceiptTransactionCell {
    func configure(_ receipt: HyperwalletReceipt?) {
        guard let receipt = receipt,
            let entry = receipt.entry?.rawValue,
            let createdOn = receipt.createdOn,
            let amount = receipt.amount,
            let currency = receipt.currency else {
                return
        }
        let formattedCreatedOn = ISO8601DateFormatter.ignoreTimeZone
            .date(from: createdOn)!
            .format(for: .date)

        let iconFont = HyperwalletIcon.of(entry).rawValue

        receiptTypeLabel.text = receipt.type?.rawValue.lowercased().localized()

        let formattedAmount = amount.formatToCurrency(with: currency)

        amountLabel.text = entry == credit ?
            String(format: "%@", formattedAmount) :
            String(format: "-%@", formattedAmount)

        amountLabel.textColor = entry == credit
            ? Theme.Amount.creditColor
            : Theme.Amount.debitColor
        createdOnLabel.text = formattedCreatedOn
        currencyLabel.text = receipt.currency
        iconColor = entry == credit ? Theme.Icon.creditColor : Theme.Icon.debitColor

        if !UIFont.isLargeSizeCategory {
            let icon = UIImage.fontIcon(iconFont,
                                        Theme.Icon.frame,
                                        CGFloat(Theme.Icon.size),
                                        iconColor)
            imageView?.image = icon
        }
    }
}

extension ReceiptTransactionCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var receiptTypeFont: UIFont! {
        get { return receiptTypeLabel.font }
        set { receiptTypeLabel.font = newValue }
    }

    @objc dynamic var receiptTypeColor: UIColor! {
        get { return receiptTypeLabel.textColor }
        set { receiptTypeLabel.textColor = newValue }
    }

    @objc dynamic var amountFont: UIFont! {
        get { return amountLabel.font }
        set { amountLabel.font = newValue }
    }

    @objc dynamic var amountColor: UIColor! {
        get { return amountLabel.textColor }
        set { amountLabel.textColor = newValue }
    }

    @objc dynamic var createdOnFont: UIFont! {
        get { return createdOnLabel.font }
        set { createdOnLabel.font = newValue }
    }

    @objc dynamic var createdOnColor: UIColor! {
        get { return createdOnLabel.textColor }
        set { createdOnLabel.textColor = newValue }
    }

    @objc dynamic var currencyFont: UIFont! {
        get { return currencyLabel.font }
        set { currencyLabel.font = newValue }
    }

    @objc dynamic var currencyColor: UIColor! {
        get { return currencyLabel.textColor }
        set { currencyLabel.textColor = newValue }
    }
}
