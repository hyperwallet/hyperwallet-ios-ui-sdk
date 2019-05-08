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

import HyperwalletSDK
import UIKit

final class PasteOnlyTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(paste(_:))
    }
}

/// Represents the text input widget.
class TextWidget: AbstractWidget {
    var textField: PasteOnlyTextField = {
        let textField = PasteOnlyTextField()
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        if #available(iOS 11.0, *) {
            textField.textDragInteraction?.isEnabled = false
        }
        return textField
    }()

    required init(field: HyperwalletField) {
        super.init(field: field)
        setupLayout(field: field)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func value() -> String {
        return textField.text ?? ""
    }

    override func focus() {
        textField.becomeFirstResponder()
    }

    override func handleTap(sender: UITapGestureRecognizer? = nil) {
        focus()
    }

    override func setupLayout(field: HyperwalletField) {
        super.setupLayout(field: field)
        setUpTextField(for: field)
    }

    private func setUpTextField(for field: HyperwalletField) {
        textField.placeholder = "\(field.placeholder ?? "")"
        textField.delegate = self
        textField.accessibilityIdentifier = field.name
        let isEditable = field.isEditable ?? true
        textField.isUserInteractionEnabled = isEditable
        textField.clearButtonMode = isEditable ? .always : .never
        textField.textColor = isEditable ? Theme.Text.color : Theme.Text.disabledColor
        self.addArrangedSubview(textField)
    }
}
