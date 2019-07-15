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

struct CreateTransferUserInputCellConfiguration {
    let transferAllText: String
    let amountText: String
    let currency: String
    let description: String
}

final class CreateTransferUserInputCell: UITableViewCell, UITextFieldDelegate {
    static let reuseIdentifier = "createTransferUserInputCellReuseIdentifier"

    var enteredAmount: ((_ value: String) -> Void)?
    var transferAllSwitchOn: ((_ value: Bool) -> Void)?

    lazy var amountTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: separatorInset.left,
                                                  y: 0,
                                                  width: bounds.width / 2,
                                                  height: bounds.height))
        textField.font = titleLabelFont
        textField.keyboardType = UIKeyboardType.numberPad
        textField.placeholder = "transfer_amount".localized()
        textField.delegate = self
        return textField
    }()

    lazy var currencyLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private var transferAllFundsLabel: UILabel = {
        let label = UILabel()
        label.text = "transfer_all_funds".localized()
        return label
    }()

    private var transferAllFundsSwitch: UISwitch = {
        let `switch` = UISwitch(frame: .zero)
        `switch`.setOn(false, animated: false)
        return `switch`
    }()

    func configure(amount: String?, currency: String, at index: Int) {
        if index == 0 {
            amountTextField.text = amount
            currencyLabel.text = currency
            textLabel?.text = amountTextField.text

            detailTextLabel?.text = currencyLabel.text
        } else {
            textLabel?.text = transferAllFundsLabel.text
            transferAllFundsSwitch.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
            accessoryView = transferAllFundsSwitch
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enteredAmount?(amountTextField.text ?? "")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.heightAnchor.constraint(equalToConstant: Theme.Cell.smallHeight).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CreateTransferUserInputCell {
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
        set { detailTextLabel?.font = newValue }
    }

    @objc dynamic var subTitleLabelColor: UIColor! {
        get { return detailTextLabel?.textColor }
        set { detailTextLabel?.textColor = newValue }
    }

    @objc
    func switchStateDidChange(_ sender: UISwitch) {
        if sender.isOn == true {
            print("isON")
            amountTextField.text = "200.00"
            transferAllSwitchOn?(true)
            enteredAmount?(amountTextField.text ?? "")
        } else {
            print("isOFF")
            amountTextField.text = ""
            transferAllSwitchOn?(false)
            enteredAmount?(amountTextField.text ?? "")
        }
    }
}
