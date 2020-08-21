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
import UIKit

/// Represents the Country and Currency Generic cell
final class CountryCurrencySelectionCell: GenericCell<GenericCellConfiguration> {
    static let reuseIdentifier = "countryCurrencySelectionCellIdentifier"
    private let trailingConstraintIdentifier = "trailingConstraintIdentifier"

    // MARK: Property
    override var item: GenericCellConfiguration? {
        didSet {
            guard let configuration = item  else {
                return
            }
            accessibilityIdentifier = configuration.identifier

            textLabel?.text = configuration.title
            textLabel?.adjustsFontForContentSizeCategory = true
            textLabel?.accessibilityLabel = configuration.title
            textLabel?.accessibilityIdentifier = configuration.title
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc dynamic var textLabelColor: UIColor! {
        get { return textLabel?.textColor }
        set { textLabel?.textColor = newValue }
    }

    @objc dynamic var textLabelFont: UIFont! {
        get { return textLabel?.font }
        set { textLabel?.font = newValue }
    }
}
