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

/// Represents the date input widget.
final class DateWidget: TextWidget {
    var toolbar = UIToolbar()
    private var datePicker: UIDatePicker!

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    required init(field: HyperwalletField) {
        super.init(field: field)
        setupLayout(field: field)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setupLayout(field: HyperwalletField) {
        super.setupLayout(field: field)
        setupDatePicker()
        toolbar.setupToolBar(target: self, action: #selector(self.doneButtonTapped))
        setupTextField()
    }

    private func setupDatePicker() {
        datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(updateTextField), for: .valueChanged)
        datePicker.accessibilityIdentifier = "DateWidgetPickerAccessibilityIdentifier"
    }

    private func setupTextField() {
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
        textField.delegate = self
    }

    @objc
    private func updateTextField() {
        textField.text = DateWidget.dateFormatter.string(from: datePicker.date)
    }

    @objc
    private func doneButtonTapped() {
        updateTextField()
        textField.resignFirstResponder()
    }

//    override func textFieldDidBeginEditing(_ textField: UITextField) {
//        super.textFieldDidBeginEditing(textField)
//        if let dateFromText = DateWidget.dateFormatter.date(from: value()) {
//            datePicker.date = dateFromText
//        }
//    }
}
