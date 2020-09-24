import HyperwalletSDK

///  Prepaid Card repository protocol
public protocol PrepaidCardRepository {
    /// List Prepaid cards
    func listPrepaidCards(queryParam: HyperwalletPrepaidCardQueryParm,
                          completion: @escaping (Result<HyperwalletPageList<HyperwalletPrepaidCard>?,
    HyperwalletErrorType>) -> Void)

    /// Get Prepaid card
    func getPrepaidCard(token: String, completion: @escaping (Result < HyperwalletPrepaidCard?,
        HyperwalletErrorType>) -> Void)
}

/// Prepaid Card repository
public final class RemotePrepaidCardRepository: PrepaidCardRepository {
    var prepaidCardPageList: HyperwalletPageList<HyperwalletPrepaidCard>?
    var prepaidCard: HyperwalletPrepaidCard?

    public func listPrepaidCards(queryParam: HyperwalletPrepaidCardQueryParm,
                                 completion: @escaping (Result<HyperwalletPageList<HyperwalletPrepaidCard>?,
    HyperwalletErrorType>) -> Void) {
        if prepaidCardPageList == nil {
            Hyperwallet.shared.listPrepaidCards(queryParam: queryParam,
                                                completion: listPrepaidCardHandler(completion))
        } else {
            completion(.success(prepaidCardPageList))
        }
    }

    public func getPrepaidCard(token: String,
                               completion: @escaping (Result < HyperwalletPrepaidCard?,
    HyperwalletErrorType>) -> Void) {
        if prepaidCard == nil {
            Hyperwallet.shared.getPrepaidCard(transferMethodToken: token, completion: getPrepaidCardHandler(completion))
        } else {
            completion(.success(prepaidCard))
        }
    }

    private func getPrepaidCardHandler(
            _ completion: @escaping (Result < HyperwalletPrepaidCard?,
            HyperwalletErrorType>) -> Void)
                    -> (HyperwalletPrepaidCard?, HyperwalletErrorType?) -> Void {
        return { (result, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.success(result))
                    self.prepaidCard = result
                }
            }
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
