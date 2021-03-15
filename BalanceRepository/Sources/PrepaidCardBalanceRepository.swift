import HyperwalletSDK

/// Prepaid Card balance repository protocol
public protocol PrepaidCardBalanceRepository {
    /// Returns the list of balances for the Prepaid Card associated with the authentication user.
    ///
    /// - Parameters:
    ///   - offset: The number of records to skip. If no filters are applied, records will be skipped from the
    ///             beginning (based on default sort criteria). Range is from 0 to {n-1} where
    ///             n = number of matching records for the query.
    ///   - limit: The maximum number of records that will be returned per page.
    ///   - completion: The callback handler of responses from the Hyperwallet platform.
    func listPrepaidCardBalances(prepaidCardToken: String,
                                 offset: Int,
                                 limit: Int,
                                 completion: @escaping (Result<HyperwalletPageList<HyperwalletBalance>?,
                                 HyperwalletErrorType>) -> Void)
}

/// Prepaid Card balance repository
public final class RemotePrepaidCardBalanceRepository: PrepaidCardBalanceRepository {
    public func listPrepaidCardBalances(prepaidCardToken: String,
                                        offset: Int,
                                        limit: Int,
                                        completion: @escaping (Result<HyperwalletPageList<HyperwalletBalance>?,
                                        HyperwalletErrorType>) -> Void) {
        Hyperwallet.shared.listPrepaidCardBalances(prepaidCardToken: prepaidCardToken,
                                                   queryParam: setUpPrepaidCardBalanceQueryParam(offset, limit),
                                                   completion: listPrepaidCardBalancesHandler(completion))
    }

    /// Preparid card balance response handler
    private func listPrepaidCardBalancesHandler(
            _ completion: @escaping (Result<HyperwalletPageList<HyperwalletBalance>?,
            HyperwalletErrorType>) -> Void)
                    -> (HyperwalletPageList<HyperwalletBalance>?, HyperwalletErrorType?) -> Void {
        return { (result, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            }
        }
    }

    /// Set up prepaid card balance query param
    private func setUpPrepaidCardBalanceQueryParam(_ offset: Int, _ limit: Int)
        -> HyperwalletPrepaidCardBalanceQueryParam {
        let queryParam = HyperwalletPrepaidCardBalanceQueryParam()
        queryParam.offset = offset
        queryParam.limit = limit
        return queryParam
    }
}
