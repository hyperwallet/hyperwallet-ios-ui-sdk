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

final class CreateTransferAmountCell: UITableViewCell {
    static let reuseIdentifier = "createTransferAmountCellReuseIdentifier"
    typealias EnteredAmountHandler = (_ value: String) -> Void

    var enteredAmountHandler: EnteredAmountHandler?

    lazy var amountTextField: PasteOnlyTextField = {
        let textField = PasteOnlyTextField(frame: .zero)
        textField.textAlignment = .right
        textField.keyboardType = UIKeyboardType.numberPad
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.heightAnchor.constraint(equalToConstant: Theme.Cell.smallHeight).isActive = true
        self.selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(tap)

        setUpTitleLabel()
        setupAmountTextField()
    }

    @objc
    private func didTapCell() {
        amountTextField.becomeFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setUpTitleLabel() {
        textLabel?.text = "transfer_amount".localized()
    }

    private func setupAmountTextField() {
        contentView.addSubview(amountTextField)
        amountTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        amountTextField.leadingAnchor.constraint(equalTo: textLabel!.trailingAnchor,
                                                 constant: 10).isActive = true
        amountTextField.trailingAnchor.constraint(equalTo: detailTextLabel!.leadingAnchor,
                                                  constant: -10).isActive = true
    }

    func configure(amount: String?, currency: String, _ handler: @escaping EnteredAmountHandler) {
        amountTextField.text = amount
        detailTextLabel?.text = currency
        enteredAmountHandler = handler
    }
}

extension CreateTransferAmountCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        enteredAmountHandler?(amountTextField.text ?? "")
    }
}

extension CreateTransferAmountCell {
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
