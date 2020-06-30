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

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.accessibilityIdentifier = "transferDestinationTitleLabel"
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.accessibilityIdentifier = "transferDestinationSubtitleLabel"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    private func setupCell() {
        let stackView = UIStackView(frame: .zero)
        let stackViewLeadingConstraints: NSLayoutConstraint
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 2
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)
        stackViewLeadingConstraints = !UIFont.isLargeSizeCategory ? stackView.leadingAnchor
            .constraint(equalTo: imageView!.trailingAnchor, constant: 15) : stackView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 20)
        NSLayoutConstraint.activate([
            stackViewLeadingConstraints,
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0)
        ])
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
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }

    @objc dynamic var subTitleLabelFont: UIFont! {
        get { return subtitleLabel.font }
        set { subtitleLabel.font = newValue }
    }

    @objc dynamic var subTitleLabelColor: UIColor! {
        get { return subtitleLabel.textColor }
        set { subtitleLabel.textColor = newValue }
    }
}

extension TransferDestinationCell {
    func configure(transferMethod: HyperwalletTransferMethod) {
        titleLabel.text = transferMethod.title
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.attributedText = formatDetails(
            subtitle: Locale.current.localizedString(forRegionCode: transferMethod.transferMethodCountry ?? "") ?? "",
            additionalInfo: transferMethod.value)

        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.lineBreakMode = .byWordWrapping
        if !UIFont.isLargeSizeCategory {
            let icon = UIImage.fontIcon(HyperwalletIcon.of(transferMethod.type ?? "").rawValue,
                                        Theme.Icon.frame,
                                        CGFloat(Theme.Icon.size),
                                        Theme.Icon.primaryColor)
            imageView?.image = icon
            imageView?.layer.cornerRadius = CGFloat(Theme.Icon.frame.width / 2)
        }
    }

    func configure(_ title: String, _ subtitle: String, _ hyperwalletIcon: HyperwalletIconContent) {
        titleLabel.text = title
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.attributedText = formatDetails(subtitle: subtitle)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.lineBreakMode = .byWordWrapping
        if !UIFont.isLargeSizeCategory {
            let icon = UIImage.fontIcon(hyperwalletIcon.rawValue,
                                        Theme.Icon.frame,
                                        CGFloat(Theme.Icon.size),
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
