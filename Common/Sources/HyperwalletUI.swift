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
@objcMembers
public final class HyperwalletUI: NSObject {
    private static var instance: HyperwalletUI?

    /// Returns the previously initialized instance of the Hyperwallet UI SDK interface object
    public static var shared: HyperwalletUI {
        guard let instance = instance else {
            fatalError("Call HyperwalletUI.setup(_:) before accessing HyperwalletUI.shared")
        }
        return instance
    }

    /// Clears Hyperwallet, UserRepositoryFactory and HyperwalletInsights instances.
    public static func clearInstance() {
        Hyperwallet.clearInstance()
        UserRepositoryFactory.clearInstance()
        HyperwalletInsights.clearInstance()
        instance = nil
    }

    /// Creates a new instance of the Hyperwallet UI SDK interface object. If a previously created instance exists,
    /// it will be replaced.
    ///
    /// - Parameter provider: a provider of Hyperwallet authentication tokens.
    public class func setup(_ provider: HyperwalletAuthenticationTokenProvider) {
        if instance == nil {
            instance = HyperwalletUI(provider)
        }
    }

    private init(_ provider: HyperwalletAuthenticationTokenProvider) {
        Hyperwallet.setup(provider)
        HyperwalletInsights.setup()
        UserRepositoryFactory.shared.userRepository().getUser { _ in }
    }
}
