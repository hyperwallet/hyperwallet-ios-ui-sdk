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

/// The UIView extension
public extension UIView {
    /// Top Anchor
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }

    /// CenterY Anchor
    var safeAreaCenterYAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.centerYAnchor
        } else {
            return self.centerYAnchor
        }
    }

    /// CenterX Anchor
    var safeAreaCenterXAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.centerXAnchor
        } else {
            return self.centerXAnchor
        }
    }

    /// Bottom Anchor
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    /// Leading Anchor
    var safeAreaLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        } else {
            return self.leadingAnchor
        }
    }

    /// Trailing Anchor
    var safeAreaTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        } else {
            return self.trailingAnchor
        }
    }

    /// Setups the empty list with message
    ///
    /// - Parameter text: the string description
    /// - Returns: the UILabel instance
    func setUpEmptyListLabel(text: String) -> UILabel {
        let emptyListLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 268, height: 20.5))
        emptyListLabel.text = text
        emptyListLabel.numberOfLines = 0
        emptyListLabel.lineBreakMode = .byWordWrapping
        emptyListLabel.textAlignment = .center
        emptyListLabel.accessibilityIdentifier = "EmptyListLabelAccessibilityIdentifier"

        self.addSubview(emptyListLabel)

        emptyListLabel.translatesAutoresizingMaskIntoConstraints = false

        let labelCenterXConstraint = NSLayoutConstraint(item: emptyListLabel,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: .centerX,
                                                        multiplier: 1.0,
                                                        constant: 0.0)
        let labelCenterYConstraint = NSLayoutConstraint(item: emptyListLabel,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: .centerY,
                                                        multiplier: 1.0,
                                                        constant: 0.0)

        let labelWidthConstraint = NSLayoutConstraint(item: emptyListLabel,
                                                      attribute: .width,
                                                      relatedBy: .equal,
                                                      toItem: nil,
                                                      attribute: .notAnAttribute,
                                                      multiplier: 1,
                                                      constant: 268)
        NSLayoutConstraint.activate([labelCenterXConstraint, labelCenterYConstraint, labelWidthConstraint])
        return emptyListLabel
    }

    /// Setups the empty list with button
    ///
    /// - Parameters:
    ///   - text: the button text
    ///   - firstItem: the UIVIew to anchor the button
    /// - Returns: the UIButton instance
    func setUpEmptyListButton(text: String, firstItem: UIView) -> UIButton {
        let emptyListButton = UIButton(type: .system)
        emptyListButton.setTitle(text, for: .normal)
        emptyListButton.titleLabel?.font = Theme.Button.font
        emptyListButton.setTitleColor(Theme.Button.color, for: UIControl.State.normal)
        emptyListButton.backgroundColor = Theme.Button.backgroundColor
        emptyListButton.accessibilityIdentifier = "emptyListButton"

        let heightConstraint = NSLayoutConstraint(item: emptyListButton,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: 52)

        let widthConstraint = NSLayoutConstraint(item: emptyListButton,
                                                 attribute: .width,
                                                 relatedBy: .lessThanOrEqual,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: 382)

        emptyListButton.addConstraint(heightConstraint)
        emptyListButton.addConstraint(widthConstraint)

        self.addSubview(emptyListButton)
        emptyListButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonCenterXConstraint = NSLayoutConstraint(item: emptyListButton,
                                                         attribute: .centerX,
                                                         relatedBy: .equal,
                                                         toItem: self,
                                                         attribute: .centerX,
                                                         multiplier: 1.0,
                                                         constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: firstItem,
                                                    attribute: .bottom,
                                                    relatedBy: .equal,
                                                    toItem: emptyListButton,
                                                    attribute: .top,
                                                    multiplier: 1,
                                                    constant: -8)
        NSLayoutConstraint.activate([buttonCenterXConstraint, verticalConstraint])
        return emptyListButton
    }

    /// Check if current view is `UITableViewCellSeparatorView`
    func isSeparatorView() -> Bool {
        return type(of: self).description() == "_UITableViewCellSeparatorView"
    }

    /// Adjust segment titles width
    /// - Parameter view: Segmented Controller
    class func adjustWidthOfSegmentTitles(view: UIView) {
        let subviews = view.subviews
        for subview in subviews {
            if subview is UILabel {
                let label: UILabel? = (subview as? UILabel)
                label?.adjustsFontSizeToFitWidth = true
                label?.minimumScaleFactor = 0.1
            } else {
                adjustWidthOfSegmentTitles(view: subview)
            }
        }
    }
}
