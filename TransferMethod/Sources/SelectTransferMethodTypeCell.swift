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
import HyperwalletSDK
import UIKit

final class SelectTransferMethodTypeCell: UITableViewCell {
    static let reuseIdentifier = "selectTransferMethodTypeCellIdentifier"

    // MARK: Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imageView?.backgroundColor = Theme.Icon.primaryBackgroundColor
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        imageView?.backgroundColor = Theme.Icon.primaryBackgroundColor
    }

    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelColor: UIColor! {
        get { return self.textLabel?.textColor }
        set { self.textLabel?.textColor = newValue }
    }

    @objc dynamic var titleLabelFont: UIFont! {
        get { return self.textLabel?.font }
        set { self.textLabel?.font = newValue }
    }

    @objc dynamic var subTitleLabelColor: UIColor! {
        get { return self.detailTextLabel?.textColor }
        set { self.detailTextLabel?.textColor = newValue }
    }

    @objc dynamic var subTitleLabelFont: UIFont! {
        get { return self.detailTextLabel?.font }
        set { self.detailTextLabel?.font = newValue }
    }
}

extension SelectTransferMethodTypeCell {
    func configure(configuration: HyperwalletTransferMethodType?) {
        if let configuration = configuration {
            accessibilityIdentifier = configuration.name

            textLabel?.text = configuration.name
            textLabel?.numberOfLines = 0
            textLabel?.lineBreakMode = .byWordWrapping
            textLabel?.adjustsFontForContentSizeCategory = true

            detailTextLabel?.attributedText = configuration
                .formatFeesProcessingTime(font: subTitleLabelFont, color: subTitleLabelColor)
            detailTextLabel?.numberOfLines = 0
            detailTextLabel?.lineBreakMode = .byWordWrapping
            detailTextLabel?.adjustsFontForContentSizeCategory = true
            if !UIFont.isLargeSizeCategory {
                let icon = UIImage.fontIcon(HyperwalletIcon.of(configuration.code!).rawValue,
                                            Theme.Icon.frame,
                                            CGFloat(Theme.Icon.size),
                                            Theme.Icon.primaryColor)
                imageView?.image = icon
                imageView?.layer.cornerRadius = CGFloat(Theme.Icon.frame.width / 2)
            }
        }
    }
}
