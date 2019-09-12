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
import UIKit

public class ListReceiptCoordinator: NSObject, HyperwalletCoordinator {
    private let controller: ListReceiptController
    private var parentController: UIViewController?

    override init() {
        controller = ListReceiptController()
    }
    public func applyTheme() {
        ThemeManager.applyReceiptTheme()
    }

    public func getController() -> UITableViewController {
        return controller
    }

    public func navigate() {
        controller.flowDelegate = parentController
        parentController?.show(controller, sender: parentController)
    }

    public func navigateToNextPage(initializationData: [String: Any]?) {
        let childController = ReceiptDetailController()
        childController.coordinator = self
        childController.flowDelegate = controller
        childController.initializationData = initializationData
        controller.show(childController, sender: controller)
    }

    public func navigateBackFromNextPage(with response: Any) {
        if let parentController = parentController {
            if let navigationController = controller.navigationController {
                navigationController.popToViewController(parentController, animated: true)
            } else {
                controller.dismiss(animated: true, completion: nil)
            }
        }
        controller.flowDelegate?.didFlowComplete(with: response)
    }

    public func start(initializationData: [String: Any]? = nil, parentController: UIViewController) {
        controller.coordinator = self
        controller.initializationData = initializationData
        self.parentController = parentController
    }
}
