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
import os.log

/// Transfer method repository protocol
public protocol TransferMethodRepository {
    /// Creates a `HyperwalletTransferMethod` for the User associated with the authentication token returned from
    /// `HyperwalletAuthenticationTokenProvider.retrieveAuthenticationToken(_ : @escaping CompletionHandler)`.
    ///
    /// - Parameters:
    ///   - transferMethod: the `HyperwalletTransferMethod` being created
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func create(
        _ transferMethod: HyperwalletTransferMethod,
        _ completion: @escaping (Result<HyperwalletTransferMethod?, HyperwalletErrorType>) -> Void)

    /// Deactivates the `HyperwalletTransferMethod` linked to the transfer method token specified. The
    /// `HyperwalletTransferMethod` being deactivated must belong to the User that is associated with the
    /// authentication token returned from
    /// `HyperwalletAuthenticationTokenProvider.retrieveAuthenticationToken(_ : @escaping CompletionHandler)`.
    ///
    /// - Parameters:
    ///   - transferMethod: the `HyperwalletTransferMethod` being deactivated
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func deactivate(
        _ transferMethod: HyperwalletTransferMethod,
        _ completion: @escaping (Result<HyperwalletStatusTransition?, HyperwalletErrorType>) -> Void)

    /// Returns the `HyperwalletPageList<HyperwalletTransferMethod>` (Bank Account, Bank Card, PayPay Account,
    /// Prepaid Card, Paper Checks), or nil if non exist.
    ///
    /// - Parameters:
    ///   - queryParam: the ordering and filtering criteria
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func list(
        _ queryParam: HyperwalletTransferMethodQueryParam?,
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType>) -> Void)
}

final class RemoteTransferMethodRepository: TransferMethodRepository {
    func create(_ transferMethod: HyperwalletTransferMethod,
                _ completion: @escaping (Result<HyperwalletTransferMethod?, HyperwalletErrorType>) -> Void) {
        if let bankAccount = transferMethod as? HyperwalletBankAccount {
            Hyperwallet.shared.createBankAccount(account: bankAccount, completion: createHandler(completion))
        } else if let bankCard = transferMethod as? HyperwalletBankCard {
            Hyperwallet.shared.createBankCard(account: bankCard, completion: createHandler(completion))
        } else if let payPalAccount = transferMethod as? HyperwalletPayPalAccount {
            Hyperwallet.shared.createPayPalAccount(account: payPalAccount, completion: createHandler(completion))
        } else {
            logTransferMethodTypeNotSupported(transferMethod.type ?? "")
        }
    }

    func deactivate(_ transferMethod: HyperwalletTransferMethod,
                    _ completion: @escaping (Result<HyperwalletStatusTransition?, HyperwalletErrorType>) -> Void) {
        guard let transferMethodType = transferMethod.type,
            let token = transferMethod.token else {
            return
        }

        switch transferMethodType {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            Hyperwallet.shared.deactivateBankAccount(transferMethodToken: token,
                                                     notes: "Deactivating the Bank Account",
                                                     completion: deactivateHandler(completion))
        case "BANK_CARD":
            Hyperwallet.shared.deactivateBankCard(transferMethodToken: token,
                                                  notes: "Deactivating the Bank Card",
                                                  completion: deactivateHandler(completion))
        case "PAYPAL_ACCOUNT":
            Hyperwallet.shared.deactivatePayPalAccount(transferMethodToken: token,
                                                       notes: "Deactivating the PayPal Account",
                                                       completion: deactivateHandler(completion))

        default:
            logTransferMethodTypeNotSupported(transferMethodType)
        }
    }

    func list(
        _ queryParam: HyperwalletTransferMethodQueryParam?,
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletTransferMethod>?,
                                        HyperwalletErrorType>) -> Void) {
        Hyperwallet.shared.listTransferMethods(queryParam: queryParam,
                                               completion: listTransferMethodHandler(completion))
    }

    private func createHandler(
        _ completion: @escaping (Result<HyperwalletTransferMethod?, HyperwalletErrorType>) -> Void)
    -> (HyperwalletTransferMethod?, HyperwalletErrorType?) -> Void {
        return {(result, error) in
            RemoteTransferMethodConfigurationRepository.performCompletion(error, result, completion)
        }
    }

    private func deactivateHandler(
        _ completion: @escaping (Result<HyperwalletStatusTransition?, HyperwalletErrorType>) -> Void)
        -> (HyperwalletStatusTransition?, HyperwalletErrorType?) -> Void {
        return {(result, error) in
            RemoteTransferMethodConfigurationRepository.performCompletion(error, result, completion)
        }
    }

    private func listTransferMethodHandler(
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType>) -> Void)
        -> (HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType?) -> Void {
        return {(result, error) in
            RemoteTransferMethodConfigurationRepository.performCompletion(error, result, completion)
        }
    }

    private func logTransferMethodTypeNotSupported(_ transferMethodType: String, _ method: String = #function) {
        os_log("%s%s%s",
               log: OSLog.notSupported,
               type: .error,
               "The transfer method type : [\(transferMethodType)] is not supported.",
               method)
    }
}
