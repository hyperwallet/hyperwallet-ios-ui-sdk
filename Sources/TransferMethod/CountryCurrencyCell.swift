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

/// Represents the country and currency data to be displyed on the CountryCurrencyCell
struct CountryCurrencyCellConfiguration {
    let title: String
    let value: String

    var identifier: String {
        return "cell\(title)"
    }
}

/// Represents the Country and Currency cell
final class CountryCurrencyCell: GenericCell<CountryCurrencyCellConfiguration> {
    static let reuseId = "CountryCurrencyCellId"

    // MARK: Property
    override var item: CountryCurrencyCellConfiguration? {
        didSet {
            guard let configuration = item  else {
                return
            }
            accessibilityIdentifier = configuration.identifier

            var value = configuration.value
            if accessoryType == .checkmark {
                value = ""
            }

            titleLabel.text = configuration.title
            titleLabel.accessibilityLabel = configuration.title
            titleLabel.accessibilityIdentifier = configuration.title

            valueLabel.text = value
            valueLabel.accessibilityLabel = configuration.value
            valueLabel.accessibilityIdentifier = configuration.value
        }
    }

    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    // MARK: Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Theme manager's proxy properties
    @objc dynamic var viewBackgroundColor: UIColor! {
        get { return self.contentView.backgroundColor }
        set { self.contentView.backgroundColor = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return self.titleLabel.textColor }
        set { self.titleLabel.textColor = newValue }
    }

    @objc dynamic var titleLabelFont: UIFont! {
        get { return self.titleLabel.font }
        set { self.titleLabel.font = newValue }
    }

    @objc dynamic var valueLabelColor: UIColor! {
        get { return self.valueLabel.textColor }
        set { self.valueLabel.textColor = newValue }
    }

    @objc dynamic var valueLabelFont: UIFont! {
        get { return self.valueLabel.font }
        set { self.valueLabel.font = newValue }
    }
}
