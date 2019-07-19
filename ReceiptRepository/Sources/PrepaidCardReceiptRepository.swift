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

/// Prepaid card receipt repository protocol
public protocol PrepaidCardReceiptRepository {
    /// Returns the list of receipts for the User associated with the Prepaid card token.
    ///
    /// - Parameters:
    ///   - prepaidCardToken: the prepaid card token
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func listPrepaidCardReceipts(
        prepaidCardToken: String,
        completion: @escaping (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>)
        -> Void)
}

/// Prepaid card receipt repository
public final class RemotePrepaidCardReceiptRepository: PrepaidCardReceiptRepository {
    private let yearAgoFromNow = Date.yearAgoFromNow

    public func listPrepaidCardReceipts(
        prepaidCardToken: String,
        completion: @escaping (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>) -> Void) {
        Hyperwallet.shared.listPrepaidCardReceipts(prepaidCardToken: prepaidCardToken,
                                                   queryParam: setUpPrepaidCardQueryParam(),
                                                   completion: ReceiptRepositoryCompletionHelper.performHandler(completion))
    }

    private func setUpPrepaidCardQueryParam() -> HyperwalletReceiptQueryParam {
        let queryParam = HyperwalletReceiptQueryParam()
        queryParam.createdAfter = yearAgoFromNow
        return queryParam
    }
}
