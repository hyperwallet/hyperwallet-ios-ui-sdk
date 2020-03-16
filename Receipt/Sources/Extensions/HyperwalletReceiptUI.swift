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
import ReceiptRepository
#endif

/// The HyperwalletUI extension
public extension HyperwalletUI {
    /// Clearing ReceiptRepositoryFactory instance.
    static func receiptUIClearInstance() {
        ReceiptRepositoryFactory.clearInstance()
    }

    /// Lists the user's transactions.
    ///
    ///
    /// - Returns: An instance of `ListReceiptCoordinator`
    func listUserReceiptCoordinator(parentController: UIViewController) -> ListReceiptCoordinator {
        let coordinator = ListReceiptCoordinator()
        coordinator.start(parentController: parentController)
        return coordinator
    }

    /// Lists the user's prepaid card transactions.
    ///
    /// - Parameter prepaidCardToken: prepaid card token for which transactions are requested
    /// - Returns: An instance of `ListReceiptCoordinator`
    func listPrepaidCardReceiptCoordinator(parentController: UIViewController, prepaidCardToken: String)
        -> ListReceiptCoordinator {
            let coordinator = ListReceiptCoordinator()
            coordinator.start(initializationData: [InitializationDataField.prepaidCardToken: prepaidCardToken],
                              parentController: parentController)
            return coordinator
    }
}
