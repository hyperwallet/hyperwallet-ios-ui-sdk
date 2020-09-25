import HyperwalletSDK

///  Prepaid Card repository protocol
public protocol PrepaidCardRepository {
    /// List Prepaid cards
    func listPrepaidCards(completion: @escaping (Result<HyperwalletPageList<HyperwalletPrepaidCard>?,
    HyperwalletErrorType>) -> Void)
}

/// Prepaid Card repository
public final class RemotePrepaidCardRepository: PrepaidCardRepository {
    var prepaidCardPageList: HyperwalletPageList<HyperwalletPrepaidCard>?

    public func listPrepaidCards(completion: @escaping (Result<HyperwalletPageList<HyperwalletPrepaidCard>?,
    HyperwalletErrorType>) -> Void) {
        if prepaidCardPageList == nil {
            Hyperwallet.shared.listPrepaidCards(queryParam: setUpPrepaidCardQueryParam(),
                                                completion: listPrepaidCardHandler(completion))
        } else {
            completion(.success(prepaidCardPageList))
        }
    }

    private func listPrepaidCardHandler(
            _ completion: @escaping (Result<HyperwalletPageList<HyperwalletPrepaidCard>?,
            HyperwalletErrorType>) -> Void)
                    -> (HyperwalletPageList<HyperwalletPrepaidCard>?, HyperwalletErrorType?) -> Void {
        return { (result, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success(result))
                    self.prepaidCardPageList = result
                }
            }
        }
    }

    private func setUpPrepaidCardQueryParam() -> HyperwalletPrepaidCardQueryParm {
        let queryParam = HyperwalletPrepaidCardQueryParm()
        // Only fetch active prepaid cards
        queryParam.status = .activated
        return queryParam
    }
}
