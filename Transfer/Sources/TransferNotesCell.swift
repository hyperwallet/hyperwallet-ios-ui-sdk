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

final class TransferNotesCell: UITableViewCell {
    static let reuseIdentifier = "transferNotesCellIdentifier"
    typealias EnteredNoteHandler = (_ value: String?) -> Void

    private var enteredNoteHandler: EnteredNoteHandler?

    private lazy var notesTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = "transfer_description".localized()
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.accessibilityIdentifier = "transferNotesTextField"
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
        contentView.addSubview(notesTextField)

        let margins = contentView.layoutMarginsGuide
        let constraints = [
            notesTextField.safeAreaLeadingAnchor.constraint(equalTo: margins.leadingAnchor),
            notesTextField.safeAreaTrailingAnchor.constraint(equalTo: margins.trailingAnchor),
            notesTextField.safeAreaTopAnchor.constraint(equalTo: margins.topAnchor),
            notesTextField.safeAreaBottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
   }

    func configure(notes: String?, isEditable: Bool, _ handler: @escaping EnteredNoteHandler) {
        if let notes = notes {
            notesTextField.text = notes
        }
        notesTextField.isEnabled = isEditable
        enteredNoteHandler = handler
    }
}

extension TransferNotesCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        enteredNoteHandler?(notesTextField.text)
    }
}

extension TransferNotesCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var notesTextFieldFont: UIFont! {
        get { return notesTextField.font }
        set { notesTextField.font = newValue }
    }

    @objc dynamic var notesTextFieldColor: UIColor! {
        get { return notesTextField.textColor }
        set { notesTextField.textColor = newValue }
    }
}
