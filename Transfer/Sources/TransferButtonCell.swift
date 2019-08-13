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

    private(set) lazy var buttonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "createTransferNextLabel"
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupCell() {
        contentView.addSubview(buttonLabel)

        let margins = contentView.layoutMarginsGuide
        let constraints = [
            buttonLabel.safeAreaLeadingAnchor.constraint(equalTo: margins.leadingAnchor),
            buttonLabel.safeAreaTrailingAnchor.constraint(equalTo: margins.trailingAnchor),
            buttonLabel.safeAreaTopAnchor.constraint(equalTo: margins.topAnchor),
            buttonLabel.safeAreaBottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
    }

    /// This is to configure the next button in create transfer page
    func configure(title: String) {
        buttonLabel.text = title
        buttonLabel.accessibilityLabel = title
    }

    /// This is to configure the confirmation button in schedule transfer page
    func configure(title: String, action: UIGestureRecognizer) {
        buttonLabel.text = title
        buttonLabel.accessibilityLabel = title
        buttonLabel.accessibilityIdentifier = "scheduleTransferLabel"
        buttonLabel.isUserInteractionEnabled = true
        buttonLabel.addGestureRecognizer(action)
    }
}

extension TransferButtonCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return buttonLabel.font }
        set { buttonLabel.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return buttonLabel.textColor }
        set { buttonLabel.textColor = newValue }
    }
}
