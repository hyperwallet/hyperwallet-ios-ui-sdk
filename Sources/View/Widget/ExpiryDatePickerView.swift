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
    private let currentDate = Date()

    var month: Int! {
        return selectedDateComponents.value(for: .month)
    }

    var year: Int! {
        return selectedDateComponents.value(for: .year)
    }

    private lazy var firstYear: Int = {
        calendar.component(.year, from: currentDate)
    }()

    private lazy var locale: Locale = {
        Locale(identifier: Locale.preferredLanguages[0])
    }()

    private lazy var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = locale
        return calendar
    }()

    private lazy var localizedYearDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("y")
        return formatter
    }()

    private lazy var expiryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "expiry_date_picker_format".localized()
        return formatter
    }()

    private var selectedDateComponents = DateComponents()
    private var localizedMonths = [String]()
    private var localizedYears = [String]()

    convenience init(value: String?, frame: CGRect = .zero) {
        self.init(frame: frame)
        setSelectedDateComponents(for: currentDate)
        if let value = value, let date = expiryDateFormatter.date(from: value) {
            setSelectedDateComponents(for: date)
        }
        setupMonthsYears()

        delegate = self
        dataSource = self

        selectRow(month - 1, inComponent: 0, animated: false)
        selectRow(year % firstYear, inComponent: 1, animated: false)
    }

    func setSelectedDateComponents(for date: Date) {
        selectedDateComponents.calendar = calendar
        selectedDateComponents.setValue(1, for: .day)
        selectedDateComponents.setValue(calendar.component(.month, from: date), for: .month)
        selectedDateComponents.setValue(calendar.component(.year, from: date), for: .year)
    }

    // MARK: UIPicker Delegate / Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 2 }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let value = component == 0
            ? row + 1
            : row + firstYear
        let component: Calendar.Component = component == 0
            ? .month
            : .year
        selectedDateComponents.setValue(value, for: component)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? localizedMonths.count : localizedYears.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? localizedMonths[row] : localizedYears[row]
    }

    private func setupMonthsYears(yearsRange: Int = 10) {
        localizedMonths = localizedYearDateFormatter.standaloneMonthSymbols.map({ $0.capitalized })
        localizedYears = (firstYear...firstYear + yearsRange).map({
            let date = calendar.date(bySetting: .year, value: $0, of: currentDate)!
            return localizedYearDateFormatter.string(from: date)
        })
    }
}
