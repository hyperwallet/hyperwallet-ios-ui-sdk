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

final class TransferAllFundsCell: UITableViewCell {
    static let reuseIdentifier = "transferAllFundsCellIdentifier"

    private lazy var availableFundsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.accessibilityIdentifier = "transferAmountTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private lazy var transferMaxAmountButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "mobileTransferMax".localized()
        button.accessibilityIdentifier = "transferMaxAmountTitleLabel"
        button.setTitle("mobileTransferMax".localized(), for: .normal)
        button.setTitleColor(Theme.Button.color, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { (view) in
            if type(of: view).description() == "_UITableViewCellSeparatorView" {
                view.isHidden = true
            }
        }
    }

    private func setupCell() {
        selectionStyle = .none

        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.addArrangedSubview(availableFundsLabel)
        stackView.addArrangedSubview(transferMaxAmountButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        let margins = contentView.layoutMarginsGuide

        let constraints = [
            stackView.safeAreaLeadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stackView.safeAreaTrailingAnchor.constraint(equalTo: margins.trailingAnchor),
            stackView.safeAreaBottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
    }

    func configure(action: UIGestureRecognizer,
                   availableBalance: String?,
                   currencyCode: String?) {
        guard let availableBalance = availableBalance,
            availableBalance.formatToDouble() != 0,
            let currencyCode = currencyCode else {
                availableFundsLabel.text = ""
                return
        }

        let locale = NSLocale(localeIdentifier: currencyCode)
        let currencySymbol = locale.displayName(forKey: NSLocale.Key.currencySymbol, value: currencyCode)
        if let currencySymbol = currencySymbol {
            availableFundsLabel.text = String(format: "mobileAvailableBalance".localized(),
                                              currencySymbol,
                                              availableBalance,
                                              currencyCode)
            availableFundsLabel.numberOfLines = 0
            availableFundsLabel.adjustsFontForContentSizeCategory = true
        }
        transferMaxAmountButton.addGestureRecognizer(action)
    }
}

extension TransferAllFundsCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var availableFundsLabelFont: UIFont! {
        get { return availableFundsLabel.font }
        set { availableFundsLabel.font = newValue }
    }

    @objc dynamic var availableFundsLabelColor: UIColor! {
        get { return availableFundsLabel.textColor }
        set { availableFundsLabel.textColor = newValue }
    }

    @objc dynamic var transferMaxAmountButtonFont: UIFont! {
        get { return transferMaxAmountButton.titleLabel?.font }
        set { transferMaxAmountButton.titleLabel?.font = newValue }
    }

    @objc dynamic var transferMaxAmountButtonColor: UIColor! {
        get { return transferMaxAmountButton.titleLabel?.textColor }
        set { transferMaxAmountButton.titleLabel?.textColor = newValue }
    }
}
