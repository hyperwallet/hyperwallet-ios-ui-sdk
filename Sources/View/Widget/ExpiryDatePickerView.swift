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

import UIKit

final class ExpiryDatePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var month: Int!
    var year: Int!

    private var months = [String]()
    private var years = [Int]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {
        let currentDate = Date()
        let currentCalendar = Calendar.current
        month = currentCalendar.component(.month, from: currentDate)
        year = currentCalendar.component(.year, from: currentDate)

        setupMonths()
        setupYears(add: 10)

        self.delegate = self
        self.dataSource = self

        // pick current month as default month for the picker and place the selected month in the center of picker
        self.selectRow(month - 1, inComponent: 0, animated: false)
    }

    private func setupMonths() {
        months = DateFormatter().monthSymbols.map({ $0.capitalized })
    }

    private func setupYears(add: Int) {
        years = Array(year...year + add)
    }

    // MARK: UIPicker Delegate / Data Source

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return months[row % months.count]

        case 1:
            return String(describing: years[row])

        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count

        case 1:
            return years.count

        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        month = selectedRow(inComponent: 0) + 1
        year = years[selectedRow(inComponent: 1)]
    }
}
