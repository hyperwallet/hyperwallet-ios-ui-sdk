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
/// The TableViewCell to display transfer amount
final class TransferAmountCell: UITableViewCell {
    static let reuseIdentifier = "transferAmountCellIdentifier"
    typealias EnteredAmountHandler = (_ value: String) -> Void

    private var numberOfDecimals = 0
    private var defaultNumberOfDigits = 0
    private var formattedZeroAmount = "0"
    private var inputAmount = ""
    var enteredAmountHandler: EnteredAmountHandler?

    private lazy var amountTextField: AmountTextField = {
        let textField = AmountTextField(frame: .zero)
        textField.textAlignment = .center
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.delegate = self
        textField.accessibilityIdentifier = "transferAmountTextField"
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        let heightConstraint = NSLayoutConstraint(item: textField,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 50)
        let widthConstraint = NSLayoutConstraint(item: textField,
                                                 attribute: .width,
                                                 relatedBy: .greaterThanOrEqual,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: 50)
        textField.addConstraint(heightConstraint)
        textField.addConstraint(widthConstraint)
        return textField
    }()

    private lazy var currencySymbolLabel: UITextField = {
        let label = UITextField(frame: .zero)
        label.isUserInteractionEnabled = false
        label.contentVerticalAlignment = .top
        label.accessibilityIdentifier = "transferAmountTitleLabel"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private lazy var currencyLabel: UITextField = {
        let label = UITextField(frame: .zero)
        label.isUserInteractionEnabled = false
        label.contentVerticalAlignment = .bottom
        label.accessibilityIdentifier = "transferAmountCurrencyLabel"
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        subviews.forEach { (view) in
            if type(of: view).description() == "_UITableViewCellSeparatorView" {
                view.isHidden = true
            }
        }
    }

    @objc
    private func didTapCell() {
        amountTextField.becomeFirstResponder()
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        textField.invalidateIntrinsicContentSize()
        let maxWidth = UIScreen.main.bounds.width * 0.7
        let minWidthToFit = min(maxWidth, textField.frame.size.width)
        let newSize = textField.sizeThatFits(CGSize(width: minWidthToFit, height: CGFloat.greatestFiniteMagnitude))
        textField.frame.size = CGSize(width: min(newSize.width, minWidthToFit), height: 50)
        formatCurrencyText(for: textField)
    }

    private func setupCell() {
        self.selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(tap)

        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.addArrangedSubview(currencySymbolLabel)
        stackView.addArrangedSubview(amountTextField)
        stackView.addArrangedSubview(currencyLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        let margins = contentView.layoutMarginsGuide
        let maxWidthConstraint = [
            amountTextField.widthAnchor.constraint(lessThanOrEqualTo: margins.widthAnchor, multiplier: 0.70)
        ]
        NSLayoutConstraint.activate(maxWidthConstraint)

        let constraints = [
            stackView.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            stackView.safeAreaTopAnchor.constraint(equalTo: margins.topAnchor),
            stackView.safeAreaBottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
    }

    func configure(amount: String?, currency: String?, _ handler: @escaping EnteredAmountHandler) {
        if let amount = amount, let currencyCode = currency {
            currencySymbolLabel.text = TransferAmountCurrencyFormatter
                .getTransferAmountCurrency(for: currencyCode)?.symbol
            currencySymbolLabel.adjustsFontForContentSizeCategory = true
            amountTextField.text = TransferAmountCurrencyFormatter.format(amount: amount, with: currencyCode)
            amountTextField.adjustsFontSizeToFitWidth = true
            amountTextField.adjustsFontForContentSizeCategory = true
            currencyLabel.text = currencyCode
            currencyLabel.adjustsFontForContentSizeCategory = true
            enteredAmountHandler = handler
            formattedZeroAmount = TransferAmountCurrencyFormatter.format(amount: formattedZeroAmount,
                                                                         with: currencyCode)
            numberOfDecimals = amountTextField.text?
                .split(separator: Character(NumberFormatter().decimalSeparator)).last?.count ?? 0
            defaultNumberOfDigits = TransferAmountCurrencyFormatter
                .getTransferAmountCurrency(for: currencyCode)?.decimals ?? 0
        }
    }
}

extension TransferAmountCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if inputAmount.isEmpty {
            inputAmount = textField.text ?? ""
        } else if defaultNumberOfDigits > 0, !inputAmount.isEmpty {
            let index = inputAmount.index(inputAmount.endIndex,
                                          offsetBy: -defaultNumberOfDigits)
            inputAmount.insert(contentsOf: ".", at: index)
        }
        enteredAmountHandler?(inputAmount)
    }

    /// Format currency text
    /// - Parameter textField: Amount text field
    private func formatCurrencyText(for textField: UITextField) {
        if let textFieldText = textField.text, !textFieldText.isEmpty, let currencyCode = currencyLabel.text {
            let currentText = digits(amount: textFieldText)
            let decimalSymbol = currentText.decimalSymbol(for: currencyCode)
            ////Shift positions only when amount is having more than one digit
            if currentText.count > 1 && textFieldText.contains(decimalSymbol) {
                let index = currentText.index(currentText.endIndex,
                                              offsetBy: -numberOfDecimals)
                let tempText = String(currentText[currentText.startIndex..<index]
                    + "\(decimalSymbol)"
                    + currentText[index..<currentText.endIndex])
                textField.text = TransferAmountCurrencyFormatter.format(amount: tempText, with: currencyCode)
            } else {
                textField.text = TransferAmountCurrencyFormatter.format(amount: currentText, with: currencyCode)
            }
        }
        setCursorToTheEnd(textField)
    }

    private func setCursorToTheEnd(_ textField: UITextField) {
        DispatchQueue.main.async {
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }

    private func digits(amount: String) -> String {
        return amount.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let maximumIntegerDigits = 12
        var currentText = textField.text ?? ""

        // BackSpace
        if string.isEmpty {
            if currentText == formattedZeroAmount {
                return false
            } else if digits(amount: currentText).count <= defaultNumberOfDigits {
                currentText.insert("0", at: currentText.startIndex)
                textField.text = currentText
                return true
            }
            inputAmount = String(inputAmount.dropLast())
            return true
        }
        inputAmount += string
        return digits(amount: currentText).count < maximumIntegerDigits
    }
}

extension TransferAmountCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var currencySymbolLabelFont: UIFont! {
        get { return currencySymbolLabel.font }
        set { currencySymbolLabel.font = newValue
            currencySymbolLabel.font = newValue }
    }

    @objc dynamic var currencySymbolLabelColor: UIColor! {
        get { return currencySymbolLabel.textColor }
        set { currencySymbolLabel.textColor = newValue
            currencySymbolLabel.textColor = newValue }
    }

    @objc dynamic var amountTextFieldFont: UIFont! {
        get { return amountTextField.font }
        set { amountTextField.font = newValue }
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
