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

extension UINavigationController {
    /// Pop number of ViewControllers
    public func popToViewController(_ number: Int) {
        let viewControllers: [UIViewController] = self.viewControllers
        guard viewControllers.count < number else {
            self.popToViewController(viewControllers[viewControllers.count - number], animated: true)
            return
        }
    }

    /// Pop currently and the preview view controller 
    public func skipPreviousViewControllerIfPresent(skip: UIViewController.Type? = nil) {
        var viewControllerToSkipPresent = false
        let viewControllers: [UIViewController] = self.viewControllers
        if let skip = skip, viewControllers.count >= 3 {
            if viewControllers[viewControllers.count - 2].isKind(of: skip) {
                viewControllerToSkipPresent.toggle()
                self.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                return
            }
        }
        if !viewControllerToSkipPresent {
            self.popViewController(animated: true)
            return
        }
    }
}
