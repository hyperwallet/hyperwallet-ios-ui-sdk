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

struct ListTransferMethodCellConfiguration {
    let transferMethodType: String
    let transferMethodCountry: String
    let transferMethodExpiryDate: String
    let transferMethodIconFont: String
}

final class ListTransferMethodTableViewCell: UITableViewCell {
    // MARK: Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imageView?.backgroundColor = Theme.Icon.backgroundColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        imageView?.backgroundColor = Theme.Icon.backgroundColor
    }

    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return textLabel?.font }
        set { textLabel?.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return textLabel?.textColor }
        set { textLabel?.textColor = newValue }
    }

    @objc dynamic var subTitleLabelFont: UIFont! {
        get { return detailTextLabel?.font }
        set { detailTextLabel?.font = newValue
            detailTextLabel?.font = newValue }
    }

    @objc dynamic var subTitleLabelColor: UIColor! {
        get { return detailTextLabel?.textColor }
        set { detailTextLabel?.textColor = newValue }
    }
}

extension ListTransferMethodTableViewCell {
    func configure(configuration: ListTransferMethodCellConfiguration) {
        textLabel?.text = configuration.transferMethodType
        detailTextLabel?.attributedText = formatSubtitle(transferMethodCountry: configuration.transferMethodCountry,
                                                         expiryDate: configuration.transferMethodExpiryDate)
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.lineBreakMode = .byWordWrapping
        let iconSize = CGSize(width: Theme.Icon.width, height: Theme.Icon.height)

        let icon = UIImage.fontIcon(configuration.transferMethodIconFont,
                                    iconSize,
                                    CGFloat(Theme.Icon.size),
                                    Theme.Icon.color,
                                    Theme.Icon.backgroundColor)
        imageView?.image = icon
        imageView?.layer.cornerRadius = CGFloat(Theme.Icon.width / 2)
    }

    func formatSubtitle(transferMethodCountry: String, expiryDate: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        let font = Theme.Label.captionOne
        let color = Theme.Label.subTitleColor
        attributedText.append(value: String(format: "%@\n", transferMethodCountry), font: font, color: color)
        attributedText.append(value: expiryDate, font: font, color: color)

        return attributedText
    }
}
