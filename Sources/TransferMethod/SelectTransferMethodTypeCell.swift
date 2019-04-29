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
struct SelectTransferMethodTypeConfiguration {
    let transferMethodType: String
    let feesProcessingTime: NSAttributedString
    let transferMethodIconFont: String
}

final class SelectTransferMethodTypeCell: UITableViewCell {
    static let reuseId = "SelectTransferMethodTypeCellIdentifier"

    // MARK: IBOutlets
    @IBOutlet weak var iconView: IconView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        iconView.backgroundColor = Theme.Icon.backgroundColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        iconView.backgroundColor = Theme.Icon.backgroundColor
    }

    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelColor: UIColor! {
        get { return self.titleLabel.textColor }
        set { self.titleLabel.textColor = newValue }
    }

    @objc dynamic var titleLabelFont: UIFont! {
        get { return self.titleLabel.font }
        set { self.titleLabel.font = newValue }
    }

    @objc dynamic var descriptionLabelColor: UIColor! {
        get { return self.descriptionLabel.textColor }
        set { self.descriptionLabel.textColor = newValue }
    }

    @objc dynamic var descriptionLabelFont: UIFont! {
        get { return self.descriptionLabel.font }
        set { self.descriptionLabel.font = newValue }
    }
}

extension SelectTransferMethodTypeCell {
    func configure(configuration: SelectTransferMethodTypeConfiguration) {
        accessibilityIdentifier = configuration.transferMethodType

        titleLabel.text = configuration.transferMethodType.localized()
        titleLabel.accessibilityIdentifier = "\(configuration.transferMethodType)_title"

        descriptionLabel.attributedText = configuration.feesProcessingTime
        descriptionLabel.accessibilityIdentifier = "\(configuration.transferMethodType)_description"

        iconView.draw(fontName: configuration.transferMethodIconFont)
        iconView.accessibilityIdentifier = configuration.transferMethodIconFont
    }
}
