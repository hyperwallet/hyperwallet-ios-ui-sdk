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

    lazy var amountTextField: PasteOnlyTextField = {
        let textField = PasteOnlyTextField(frame: .zero)
        textField.textAlignment = .right
        textField.keyboardType = UIKeyboardType.numberPad
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.accessibilityIdentifier = "transferAmountTextField"
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(tap)

        setupAmountTextField()
    }

    @objc
    private func didTapCell() {
        amountTextField.becomeFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupAmountTextField() {
        textLabel?.accessibilityIdentifier = "transferAmountTitleLabel"
        detailTextLabel?.accessibilityIdentifier = "transferAmountCurrencyLabel"
        contentView.addSubview(amountTextField)

      let constraints = [
            amountTextField.safeAreaCenterYAnchor
                .constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            amountTextField.safeAreaTrailingAnchor
                .constraint(equalTo: detailTextLabel!.layoutMarginsGuide.leadingAnchor, constant: -15),
            amountTextField.safeAreaLeadingAnchor
                .constraint(equalTo: textLabel!.layoutMarginsGuide.trailingAnchor, constant: 15)
        ]
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
    }

    func configure(amount: String?, currency: String?, isEnabled: Bool, _ handler: @escaping EnteredAmountHandler) {
        textLabel?.text = "transfer_amount".localized()
        amountTextField.text = amount
        amountTextField.isEnabled = isEnabled
        detailTextLabel?.text = currency ?? String(repeating: " ", count: 3)
        enteredAmountHandler = handler
    }
}

extension TransferAmountCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        enteredAmountHandler?(amountTextField.text ?? "")
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        var currentText = textField.text ?? ""
        if string.count > 1 {
            // Paste
            let stringPastedAmount = string.format(with: detailTextLabel?.text)
            guard !stringPastedAmount.isEmpty,
                currentText.isEmpty else {
                    return false
            }
            textField.text = stringPastedAmount
            return false
        }
        let digitsOnly = currentText.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        if string.isEmpty {
            // backspace
            currentText = digitsOnly.dropLast().description
        } else {
            // digit
            currentText = digitsOnly + string
        }

        if Double(currentText) == 0 {
            textField.text = ""
            return false
        }

        currentText = "0" + currentText
        currentText.insert(".", at: currentText.index(currentText.endIndex, offsetBy: -2))
        textField.text = currentText.format(with: detailTextLabel?.text)
        return false
    }
}

extension TransferAmountCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return textLabel?.font }
        set { textLabel?.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return textLabel?.textColor }
        set { textLabel?.textColor = newValue }
    }

    @objc dynamic var currencyLabelFont: UIFont! {
        get { return detailTextLabel?.font }
        set { detailTextLabel?.font = newValue }
    }

    @objc dynamic var currencyLabelColor: UIColor! {
        get { return detailTextLabel?.textColor }
        set { detailTextLabel?.textColor = newValue }
    }
}
