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

/// Represents the state of processing
public enum ProcessingState: CustomStringConvertible {
    /// Processing in progress
    case processing
    /// Processing completed
    case complete

    public var description: String {
        switch self {
        case .processing:
            return "processing_view_label".localized()

        case .complete:
            return "complete_view_label".localized()
        }
    }
}

/// An object that displays a rectangle view to show the state of processing
public final class ProcessingView: UIView {
    @IBOutlet private weak var stateLabel: UILabel!
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var contentView: UIView!

    private let propertyOpacity = "opacity"

    private var loadedFromCode: Bool = false

    private var state: ProcessingState! {
        didSet {
            updateView(for: state)
        }
    }

    override private init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        defaultInit()
        loadedFromCode = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultInit()
    }

    /// Returns an object of the ProcessingView type
    /// - Parameter view: The parent view for a ProcessingView object
    public convenience init(showInView view: UIView) {
        var parentView = view
        if let superView = (view as? UITableView)?.superview {
            parentView = superView
        }
        self.init(frame: parentView.frame)
        parentView.addSubview(self)
        self.layer.add(fadeInAnimation(), forKey: nil)
    }

    /// Returns an object of the ProcessingView type
    public convenience init() {
        guard let view = UIApplication.shared.keyWindow!.rootViewController?.view
            else {
                fatalError("Unexpected error: can't get access to the rootViewController")
        }
        self.init(showInView: view)
    }

    private func defaultInit() {
        HyperwalletBundle.bundle.loadNibNamed("ProcessingView", owner: self, options: nil)
        populateByAccessibilityIds()
        activityIndicator.hidesWhenStopped = true
        contentView.layer.cornerRadius = CGFloat(8.0)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        state = .processing
    }

    override public func didMoveToSuperview() {
        if self.superview == nil {
            return
        }
        contentView.widthAnchor.constraint(equalToConstant: CGFloat(136.0)).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: CGFloat(136.0)).isActive = true

        NSLayoutConstraint.activate([
            getConstraint(item: contentView, toItem: self, attribute: .centerX),
            getConstraint(item: contentView, toItem: self, attribute: .centerY)
        ])

        if loadedFromCode {
            NSLayoutConstraint.activate([
                getConstraintEqualToContainer(attribute: .leading),
                getConstraintEqualToContainer(attribute: .top),
                getConstraintEqualToContainer(attribute: .trailing),
                getConstraintEqualToContainer(attribute: .bottom)
            ])
        }
    }

    private func updateView(for state: ProcessingState?) {
        let isProcessing = state == .processing
        checkImageView.isHidden = isProcessing
        if isProcessing {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        stateLabel.text = state?.description
    }

    /// Hides and removes a ProcessingView from the parent view
    /// - Parameter state: Processing state
    public func hide(with state: ProcessingState? = nil) {
        CATransaction.begin()
        if let state = state {
            self.state = state
        }
        CATransaction.setCompletionBlock { [weak self] in
            self?.removeFromSuperview()
        }
        self.layer.add(fadeOutAnimation(), forKey: nil)
        CATransaction.commit()
    }

    // MARK: Theme manager's proxy properties
    @objc dynamic var viewBackgroundColor: UIColor! {
        get { return self.contentView.backgroundColor }
        set { self.contentView.backgroundColor = newValue }
    }

    @objc dynamic var stateLabelColor: UIColor! {
        get { return self.stateLabel.textColor }
        set { self.stateLabel.textColor = newValue }
    }
}

// MARK: Animation
extension ProcessingView {
    private func fadeInAnimation() -> CABasicAnimation {
        let result = CABasicAnimation(keyPath: propertyOpacity)
        result.fromValue = 0.0
        result.toValue = 1.0
        result.duration = 0.2
        result.fillMode = .backwards
        result.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return result
    }

    private func fadeOutAnimation() -> CABasicAnimation {
        let result = CABasicAnimation(keyPath: propertyOpacity)
        result.fromValue = 1.0
        result.toValue = 0.0
        result.duration = 0.8
        result.fillMode = .forwards
        result.timingFunction = CAMediaTimingFunction(name: .easeIn)
        result.isRemovedOnCompletion = false
        return result
    }
}

// MARK: Constraints
extension ProcessingView {
    private func getConstraint(item: UIView, toItem: UIView, attribute: NSLayoutConstraint.Attribute)
        -> NSLayoutConstraint {
            return NSLayoutConstraint(item: item,
                                      attribute: attribute,
                                      relatedBy: .equal,
                                      toItem: toItem,
                                      attribute: attribute,
                                      multiplier: 1.0,
                                      constant: 0.0
            )
    }

    private func getConstraintEqualToContainer(attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return getConstraint(item: self, toItem: self.superview!, attribute: attribute)
    }
}

// MARK: Accessibility Identifiers
extension ProcessingView {
    private func populateByAccessibilityIds() {
        self.accessibilityIdentifier = "processingView"
        contentView.accessibilityIdentifier = "contentView"
        checkImageView.accessibilityIdentifier = "checkImageView"
        activityIndicator.accessibilityIdentifier = "activityIndicator"
        stateLabel.accessibilityIdentifier = "stateLabel"
    }
}
