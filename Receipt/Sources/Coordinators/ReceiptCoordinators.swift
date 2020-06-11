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

/// Coordinator class for ListReceipt
public class ListReceiptCoordinator: NSObject, HyperwalletCoordinator {
    private let controller: ListReceiptController
    private var parentController: UIViewController?

    override init() {
        controller = ListReceiptController()
        super.init()
        self.applyTheme()
    }
    public func applyTheme() {
        ThemeManager.applyReceiptTheme()
    }

    public func getController() -> UITableViewController {
        return controller
    }

    @objc
    public func navigate() {
        parentController?.show(controller, sender: parentController)
    }

    public func navigateToNextPage(initializationData: [InitializationDataField: Any]?) {
        let childController = ReceiptDetailController()
        childController.flowDelegate = controller
        childController.initializationData = initializationData
        controller.show(childController, sender: controller)
    }

    public func navigateBackFromNextPage(with response: Any) {
        controller.navigationController?.popViewController(animated: false)
    }

    public func start(initializationData: [InitializationDataField: Any]? = nil, parentController: UIViewController) {
        controller.coordinator = self
        controller.initializationData = initializationData
        controller.flowDelegate = parentController
        self.parentController = parentController
    }
}
