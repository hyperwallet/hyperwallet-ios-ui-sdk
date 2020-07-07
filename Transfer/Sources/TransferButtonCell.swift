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

    private(set) lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "createTransferNextLabel"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let heightConstraint = NSLayoutConstraint(item: button,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 52)
        button.addConstraint(heightConstraint)

        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { (view) in
            if type(of: view).description() == "_UITableViewCellSeparatorView" {
                view.isHidden = true
            }
        }
    }

    private func setupCell() {
        contentView.addSubview(button)

        let margins = contentView.layoutMarginsGuide
        let constraints = [
            button.safeAreaLeadingAnchor.constraint(equalTo: margins.leadingAnchor),
            button.safeAreaTrailingAnchor.constraint(equalTo: margins.trailingAnchor),
            button.safeAreaCenterXAnchor.constraint(equalTo: margins.centerXAnchor),
            button.safeAreaCenterYAnchor.constraint(equalTo: margins.centerYAnchor),
            button.safeAreaTopAnchor.constraint(equalTo: margins.topAnchor),
            button.safeAreaBottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ]
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        NSLayoutConstraint.activate(constraints)
    }

    /// This is to configure the next button in create transfer page
    func configure(title: String) {
        button.setTitle(title, for: .normal)
        button.accessibilityLabel = title
    }

    /// This is to configure the confirmation button in schedule transfer page
    func configure(title: String, action: UIGestureRecognizer) {
        button.setTitle(title, for: .normal)
        button.accessibilityLabel = title
        button.accessibilityIdentifier = "scheduleTransferLabel"
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(action)
    }
}

extension TransferButtonCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var buttonTitleLabelFont: UIFont! {
        get { return button.titleLabel?.font }
        set { button.titleLabel?.font = newValue }
    }

    @objc dynamic var buttonTitleLabelColor: UIColor! {
        get { return button.titleLabel?.textColor }
        set { button.titleLabel?.textColor = newValue }
    }

    @objc dynamic var buttonBackgroundColor: UIColor! {
        get { return button.backgroundColor }
        set { button.backgroundColor = newValue }
    }
}
