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

public protocol PrepaidCardReceiptRepository {
    /// Returns the list of receipts for the User associated with the Prepaid card token.
    ///
    /// The ordering and filtering of `HyperwalletReceipt` will be based on the criteria specified within the
    /// `HyperwalletReceiptQueryParam` object, if it is not nil. Otherwise the default ordering and
    /// filtering will be applied.
    ///
    /// * Offset: 0
    /// * Limit: 10
    /// * Created Before: N/A
    /// * Created After: N/A
    /// * Currency: All
    /// * Sort By: Created On
    ///
    /// The `completion: @escaping (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void`
    /// that is passed in to this method invocation will receive the successful
    /// response(HyperwalletPageList<HyperwalletReceipt>?) or error(HyperwalletErrorType) from processing
    /// the request.
    ///
    /// This function will request a new authentication token via `HyperwalletAuthenticationTokenProvider`
    /// if the current one is expired or is about to expire.
    ///
    /// - Parameters:
    ///   - prepaidCardToken: the prepaid card token
    ///   - queryParam: the ordering and filtering criteria
    ///   - completion: the callback handler of responses from the Hyperwallet platform
    func listPrepaidCardReceipts(prepaidCardToken: String,
                                 queryParam: HyperwalletReceiptQueryParam?,
                                 completion: @escaping (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?)
        -> Void)
}

public final class RemotePrepaidCardReceiptRepository: PrepaidCardReceiptRepository {
    public func listPrepaidCardReceipts(
        prepaidCardToken: String,
        queryParam: HyperwalletReceiptQueryParam?,
        completion: @escaping (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void) {
        Hyperwallet.shared.listPrepaidCardReceipts(prepaidCardToken: prepaidCardToken,
                                                   queryParam: queryParam,
                                                   completion: completion)
    }

//    private func setUpUserQueryParam() -> HyperwalletReceiptQueryParam {
//        let queryParam = HyperwalletReceiptQueryParam()
//        queryParam.offset = offset
//        queryParam.limit = userReceiptLimit
//        queryParam.sortBy = HyperwalletReceiptQueryParam.QuerySortable.descendantCreatedOn.rawValue
//        queryParam.createdAfter = Calendar.current.date(byAdding: .year, value: -1, to: Date())
//        return queryParam
//    }
//
//    private func setUpPrepaidCardQueryParam() -> HyperwalletReceiptQueryParam {
//        let queryParam = HyperwalletReceiptQueryParam()
//        queryParam.createdAfter = Calendar.current.date(byAdding: .year, value: -1, to: Date())
//        return queryParam
//    }
//
//    public func getKeys(completion: @escaping (HyperwalletTransferMethodConfigurationKey?,
//  HyperwalletErrorType?) -> Void) {
//            Hyperwallet.shared.retrieveTransferMethodConfigurationKeys(
//                request: HyperwalletTransferMethodConfigurationKeysQuery(),
//                completion: { [weak self] (result, error) in
//                    guard let strongSelf = self else {
//                        return
//                    }
//                    if let error = error {
//                        completion(nil, error)
//                    } else if let result = result {
//                        strongSelf.transferMethodConfigurationKeys = result
//                        completion(result, nil)
//                    }
//            })
//            return
//        //completion(transferMethodConfigurationKeys, nil)
//    }

}
