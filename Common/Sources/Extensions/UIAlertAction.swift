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

/// The UIAlertAction extension
public extension UIAlertAction {
    /// The default cancel button label
    static let cancel = "cancel_button_label".localized()
    /// The default retry button label
    static let retry = "try_again_button_label".localized()
    /// The default close button label
    static let close = "doneButtonLabel".localized()
    /// The default remove button label
    static let remove = "remove_button_label".localized()

    /// Initialize a cancel alert action
    ///
    /// - Parameter handler: if provided, will be invoked after the cancel button is clicked
    /// - Returns: a cancel alert action
    static func cancel(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: UIAlertAction.cancel, style: .cancel, handler: handler)
    }

    /// Initialize a cancel alert action with pop back functionality
    ///
    /// - Parameter viewController: a view needs to show the alert dialog
    /// - Returns: a cancel alert action with a pop back handler
    static func cancel(_ viewController: UIViewController) -> UIAlertAction {
        let handler = { (alertAction: UIAlertAction) -> Void in
            viewController.navigationController?.popViewController(animated: true) }
        return cancel(handler)
    }

    /// Initialize a close alert action
    ///
    /// - Parameter handler: if provided, will be invoked after the close button is clicked
    /// - Returns: a close alert action
    static func close(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: UIAlertAction.close, style: .default, handler: handler)
    }

    /// Initialize a close alert action with pop back functionality
    ///
    /// - Parameter viewController: a view needs to show the alert dialog
    /// - Returns: a close alert action with a pop back handler
    static func close(_ viewController: UIViewController) -> UIAlertAction {
        let handler = { (alertAction: UIAlertAction) -> Void in
            viewController.navigationController?.popViewController(animated: true) }
        return close(handler)
    }

    /// Initialize a remove alert action
    ///
    /// - Parameters:
    ///   - handler: will be invoked after the remove button is clicked
    ///   - title: a string value of the alert action
    /// - Returns: a remove alert action
    static func remove(_ handler: @escaping (UIAlertAction) -> Void,
                       _ title: String = UIAlertAction.remove) -> UIAlertAction {
        return UIAlertAction(title: title, style: .destructive, handler: handler)
    }

    /// Initialize a retry alert action
    ///
    /// - Parameter handler: if provided, will be invoked after the retry button is clicked
    /// - Returns: a confirm retry action
    static func retry(_ handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: UIAlertAction.retry, style: .default, handler: handler)
    }

    /// Add an icon image on this alert action
    ///
    /// - Parameters:
    ///   - imageName: The image name
    /// - Returns: An alert action with an icon
    func addIcon(imageName: String) -> UIAlertAction {
        let iconImage = UIImage(named: imageName,
                                in: HyperwalletBundle.bundle,
                                compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        self.setValue(iconImage, forKey: "image")
        return self
    }
}
