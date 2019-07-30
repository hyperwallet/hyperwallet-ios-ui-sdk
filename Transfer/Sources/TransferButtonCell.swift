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

final class TransferButtonCell: UITableViewCell {
    static let reuseIdentifier = "transferButtonCellIdentifier"

    private(set) lazy var nextLabel: UILabel = {
        let label = UILabel()
        label.textColor = Theme.Button.color
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityLabel = "transfer_next_button".localized()
        label.accessibilityIdentifier = "addTransferNextLabel"
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nextLabel)
        nextLabel.safeAreaCenterYAnchor
            .constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor).isActive = true
        nextLabel.safeAreaCenterXAnchor
            .constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(title: String) {
        nextLabel.text = title
    }
}

extension TransferButtonCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return nextLabel.font }
        set { nextLabel.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return nextLabel.textColor }
        set { nextLabel.textColor = newValue }
    }
}
