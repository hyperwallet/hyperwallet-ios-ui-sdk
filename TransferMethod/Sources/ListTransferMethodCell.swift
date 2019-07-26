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

public final class ListTransferMethodCell: UITableViewCell {
    public static let reuseIdentifier = "listTransferMethodCellIdentifier"

    // MARK: Life cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.heightAnchor.constraint(equalToConstant: Theme.Cell.largeHeight).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imageView?.backgroundColor = Theme.Icon.primaryBackgroundColor
    }

    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        imageView?.backgroundColor = Theme.Icon.primaryBackgroundColor
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

extension ListTransferMethodCell {
    /// Fill `ListTransferMethodCell` related fields
    ///
    /// - Parameter transferMethod: a transfer method which contains the info needs to be filled to the cell.
    public func configure(transferMethod: HyperwalletTransferMethod) {
        textLabel?.text = transferMethod.type?.lowercased().localized()
        textLabel?.accessibilityIdentifier = "ListTransferMethodTableViewCellTextLabel"
        detailTextLabel?.attributedText = formatDetails(
            transferMethodCountry: transferMethod.transferMethodCountry?.localized() ?? "",
            additionalInfo: transferMethod.additionalInfo)

        detailTextLabel?.accessibilityIdentifier = "ListTransferMethodTableViewCellDetailTextLabel"
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.lineBreakMode = .byWordWrapping
        let icon = UIImage.fontIcon(HyperwalletIcon.of(transferMethod.type ?? "").rawValue,
                                    Theme.Icon.frame,
                                    CGFloat(Theme.Icon.size),
                                    Theme.Icon.primaryColor)
        imageView?.image = icon
        imageView?.layer.cornerRadius = CGFloat(Theme.Icon.frame.width / 2)
    }

    func formatDetails(transferMethodCountry: String, additionalInfo: String?) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        attributedText.append(value: String(format: "%@\n", transferMethodCountry),
                              font: subTitleLabelFont,
                              color: subTitleLabelColor)
        if let additionalInfo = additionalInfo {
            attributedText.append(value: additionalInfo, font: subTitleLabelFont, color: subTitleLabelColor)
        }

        return attributedText
    }
}
