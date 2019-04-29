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
class ExpiryDateWidget: TextWidget {
    var pickerView: MonthYearPickerView!

    required init(field: HyperwalletField) {
        super.init(field: field)
        setupLayout(field: field)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setupLayout(field: HyperwalletField) {
        super.setupLayout(field: field)
        pickerView = MonthYearPickerView(frame: CGRect(x: 0,
                                                       y: UIScreen.main.bounds.height - 216,
                                                       width: UIScreen.main.bounds.width,
                                                       height: 216))
        attachPickerView(pickerView: pickerView)
    }

    private func attachPickerView(pickerView: MonthYearPickerView) {
        self.pickerView = pickerView
        pickerView.toolBarDelegate = self
        textField.inputView = self.pickerView
        textField.inputAccessoryView = pickerView.toolbar
    }

    /// format the expiryDate to YYYY-MM, which can be accepted by server through REST API call
    ///
    /// - Returns: formatted expiryDate
    override func value() -> String {
        if textField.text?.isEmpty ?? true {
            return ""
        } else {
            return String(format: "%04d-%02d", pickerView.year, pickerView.month)
        }
    }
}

// MARK: - Tap toolbar -

extension ExpiryDateWidget: ToolbarPickerViewDelegate {
    func didTapDone(_ tapDoneHandler: (_ textField: UITextField) -> Void) {
        tapDoneHandler(textField)
        textField.resignFirstResponder()
    }
}
