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

final class TransferDestinationCell: UITableViewCell {
    public static let reuseIdentifier = "transferDestinationCellIdentifier"

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

extension TransferDestinationCell {
    func configure(transferMethod: HyperwalletTransferMethod) {
        textLabel?.text = transferMethod.title
        textLabel?.adjustsFontForContentSizeCategory = true
        textLabel?.accessibilityIdentifier = "transferDestinationTitleLabel"
        let subTitle = transferMethod.isPrepaidCard() ?
            transferMethod.transferMethodCurrency :
            Locale.current.localizedString(forRegionCode: transferMethod.transferMethodCountry ?? "")
        detailTextLabel?.attributedText = formatDetails(
            subtitle: subTitle ?? "",
            additionalInfo: transferMethod.value)

        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.adjustsFontForContentSizeCategory = true
        detailTextLabel?.lineBreakMode = .byWordWrapping
        detailTextLabel?.accessibilityIdentifier = "transferDestinationSubtitleLabel"
        if !UIFont.isLargeSizeCategory {
            let icon = UIImage.fontIcon(HyperwalletIcon.of(transferMethod.type ?? "").rawValue,
                                        Theme.Icon.frame,
                                        CGFloat(Theme.Icon.size),
                                        Theme.Icon.primaryColor)
            imageView?.image = icon
            imageView?.layer.cornerRadius = CGFloat(Theme.Icon.frame.width / 2)
        }
    }

    func configure(_ title: String, _ hyperwalletIcon: HyperwalletIconContent) {
        textLabel?.text = title
        textLabel?.adjustsFontForContentSizeCategory = true
        textLabel?.numberOfLines = 0
        textLabel?.lineBreakMode = .byWordWrapping
        textLabel?.accessibilityIdentifier = "transferDestinationTitleLabel"
        detailTextLabel?.text = nil
        detailTextLabel?.accessibilityIdentifier = nil
        if !UIFont.isLargeSizeCategory {
            let icon = UIImage.fontIcon(hyperwalletIcon.rawValue,
                                        Theme.Icon.frame,
                                        CGFloat(Theme.Icon.addTransferMethodIconSize),
                                        Theme.Icon.primaryColor)
            imageView?.image = icon
            imageView?.layer.cornerRadius = CGFloat(Theme.Icon.frame.width / 2)
        }
    }

    private func formatDetails(subtitle: String, additionalInfo: String? = nil) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        let stringFormat = additionalInfo != nil ? "%@\n" : "%@"
        attributedText.append(value: String(format: stringFormat, subtitle),
                              font: subTitleLabelFont,
                              color: subTitleLabelColor)
        if let additionalInfo = additionalInfo {
            attributedText.append(value: additionalInfo, font: subTitleLabelFont, color: subTitleLabelColor)
        }

        return attributedText
    }
}
