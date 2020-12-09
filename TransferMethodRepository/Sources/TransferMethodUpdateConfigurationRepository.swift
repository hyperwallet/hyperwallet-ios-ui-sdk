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

/// Transfer method configuration repository protocol
public protocol TransferMethodUpdateConfigurationRepository {
    ///  Gets the transfer method update fields based on the parameters
    ///
    /// - Parameters:
    ///   - transferMethodToken: the `TransferMethodToken`
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func getFields(
        _ transferMethodToken: String,
        completion: @escaping (Result < HyperwalletTransferMethodUpdateConfigurationField?,
        HyperwalletErrorType>) -> Void)

    /// Refreshes the transfer method fields
    func refreshFields()
}

/// RemoteTransferMethodUpdateConfigurationRepository
public final class RemoteTransferMethodUpdateConfigurationRepository: TransferMethodUpdateConfigurationRepository {
    private var transferMethodUpdateConfigurationFieldsDictionary =
        [HyperwalletTransferMethodUpdateConfigurationFieldQuery: HyperwalletTransferMethodUpdateConfigurationField]()

    public func getFields(_ transferMethodToken: String,
                          completion: @escaping (
        Result<HyperwalletTransferMethodUpdateConfigurationField?, HyperwalletErrorType>) -> Void) {
        let fieldsQuery = HyperwalletTransferMethodUpdateConfigurationFieldQuery(
            transferMethodToken: transferMethodToken)
        guard let transferMethodUpdateConfigurationFields =
            transferMethodUpdateConfigurationFieldsDictionary[fieldsQuery]
            else {
            Hyperwallet.shared
                .retrieveTransferMethodUpdateConfigurationFields(request: fieldsQuery,
                                                                 completion: getFieldsHandler(fieldsQuery, completion))
            return
        }
        completion(.success(transferMethodUpdateConfigurationFields))
    }

    public func refreshFields() {
        transferMethodUpdateConfigurationFieldsDictionary =
        [HyperwalletTransferMethodUpdateConfigurationFieldQuery: HyperwalletTransferMethodUpdateConfigurationField]()
    }
    private func getFieldsHandler(
        _ fieldQuery: HyperwalletTransferMethodUpdateConfigurationFieldQuery,
        _ completion: @escaping (Result < HyperwalletTransferMethodUpdateConfigurationField?,
        HyperwalletErrorType>) -> Void)
        -> (HyperwalletTransferMethodUpdateConfigurationField?,
        HyperwalletErrorType?) -> Void {
        return { (result, error) in
            self.transferMethodUpdateConfigurationFieldsDictionary[fieldQuery] =
                TransferMethodRepositoryCompletionHelper
                .performHandler(error, result, completion)
        }
    }
}