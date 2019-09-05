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
    /// To always prefer LargeTitles
    func largeTitle() {
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.largeTitleDisplayMode = .always
        }
    }

    /// To set the display mode for large titles
    ///
    /// - Parameter mode: UINavigationItem.LargeTitleDisplayMode
    func titleDisplayMode(_ mode: UINavigationItem.LargeTitleDisplayMode) {
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = mode
        }
    }

    /// Set bavkground color for the view
    func setViewBackgroundColor() {
        view.backgroundColor = Theme.ViewController.backgroundColor
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
    @objc
    open func didFlowComplete(with response: Any) {
    }
    struct Holder {
        static var flowDelegate = [ObjectIdentifier: HyperwalletFlowDelegate]()
        static var coordinator =  [ObjectIdentifier: HyperwalletCoordinator]()
        static var initializationData = [ObjectIdentifier: [String: Any]]()
    }

    public weak var flowDelegate: HyperwalletFlowDelegate? {
        get {
            return Holder.flowDelegate[ObjectIdentifier(self)]
        }
        set(newValue) {
            Holder.flowDelegate[ObjectIdentifier(self)] = newValue
        }
    }
    public var coordinator: HyperwalletCoordinator? {
        get {
            return Holder.coordinator[ObjectIdentifier(self)]
        }
        set(newValue) {
            Holder.coordinator[ObjectIdentifier(self)] = newValue
        }
    }
    public var initializationData: [String: Any]? {
        get {
            return Holder.initializationData[ObjectIdentifier(self)]
        }
        set(newValue) {
            Holder.initializationData[ObjectIdentifier(self)] = newValue
        }
    }
}
