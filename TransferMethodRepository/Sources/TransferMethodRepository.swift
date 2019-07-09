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

import Foundation
import HyperwalletSDK

/// Transfer method repository protocol
public protocol TransferMethodRepository {
    /// Creates a `HyperwalletTransferMethod` for the User associated with the authentication token returned from
    /// `HyperwalletAuthenticationTokenProvider.retrieveAuthenticationToken(_ : @escaping CompletionHandler)`.
    ///
    /// - Parameters:
    ///   - transferMethod: the `HyperwalletTransferMethod` to be created
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func create(
        transferMethod: HyperwalletTransferMethod,
        _ completion: @escaping (Result<HyperwalletTransferMethod?, HyperwalletErrorType>) -> Void)

    /// Deactivates the `HyperwalletTransferMethod` linked to the transfer method token specified. The
    /// `HyperwalletTransferMethod` being deactivated must belong to the User that is associated with the
    /// authentication token returned from
    /// `HyperwalletAuthenticationTokenProvider.retrieveAuthenticationToken(_ : @escaping CompletionHandler)`.
    ///
    /// - Parameters:
    ///   - transferMethodToken: transferMethodToken descriptionthe Hyperwallet specific unique identifier for
    ///                          the `HyperwalletTransferMethod` being deactivated
    ///   - notes: a note regarding the status change
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func deactivate(
        transferMethodToken: String,
        notes: String?,
        _ completion: @escaping (Result<HyperwalletStatusTransition?, HyperwalletErrorType>) -> Void)

    /// Returns the `HyperwalletPageList<HyperwalletTransferMethod>` (Bank Account, Bank Card, PayPay Account,
    /// Prepaid Card, Paper Checks), or nil if non exist.
    ///
    /// - Parameters:
    ///   - queryParam: the ordering and filtering criteria
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func listTransferMethods(
        _ queryParam: HyperwalletTransferMethodQueryParam?,
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType>) -> Void)
}

final class RemoteTransferMethodRepository: TransferMethodRepository {
    func create(transferMethod: HyperwalletTransferMethod,
                _ completion: @escaping (Result<HyperwalletTransferMethod?, HyperwalletErrorType>) -> Void) {
//        if let bankAccount = transferMethod as? HyperwalletBankAccount {
//            Hyperwallet.shared.createBankAccount(account: bankAccount,
//                                                 completion: createTransferMethodHandler())
//        } else if let bankCard = transferMethod as? HyperwalletBankCard {
//            Hyperwallet.shared.createBankCard(account: bankCard,
//                                              completion: createTransferMethodHandler())
//        } else if let payPalAccount = transferMethod as? HyperwalletPayPalAccount {
//            Hyperwallet.shared.createPayPalAccount(account: payPalAccount,
//                                                   completion: createTransferMethodHandler())
//        }

    }

    func deactivate(transferMethodToken: String,
                    notes: String?,
                    _ completion: @escaping (Result<HyperwalletStatusTransition?, HyperwalletErrorType>) -> Void) {
    }

    func listTransferMethods(
        _ queryParam: HyperwalletTransferMethodQueryParam?,
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletTransferMethod>?,
                                        HyperwalletErrorType>) -> Void) {
    }

    @discardableResult
    private func performCompletion<T>(_ error: HyperwalletErrorType?,
                                      _ result: T?,
                                      _ completionHandler: @escaping (Result<T?, HyperwalletErrorType>) -> Void,
                                      _ repositoryOriginalValue: T? = nil) -> T? {
        if let error = error {
            DispatchQueue.main.async {
                completionHandler(.failure(error))
            }
        } else {
            DispatchQueue.main.async {
                completionHandler(.success(result))
            }
            return result
        }

        return repositoryOriginalValue
    }
}
