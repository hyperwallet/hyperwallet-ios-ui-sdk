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

final class TransferInfoCell: UITableViewCell {
    static let reuseIdentifier = "transferInfoCellIdentifier"
    typealias EnteredNoteHandler = (_ value: String?) -> Void

    private var enteredNoteHandler: EnteredNoteHandler?

    private lazy var infoTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "transfer_description".localized()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.accessibilityIdentifier = "transferInfoTextField"
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupCell() {
        contentView.addSubview(infoTextField)

        let margins = contentView.layoutMarginsGuide
        let constraints = [
            infoTextField.safeAreaLeadingAnchor.constraint(equalTo: margins.leadingAnchor),
            infoTextField.safeAreaTrailingAnchor.constraint(equalTo: margins.trailingAnchor),
            infoTextField.safeAreaTopAnchor.constraint(equalTo: margins.topAnchor),
            infoTextField.safeAreaBottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
    }

    func configure(info: String?, isEditable: Bool, _ handler: @escaping EnteredNoteHandler) {
        if let info = info {
            infoTextField.text = info
        }
        infoTextField.isEnabled = isEditable
        enteredNoteHandler = handler
    }
}

extension TransferInfoCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        enteredNoteHandler?(infoTextField.text)
    }
}

extension TransferInfoCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var infoTextFieldFont: UIFont! {
        get { return infoTextField.font }
        set { infoTextField.font = newValue }
    }

    @objc dynamic var infoTextFieldColor: UIColor! {
        get { return infoTextField.textColor }
        set { infoTextField.textColor = newValue }
    }
}
