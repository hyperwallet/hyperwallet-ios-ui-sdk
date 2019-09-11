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

/// Protocol to start/navigate Hyperwallet UI SDK flow
public protocol HyperwalletCoordinator: NSObject {
    /// Apply Theme
    func applyTheme()
    /// Get the current Controller class for the Coordinator
    func getController() -> UITableViewController
    /// Navigate to the flow
    func navigate()
    /// Navigate to next page from the current flow
    func navigateToNextPage(initializationData: [InitializationDataField: Any]?)
    /// Navigate back from the next page to either current flow or parent flow.
    func navigateBackFromNextPage(with response: Any)
    /// Start the coordinator
    func start(initializationData: [InitializationDataField: Any]?, parentController: UIViewController)
}
