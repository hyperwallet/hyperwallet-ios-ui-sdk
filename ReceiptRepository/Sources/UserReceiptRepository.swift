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

/// User receipt repository protocol
public protocol UserReceiptRepository {
    /// Returns the list of receipts for the User associated with the authentication token.
    ///
    /// - Parameters:
    ///   - offset: The number of records to skip. If no filters are applied, records will be skipped from the
    ///             beginning (based on default sort criteria). Range is from 0 to {n-1} where
    ///             n = number of matching records for the query.
    ///   - limit: The maximum number of records that will be returned per page.
    ///   - completion: The callback handler of responses from the Hyperwallet platform.
    func listUserReceipts(
        offset: Int,
        limit: Int,
        completion: @escaping (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>) -> Void)
}

/// User receipt repository
public final class RemoteUserReceiptRepository: UserReceiptRepository {
    private let yearAgoFromNow = Date.yearAgoFromNow

    public func listUserReceipts(
        offset: Int,
        limit: Int,
        completion: @escaping (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>) -> Void) {
        Hyperwallet.shared.listUserReceipts(queryParam: setUpUserQueryParam(offset, limit),
                                            completion: listUserReceiptsHandler(completion))
    }

    private func listUserReceiptsHandler(
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>) -> Void)
        -> (HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType?) -> Void {
            return {(result, error) in
                CompletionHelper.performHandler(error, result, completion)
            }
    }

    private func setUpUserQueryParam(_ offset: Int, _ limit: Int) -> HyperwalletReceiptQueryParam {
        let queryParam = HyperwalletReceiptQueryParam()
        queryParam.offset = offset
        queryParam.limit = limit
        queryParam.sortBy = HyperwalletReceiptQueryParam.QuerySortable.descendantCreatedOn.rawValue
        queryParam.createdAfter = yearAgoFromNow
        return queryParam
    }
}
