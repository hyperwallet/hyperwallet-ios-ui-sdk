import HyperwalletSDK

/// User balance repository protocol
public protocol UserBalanceRepository {
    /// Returns the list of balances for the User associated with the authentication token.
    ///
    /// - Parameters:
    ///   - offset: The number of records to skip. If no filters are applied, records will be skipped from the
    ///             beginning (based on default sort criteria). Range is from 0 to {n-1} where
    ///             n = number of matching records for the query.
    ///   - limit: The maximum number of records that will be returned per page.
    ///   - completion: The callback handler of responses from the Hyperwallet platform.
    func listUserBalances( offset: Int,
                           limit: Int,
                           completion: @escaping (Result<HyperwalletPageList<HyperwalletBalance>?,
        HyperwalletErrorType>) -> Void)
}

/// User balance repository
public final class RemoteUserBalanceRepository: UserBalanceRepository {
    public func listUserBalances( offset: Int,
                                  limit: Int,
                                  completion: @escaping (Result<HyperwalletPageList<HyperwalletBalance>?,
        HyperwalletErrorType>) -> Void) {
        Hyperwallet.shared.listUserBalances(queryParam: setUpBalanceQueryParam(offset, limit),
                                            completion: listUserBalancesHandler(completion))
    }

    private func listUserBalancesHandler(
        _ completion: @escaping (Result<HyperwalletPageList<HyperwalletBalance>?,
        HyperwalletErrorType>) -> Void)
        -> (HyperwalletPageList<HyperwalletBalance>?, HyperwalletErrorType?) -> Void {
            return { (result, error) in if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) } } else {
                DispatchQueue.main.async { completion(.success(result)) } } }
    }

    private func setUpBalanceQueryParam(_ offset: Int, _ limit: Int) -> HyperwalletBalanceQueryParam {
        let queryParam = HyperwalletBalanceQueryParam()
        queryParam.offset = offset
        queryParam.limit = limit
        return queryParam
    }
}
