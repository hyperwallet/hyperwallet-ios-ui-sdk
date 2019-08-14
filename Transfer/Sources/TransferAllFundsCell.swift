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
    typealias TransferAllFundsSwitchHandler = (_ value: Bool) -> Void
    static let reuseIdentifier = "transferAllFundsCellIdentifier"

    private var transferAllFundsSwitchHandler: TransferAllFundsSwitchHandler?

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "transfer_all_funds".localized()
        label.accessibilityLabel = "transfer_all_funds".localized()
        label.accessibilityIdentifier = "transferAllFundsTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    private lazy var transferAllFundsSwitch: UISwitch = {
        let transferAllSwitch = UISwitch(frame: .zero)
        transferAllSwitch.setOn(false, animated: false)
        transferAllSwitch.accessibilityIdentifier = "transferAllFundsSwitch"
        transferAllSwitch.translatesAutoresizingMaskIntoConstraints = false
        transferAllSwitch.setContentHuggingPriority(.required, for: .horizontal)
        transferAllSwitch.setContentCompressionResistancePriority(.required, for: .horizontal)
        return transferAllSwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupCell() {
        selectionStyle = .none
        transferAllFundsSwitch.addTarget(self, action: #selector(switchStateDidChange), for: .valueChanged)

        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(transferAllFundsSwitch)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        let margins = contentView.layoutMarginsGuide

        let constraints = [
            stackView.safeAreaLeadingAnchor.constraint(equalTo: margins.leadingAnchor),
            stackView.safeAreaTrailingAnchor.constraint(equalTo: margins.trailingAnchor),
            stackView.safeAreaTopAnchor.constraint(equalTo: margins.topAnchor),
            stackView.safeAreaBottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
    }

    @objc
    private func switchStateDidChange() {
        transferAllFundsSwitchHandler?(transferAllFundsSwitch.isOn)
    }

    func configure(setOn: Bool, _ handler: @escaping TransferAllFundsSwitchHandler) {
        transferAllFundsSwitch.setOn(setOn, animated: false)
        transferAllFundsSwitchHandler = handler
    }
}

extension TransferAllFundsCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
}
