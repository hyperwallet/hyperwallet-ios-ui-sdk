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
final class ExpiryDateWidget: NumberWidget {
    private static let dateTextFieldFormat = "##/##"
    private static let dateApiFormat = "yyyy-MM"
    private static let placeholderText = "MM/YY"
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter
    }()

    override func setupLayout(field: HyperwalletField) {
        super.setupLayout(field: field)
        setPlaceholderText()
    }

    override func textFieldDidChange() {
        let text = getUnformattedText()
        if !text.isEmpty {
            textField.text = formatDisplayString(with: ExpiryDateWidget.dateTextFieldFormat, inputText: text)
        } else {
            textField.text = ""
            setPlaceholderText()
        }
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        if textField.text?.isEmpty ?? true {
            setPlaceholderText()
        }
    }

    /// format the expiryDate to YYYY-MM, which can be accepted by server through REST API call
    ///
    /// - Returns: formatted expiryDate
    override func value() -> String {
        if let text = textField.text, !(textField.text?.isEmpty ?? true) {
            return formatExpiryDateForApi(text)
        }
        return ""
    }

    func formatExpiryDateForApi(_ text: String) -> String {
        let date = ExpiryDateWidget.dateFormatter.date(from: text)
        return date?.formatDateToString(dateFormat: ExpiryDateWidget.dateApiFormat) ?? ""
    }

    private func setPlaceholderText() {
        textField.placeholder = ExpiryDateWidget.placeholderText
    }
}
