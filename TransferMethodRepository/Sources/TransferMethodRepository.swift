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

/// Transfer method repository protocol
public protocol TransferMethodRepository {
    /// Creates a `HyperwalletTransferMethod` for the User associated with the authentication token returned from
    /// `HyperwalletAuthenticationTokenProvider.retrieveAuthenticationToken(_ : @escaping CompletionHandler)`.
    ///
    /// - Parameters:
    ///   - transferMethod: the `HyperwalletTransferMethod` being created
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func createTransferMethod(
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
    func deactivateTransferMethod(
        _ transferMethod: HyperwalletTransferMethod,
        _ completion: @escaping (Result<HyperwalletStatusTransition?, HyperwalletErrorType>) -> Void)

    /// Returns the `HyperwalletPageList<HyperwalletTransferMethod>` (Bank Account, Bank Card, PayPay Account,
    /// Prepaid Card, Paper Checks), or nil if non exist.
    ///
    /// - Parameters:
    ///   - queryParam: the ordering and filtering criteria
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func listTransferMethod(
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType>) -> Void)
}

final class RemoteTransferMethodRepository: TransferMethodRepository {
    private static let deactivateNote = "Deactivating Account"

    func createTransferMethod(
        _ transferMethod: HyperwalletTransferMethod,
        _ completion: @escaping (Result<HyperwalletTransferMethod?, HyperwalletErrorType>) -> Void) {
        if let bankAccount = transferMethod as? HyperwalletBankAccount {
            Hyperwallet.shared.createBankAccount(account: bankAccount,
                                                 completion: TransferMethodRepositoryCompletionHelper.performHandler(completion))
        } else if let bankCard = transferMethod as? HyperwalletBankCard {
            Hyperwallet.shared.createBankCard(account: bankCard,
                                              completion: TransferMethodRepositoryCompletionHelper.performHandler(completion))
        } else if let payPalAccount = transferMethod as? HyperwalletPayPalAccount {
            Hyperwallet.shared.createPayPalAccount(account: payPalAccount,
                                                   completion: TransferMethodRepositoryCompletionHelper.performHandler(completion))
        }
    }

    func deactivateTransferMethod(
        _ transferMethod: HyperwalletTransferMethod,
        _ completion: @escaping (Result<HyperwalletStatusTransition?, HyperwalletErrorType>) -> Void) {
        guard let transferMethodType = transferMethod.type,
            let token = transferMethod.token else {
            return
        }

        switch transferMethodType {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            Hyperwallet.shared.deactivateBankAccount(transferMethodToken: token,
                                                     notes: RemoteTransferMethodRepository.deactivateNote,
                                                     completion: TransferMethodRepositoryCompletionHelper.performHandler(completion))
        case "BANK_CARD":
            Hyperwallet.shared.deactivateBankCard(transferMethodToken: token,
                                                  notes: RemoteTransferMethodRepository.deactivateNote,
                                                  completion: TransferMethodRepositoryCompletionHelper.performHandler(completion))
        case "PAYPAL_ACCOUNT":
            Hyperwallet.shared.deactivatePayPalAccount(transferMethodToken: token,
                                                       notes: RemoteTransferMethodRepository.deactivateNote,
                                                       completion: TransferMethodRepositoryCompletionHelper.performHandler(completion))

        default:
            break
        }
    }

    func listTransferMethod(
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletTransferMethod>?,
                                        HyperwalletErrorType>) -> Void) {
        let queryParam = HyperwalletTransferMethodQueryParam()
        queryParam.limit = 100
        queryParam.status = .activated

        Hyperwallet.shared.listTransferMethods(queryParam: queryParam,
                                               completion: TransferMethodRepositoryCompletionHelper.performHandler(completion))
    }
}
