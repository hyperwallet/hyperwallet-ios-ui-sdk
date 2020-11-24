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

/// The UIViewController extension
public extension UIViewController {
    /// To set the display mode for large titles
    ///
    /// - Parameters:
    ///   - mode: UINavigationItem.LargeTitleDisplayMode
    ///   - title: title displayed
    func titleDisplayMode(_ mode: UINavigationItem.LargeTitleDisplayMode, for title: String?) {
        let currentNavigationItem: UINavigationItem = self.tabBarController?.navigationItem ?? self.navigationItem
        currentNavigationItem.title = title
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            currentNavigationItem.largeTitleDisplayMode = mode
            if #available(iOS 13.0, *) {
                ThemeManager.applyToUINavigationBar()
            } else {
              self.navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: Theme.NavigationBar.largeTitleColor,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0)
              ]
            }
        }
    }

    /// Hide keyboard when tapped around on the screen
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIViewController: HyperwalletFlowDelegate {
    /// Protocol method
    @objc
    open func didFlowComplete(with response: Any) {
    }
    struct Holder {
        static var flowDelegate = [ObjectIdentifier: HyperwalletFlowDelegate]()
        static var coordinator =  [ObjectIdentifier: HyperwalletCoordinator]()
        static var initializationData = [ObjectIdentifier: [InitializationDataField: Any]]()
    }
    /// The reference to call didFlowComplete
    public weak var flowDelegate: HyperwalletFlowDelegate? {
        get {
            return Holder.flowDelegate[ObjectIdentifier(self)]
        }
        set(newValue) {
            Holder.flowDelegate[ObjectIdentifier(self)] = newValue
        }
    }
    /// The reference to start/navigate Hyperwallet UI SDK flow
    public var coordinator: HyperwalletCoordinator? {
        get {
            return Holder.coordinator[ObjectIdentifier(self)]
        }
        set(newValue) {
            Holder.coordinator[ObjectIdentifier(self)] = newValue
        }
    }
    /// Data required to initialize a flow (render UI screen)
    public var initializationData: [InitializationDataField: Any]? {
        get {
            return Holder.initializationData[ObjectIdentifier(self)]
        }
        set(newValue) {
            Holder.initializationData[ObjectIdentifier(self)] = newValue
        }
    }

    /// Removes the current coordinator while moving back
    public func removeCoordinator() {
        Holder.coordinator.removeValue(forKey: ObjectIdentifier(self))
    }

    /// Removes all coordinators
    public func removeAllCoordinators() {
        Holder.coordinator.removeAll()
    }
}

extension UIViewController: UIAdaptivePresentationControllerDelegate {
    /// Removes the current coordinator after dismissing the Controller
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        removeCoordinator()
    }
}
