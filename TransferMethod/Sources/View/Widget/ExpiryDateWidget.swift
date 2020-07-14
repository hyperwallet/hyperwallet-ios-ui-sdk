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

/// Represents the expiry date widget.
final class ExpiryDateWidget: TextWidget {
    private static let placeholderText = "MM/YY"
    private static let expiryDateFormat = "##/##"

    override func setupLayout(field: HyperwalletField) {
        super.setupLayout(field: field)
        setupTextField()
    }

    override func textFieldDidChange() {
        let text = getUnformattedText()
        if !text.isEmpty {
            textField.text = formatDisplayString(with: ExpiryDateWidget.expiryDateFormat, inputText: text)
        } else {
            textField.text = ""
            textField.placeholder = ExpiryDateWidget.placeholderText
        }
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        if textField.text?.isEmpty ?? true {
            textField.placeholder = ExpiryDateWidget.placeholderText
        }
    }

    /// format the expiryDate to YYYY-MM, which can be accepted by server through REST API call
    ///
    /// - Returns: formatted expiryDate
    override func value() -> String {
        if let text = textField.text, !(textField.text?.isEmpty ?? true) {
            let year = "20" + text.suffix(2) // TODO find a better way of doing this
            let month = String(text.prefix(2))
            return String(format: "%@-%@", year, month)
        }
        return ""
    }

    private func setupTextField() {
        textField.placeholder = ExpiryDateWidget.placeholderText
        textField.keyboardType = UIKeyboardType.numberPad
    }
}
