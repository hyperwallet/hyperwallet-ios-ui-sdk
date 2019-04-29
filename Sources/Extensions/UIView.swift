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

extension UIView {
    /// Top Anchor
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
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

    /// Left Anchor
    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        } else {
            return self.leftAnchor
        }
    }

    /// Right Anchor
    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        } else {
            return self.rightAnchor
        }
    }

    /// Height Anchor
    var safeAreaHeightAnchor: NSLayoutDimension {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.heightAnchor
        } else {
            return self.heightAnchor
        }
    }

    /// Width Anchor
    var safeAreaWidthAnchor: NSLayoutDimension {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.widthAnchor
        } else {
            return self.widthAnchor
        }
    }

    /// Defines constraint for Button to the bottom, leading, trailing and height
    public func buttonConstraints(margin: UIView, bottom: UIView) {
        // Layout for iPhone X model
        if #available(iOS 11.0, *),
            let topPadding = UIApplication.shared.keyWindow?.safeAreaInsets.top, topPadding > 24 {
            NSLayoutConstraint.activate([
                self.bottomAnchor.constraint(equalTo: bottom.bottomAnchor),
                self.leadingAnchor.constraint(equalTo: margin.layoutMarginsGuide.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: margin.layoutMarginsGuide.trailingAnchor)
            ])
            self.layer.masksToBounds = true
            self.layer.cornerRadius = 6
        } else {
            NSLayoutConstraint.activate([
                self.bottomAnchor.constraint(equalTo: bottom.bottomAnchor),
                self.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: margin.trailingAnchor)
            ])
        }
        self.setConstraint(value: 55, attribute: .height)
    }

    /// Add constraint based in Visual Format
    ///
    /// - parameter: format - The value should follow the visual format language
    /// - views
    public func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDict = [String: UIView]()

        for (index, view) in views.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDict["v\(index)"] = view
        }

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format,
                                                      options: NSLayoutConstraint.FormatOptions(),
                                                      metrics: nil,
                                                      views: viewsDict))
    }

    /// Fill entire view to the super view
    public func addConstraintsFillEntireView(view: UIView) {
        addConstraintsWithFormat(format: "H:|[v0]|", views: view)
        addConstraintsWithFormat(format: "V:|[v0]|", views: view)
    }

    /// Defines fixed constraint validation to the attribute
    public func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute) {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1 ,
                                            constant: value)
        addConstraint(constraint)
    }

    /// Helper method to add safe area margin
    public func addSubview(childView: UIView) {
        addSubview(childView)
        /// Below line tells the view to not use AutoResizing
        childView.translatesAutoresizingMaskIntoConstraints = false

        /// Create the leading and trailing margin constraints
        let margins = layoutMarginsGuide
        NSLayoutConstraint.activate([
            childView.safeAreaLeadingAnchor.constraint(equalTo: margins.leadingAnchor),
            childView.safeAreaTrailingAnchor.constraint(equalTo: margins.trailingAnchor),
            childView.safeAreaTopAnchor.constraint(equalTo: margins.topAnchor),
            childView.safeAreaBottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
}
