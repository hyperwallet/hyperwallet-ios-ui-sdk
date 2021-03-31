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

enum TransferSourceType: String {
    case user
    case prepaidCard
}

class TransferSourceCellConfiguration {
    let type: TransferSourceType
    let token: String
    let title: String
    let fontIcon: HyperwalletIconContent
    var isSelected: Bool
    var availableBalance: String?
    var destinationCurrency: String?
    var additionalText: String?

    init(isSelectedTransferSource: Bool,
         type: TransferSourceType,
         token: String,
         title: String,
         fontIcon: HyperwalletIconContent) {
        self.isSelected = isSelectedTransferSource
        self.type = type
        self.token = token
        self.title = title
        self.fontIcon = fontIcon
    }
}

final class TransferSourceCell: UITableViewCell {
    public static let reuseIdentifier = "transferSourceCellIdentifier"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        set { detailTextLabel?.font = newValue }
    }

    @objc dynamic var subTitleLabelColor: UIColor! {
        get { return detailTextLabel?.textColor }
        set { detailTextLabel?.textColor = newValue }
    }
}

extension TransferSourceCell {
    func configure(transferSourceCellConfiguration: TransferSourceCellConfiguration) {
        configure(title: transferSourceCellConfiguration.title,
                  additionalInfo: transferSourceCellConfiguration.additionalText,
                  currency: transferSourceCellConfiguration.destinationCurrency,
                  availableBalance: transferSourceCellConfiguration.availableBalance,
                  fontIcon: transferSourceCellConfiguration.fontIcon.rawValue,
                  type: transferSourceCellConfiguration.type)
    }

    private func configure(title: String,
                           additionalInfo: String? = nil,
                           currency: String?,
                           availableBalance: String?,
                           fontIcon: String,
                           type: TransferSourceType) {
        textLabel?.text = title
        textLabel?.adjustsFontForContentSizeCategory = true
        textLabel?.numberOfLines = 0
        textLabel?.lineBreakMode = .byWordWrapping
        textLabel?.accessibilityIdentifier = "transferSourceTitleLabel"
        detailTextLabel?.text = type == .user ? currency : additionalInfo
        detailTextLabel?.adjustsFontSizeToFitWidth = true
        detailTextLabel?.minimumScaleFactor = 0.1
        detailTextLabel?.numberOfLines = 2
        detailTextLabel?.accessibilityIdentifier = availableBalance == nil ? nil : "transferSourceSubtitleLabel"

        if !UIFont.isLargeSizeCategory {
            let icon = UIImage.fontIcon(fontIcon,
                                        Theme.Icon.frame,
                                        CGFloat(Theme.Icon.size),
                                        Theme.Icon.primaryColor)
            imageView?.image = icon
            imageView?.layer.cornerRadius = CGFloat(Theme.Icon.frame.width / 2)
        }
    }
}
