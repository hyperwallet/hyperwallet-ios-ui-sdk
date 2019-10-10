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

final class TransferAmountCell: UITableViewCell {
    static let reuseIdentifier = "transferAmountCellIdentifier"
    typealias EnteredAmountHandler = (_ value: String) -> Void

    var enteredAmountHandler: EnteredAmountHandler?

    private lazy var amountTextField: PasteOnlyTextField = {
        let textField = PasteOnlyTextField(frame: .zero)
        textField.textAlignment = .right
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.delegate = self
        textField.accessibilityIdentifier = "transferAmountTextField"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.accessibilityIdentifier = "transferAmountTitleLabel"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private lazy var currencyLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.accessibilityIdentifier = "transferAmountCurrencyLabel"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc
    private func didTapCell() {
        amountTextField.becomeFirstResponder()
    }

    private func setupCell() {
        self.selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(tap)

        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 15
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(amountTextField)
        stackView.addArrangedSubview(currencyLabel)
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

    func configure(amount: String?, currency: String?, isEnabled: Bool, _ handler: @escaping EnteredAmountHandler) {
        titleLabel.text = "transfer_amount".localized()
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        amountTextField.text = amount
        amountTextField.adjustsFontForContentSizeCategory = true
        amountTextField.isEnabled = isEnabled
        currencyLabel.text = currency ?? String(repeating: " ", count: 3)
        currencyLabel.numberOfLines = 0
        currencyLabel.adjustsFontForContentSizeCategory = true
        enteredAmountHandler = handler
    }
}

extension TransferAmountCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var currentText = textField.text else {
            enteredAmountHandler?("")
            return
        }
        let decimalPointSymbol = "."
        if currentText.last == Character(decimalPointSymbol) {
            currentText.removeLast()
            textField.text = currentText
        }
        enteredAmountHandler?(currentText)
    }

    private func setCursorToTheEnd(_ textField: UITextField) {
        DispatchQueue.main.async {
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let maximumIntegerDigits = 12
        let maximumFractionDigits = 2
        let decimalPointSymbol = "."
        let currentText = textField.text ?? ""

        // BackSpace
        if string.isEmpty {
            return true
        }
        // Paste
        if string.count > 1 {
            let stringPastedAmount = string.format(with: currencyLabel.text)
            let pastedDigitsOnly = stringPastedAmount.replacingOccurrences(of: "[^0-9]",
                                                                           with: "",
                                                                           options: .regularExpression)
            let pointEntered = stringPastedAmount.contains(decimalPointSymbol)
            let maximumAllowedDigits = pointEntered
                ? maximumIntegerDigits + maximumFractionDigits
                : maximumIntegerDigits
            guard !stringPastedAmount.isEmpty,
                currentText.isEmpty,
                pastedDigitsOnly.count <= maximumAllowedDigits else {
                    return false
            }
            textField.text = stringPastedAmount
            setCursorToTheEnd(textField)
            return false
        }
        // Decimal point
        if string == decimalPointSymbol {
            if currentText.isEmpty {
                textField.text = "0\(decimalPointSymbol)"
                return false
            }
            return !currentText.contains(decimalPointSymbol)
        }
        // Digit
        if currentText == "0" {
            if string != "0" {
                textField.text = string
            }
            return false
        }
        let split = currentText.split(separator: Character(decimalPointSymbol),
                                      omittingEmptySubsequences: false)
        let pointEntered = split.count == 2

        return pointEntered
            ? split[1].count < maximumFractionDigits
            : split[0].count < maximumIntegerDigits
    }
}

extension TransferAmountCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return titleLabel.font }
        set { titleLabel.font = newValue
            amountTextField.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue
            amountTextField.textColor = newValue }
    }

    @objc dynamic var currencyLabelFont: UIFont! {
        get { return currencyLabel.font }
        set { currencyLabel.font = newValue }
    }

    @objc dynamic var currencyLabelColor: UIColor! {
        get { return currencyLabel.textColor }
        set { currencyLabel.textColor = newValue }
    }
}
