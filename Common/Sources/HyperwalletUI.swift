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
import UserRepository
#endif
import HyperwalletSDK

/// Class responsible for initializing the Hyperwallet UI SDK. It contains methods to interact with the controllers
/// used to interact with the Hyperwallet platform
public final class HyperwalletUI {
    private static var instance: HyperwalletUI?

    public enum HyperwalletFlow: String {
        case selectTransferMethodType
        case addTransferMethod
        case listTransferMethods
        case listReceipts
        case createTransfer
    }

    public static var flows = [HyperwalletFlow: NSObject.Type]()

    /// Returns the previously initialized instance of the Hyperwallet UI SDK interface object
    public static var shared: HyperwalletUI {
        guard let instance = instance else {
            fatalError("Call HyperwalletUI.setup(_:) before accessing HyperwalletUI.shared")
        }
        return instance
    }

    /// Creates a new instance of the Hyperwallet UI SDK interface object. If a previously created instance exists,
    /// it will be replaced.
    ///
    /// - Parameter provider: a provider of Hyperwallet authentication tokens.
    public class func setup(_ provider: HyperwalletAuthenticationTokenProvider) {
        instance = HyperwalletUI(provider)
    }

    private init(_ provider: HyperwalletAuthenticationTokenProvider) {
        Hyperwallet.setup(provider)
        UserRepositoryFactory.shared.userRepository().getUser { _ in }
    }

    public func isFlowInitialized(flow: HyperwalletFlow) -> Bool {
        return HyperwalletUI.flows[flow] != nil
    }

    public func navigateToFlow(flow: HyperwalletFlow,
                               fromViewController: UIViewController,
                               initializationData: [InitializationDataField: Any]? = nil) {
        if let toViewCoordinator = HyperwalletUI.flows[flow],
            let initializedCoordinator = toViewCoordinator.init() as? HyperwalletCoordinator {
            initializedCoordinator.start(initializationData: initializationData, parentController: fromViewController)
            initializedCoordinator.navigate()
        }
    }

    private func applyTheme() {
        for (_, coordinator) in HyperwalletUI.flows {
            if let initializedCoordinator = coordinator.init() as? HyperwalletCoordinator {
                initializedCoordinator.applyTheme()
            }
        }
    }

    private func addFlows() {
        if let className = NSClassFromString("HyperwalletUISDK.SelectTransferMethodTypeCoordinator") as? NSObject.Type
            ?? NSClassFromString("TransferMethod.SelectTransferMethodTypeCoordinator") as? NSObject.Type {
            HyperwalletUI.flows[.selectTransferMethodType] = className
        }

        if let className = NSClassFromString("HyperwalletUISDK.AddTransferMethodCoordinator") as? NSObject.Type
            ?? NSClassFromString("TransferMethod.AddTransferMethodCoordinator") as? NSObject.Type {
            HyperwalletUI.flows[.addTransferMethod] = className
        }

        if let className = NSClassFromString("HyperwalletUISDK.ListTransferMethodsCoordinator") as? NSObject.Type
            ?? NSClassFromString("TransferMethod.ListTransferMethodsCoordinator") as? NSObject.Type {
            HyperwalletUI.flows[.listTransferMethods] = className
        }

        if let className = NSClassFromString("HyperwalletUISDK.ListReceiptCoordinator") as? NSObject.Type
            ?? NSClassFromString("TransferMethod.ListReceiptCoordinator") as? NSObject.Type {
            HyperwalletUI.flows[.listReceipts] = className
        }

        if let className = NSClassFromString("HyperwalletUISDK.CreateTransferCoordinator") as? NSObject.Type
            ?? NSClassFromString("Receipt.CreateTransferCoordinator") as? NSObject.Type {
            HyperwalletUI.flows[.createTransfer] = className
        }
    }
}
