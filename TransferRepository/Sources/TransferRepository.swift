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

/// Transfer repository protocol
public protocol TransferRepository {
    /// Create a transfer
    ///
    /// - Parameters:
    ///   - transfer: the `HyperwalletTransfer` being created
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func createTransfer(_ transfer: Transfer.HyperwalletTransfer,
                        _ completion: @escaping (Result<Transfer.HyperwalletTransfer?, HyperwalletErrorType>) -> Void)

    /// Schedule a transfer
    ///
    /// - Parameters:
    ///   - transfer: the transfer that was previously created
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func scheduleTransfer(_ transfer: Transfer.HyperwalletTransfer,
                          _ completion: @escaping (Result<HyperwalletStatusTransition?, HyperwalletErrorType>) -> Void)
}

final class RemoteTransferRepository: TransferRepository {
    /// Create a transfer
    ///
    /// - Parameters:
    ///   - transfer: the transfer will be created
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    public func createTransfer(_ transfer: Transfer.HyperwalletTransfer,
                               _ completion: @escaping (Result<Transfer.HyperwalletTransfer?, HyperwalletErrorType>) -> Void) {
        Hyperwallet.shared.createTransfer(transfer: transfer,
                                          completion: TransferRepositoryCompletionHelper.performHandler(completion))
    }

    /// Schedule a transfer
    ///
    /// - Parameters:
    ///   - transfer: the transfer that was previously created
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    public func scheduleTransfer(_ transfer: Transfer.HyperwalletTransfer,
                                 _ completion: @escaping (Result < HyperwalletStatusTransition?,
        HyperwalletErrorType>) -> Void) {
        Hyperwallet.shared.scheduleTransfer(transferToken: transfer.token!,
                                            notes: transfer.notes,
                                            completion: TransferRepositoryCompletionHelper.performHandler(completion))
    }
}
