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

import HyperwalletSDK

/// Class contains methods to get an instance of transfer method repository
public final class TransferMethodRepositoryFactory {
    private static var instance: TransferMethodRepositoryFactory?
    private let remoteTransferMethodConfigurationRepository: TransferMethodConfigurationRepository
    private let remoteTransferMethodRepository: TransferMethodRepository
    private let remotePrepaidCardRepository: PrepaidCardRepository

    /// Returns the previously initialized instance of the RepositoryFactory object
    public static var shared: TransferMethodRepositoryFactory {
        guard let instance = instance else {
            self.instance = TransferMethodRepositoryFactory()
            return self.instance!
        }
        return instance
    }

    /// Clears the TransferMethodRepositoryFactory singleton instance.
    public static func clearInstance() {
        instance = nil
    }

    private init() {
        remoteTransferMethodConfigurationRepository = RemoteTransferMethodConfigurationRepository()
        remoteTransferMethodRepository = RemoteTransferMethodRepository()
        remotePrepaidCardRepository = RemotePrepaidCardRepository()
    }

    /// Gets the `TransferMethodConfigurationRepository` instance.
    ///
    /// - Returns: The TransferMethodConfigurationRepository
    public func transferMethodConfigurationRepository() -> TransferMethodConfigurationRepository {
        return remoteTransferMethodConfigurationRepository
    }

    /// Gets the `TransferMethodRepository` instance.
    ///
    /// - Returns: The TransferMethodRepository
    public func transferMethodRepository() -> TransferMethodRepository {
        return remoteTransferMethodRepository
    }

    /// Gets the `PrepaidCardRepository` instance.
    ///
    /// - Returns: The PrepaidCardRepository
    public func prepaidCardRepository() -> PrepaidCardRepository {
        return remotePrepaidCardRepository
    }
}
