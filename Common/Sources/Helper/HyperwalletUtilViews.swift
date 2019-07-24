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

/// Displays the common UI Views - Alerts and Spinners
public struct HyperwalletUtilViews {
    // MARK: - SelectTransferMethodView

    /// show an alert dialog
    ///
    /// - Parameters:
    ///   - viewController: current view
    ///   - title: title shown in the dialog
    ///   - message: description shown in the dialog
    public static func showAlert(_ viewController: UIViewController, title: String?, message: String?) {
        HyperwalletUtilViews.showAlert(viewController, title: title, message: message, actions: UIAlertAction.close())
    }

    /// Display the alert view with custom list of options
    ///
    /// - parameters: viewController - The view controller will present the Alert View
    /// - parameters: title - The title will be displayed in top of Alert View
    /// - parameters: message - The message will be displayed in the body of Alert View
    /// - parameters: style - The style of the alert controller.
    /// - parameters: actions - The list of option `UIAlertAction` the use can choose.
    public static func showAlert(
        _ viewController: UIViewController,
        title: String? = nil,
        message: String?,
        style: UIAlertController.Style = .alert,
        actions: UIAlertAction...) {
        let titleLocalized = title?.localized()
        let messageLocalized = message?.localized()

        let alert = UIAlertController(title: titleLocalized, message: messageLocalized, preferredStyle: style)
        alert.accessibilityLabel = title
        actions.forEach { action in
            alert.addAction(action)
        }

        viewController.present(alert, animated: true, completion: nil)
    }

    /// show an alert dialog with retry button
    ///
    /// - Parameters:
    ///   - viewController: current view
    ///   - title: title shown in the dialog
    ///   - message: description shown in the dialog
    ///   - retry: an action needs to be retried
    public static func showAlertWithRetry(
        _ viewController: UIViewController,
        title: String?,
        message: String?,
        _ retry: @escaping (UIAlertAction) -> Void) {
        HyperwalletUtilViews.showAlert(viewController,
                                       title: title,
                                       message: message,
                                       actions: UIAlertAction.cancel(viewController),
                                       UIAlertAction.retry(retry))
    }

    /// Displays the Activity Indicator embedded on view
    ///
    /// - parameters: onView - The view where the `SpinnerView` will be embedded
    /// - returns: SpinnerView
    ///
    /// Example: the `self` is ViewController
    ///    let spinnerView = HyperwalletUtilViews.showSpinner(self.view)
    ///
    ///    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // represent a callback
    ///        HyperwalletUtilViews.removeSpinner(spinnerView)
    ///    }
    public static func showSpinner(view: UIView) -> SpinnerView {
        return SpinnerView(showInView: view)
    }

    /// Remove the `SpinnerView` with animation
    public static func removeSpinner(_ spinnerView: SpinnerView) {
       spinnerView.hide()
    }

    /// Displays the Processing view in a modal view for indicating the UI is processing the data
    ///
    /// - returns: ProcessingView
    ///
    /// Example:
    ///    To show ProcessingView:
    ///    let processingView = HyperwalletUtilViews.showProcessing()
    ///
    ///    To hide with Complete state:
    ///    processingView.hide(with: .complete)
    ///
    ///     To dismiss ProcessView with the same state:
    ///     processingView.hide()
    public static func showProcessing() -> ProcessingView {
        return ProcessingView()
    }
}

// MARK: - SpinnerView

/// Represents Spinner view to be embedded on a view
public final class SpinnerView: UIView {
    private let propertyOpacity = "opacity"

    let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = true
        activity.accessibilityIdentifier = "activityIndicator"
        activity.accessibilityValue = "Loading".localized()
        activity.startAnimating()
        return activity
    }()

    public convenience init(showInView view: UIView) {
        self.init(frame: view.frame)
        setupLayout()
        view.addSubview(self)
        view.addConstraintsFillEntireView(view: self)
        view.bringSubviewToFront(self)
        layer.add(fadeInAnimation(), forKey: nil)
    }

    /// Configures the layout
    func setupLayout() {
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    /// Hides and remove the SpinnerView from the superView
    func hide() {
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.removeFromSuperview()
        }
        self.layer.add(fadeOutAnimation(), forKey: nil)
        CATransaction.commit()
    }

    private func fadeInAnimation() -> CABasicAnimation {
        let result = CABasicAnimation(keyPath: propertyOpacity)
        result.fromValue = 0.0
        result.toValue = 1.0
        result.duration = 0.1
        result.fillMode = .backwards
        result.timingFunction = CAMediaTimingFunction(name: .easeOut)
        return result
    }

    private func fadeOutAnimation() -> CABasicAnimation {
        let result = CABasicAnimation(keyPath: propertyOpacity)
        result.fromValue = 1.0
        result.toValue = 0.0
        result.duration = 0.3
        result.fillMode = .forwards
        result.timingFunction = CAMediaTimingFunction(name: .easeIn)
        result.isRemovedOnCompletion = false
        return result
    }

    // MARK: Theme manager's proxy properties
    /// Defines the view backgrounnd color
    @objc dynamic var viewBackgroundColor: UIColor! {
        get { return self.backgroundColor }
        set { self.backgroundColor = newValue }
    }

    /// Defines the UIActivityIndicatorView style
    @objc dynamic var activityIndicatorStyle: UIActivityIndicatorView.Style {
        get { return self.activityIndicator.style }
        set { self.activityIndicator.style = newValue }
    }

    /// Defines the UIActivityIndicatorView color
    @objc dynamic var activityIndicatorColor: UIColor! {
        get { return activityIndicator.color }
        set { activityIndicator.color = newValue }
    }

    /// Defines the UIActivityIndicatorView background color
    @objc dynamic var activityIndicatorBackgroundColor: UIColor! {
        get { return activityIndicator.backgroundColor }
        set { activityIndicator.backgroundColor = newValue }
    }
}
