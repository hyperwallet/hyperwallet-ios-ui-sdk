import HyperwalletSDK

///  Prepaid Card repository protocol
public protocol PrepaidCardRepository {
    /// List Prepaid cards
    func listPrepaidCards(queryParam: HyperwalletPrepaidCardQueryParam,
                          completion: @escaping (Result<HyperwalletPageList<HyperwalletPrepaidCard>?,
    HyperwalletErrorType>) -> Void)

    /// Get Prepaid card
    func getPrepaidCard(token: String, completion: @escaping (Result < HyperwalletPrepaidCard?,
        HyperwalletErrorType>) -> Void)

    /// Refreshes Prepaid Card
    func refreshPrepaidCard()

    /// Refreshes Prepaid Cards
    func refreshPrepaidCards()
}

/// Prepaid Card repository
public final class RemotePrepaidCardRepository: PrepaidCardRepository {
    var prepaidCardPageList: HyperwalletPageList<HyperwalletPrepaidCard>?
    var prepaidCard: HyperwalletPrepaidCard?

    public func listPrepaidCards(queryParam: HyperwalletPrepaidCardQueryParam,
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

    /// Refreshes Prepaid Card
    public func refreshPrepaidCard() {
        prepaidCard = nil
    }

    /// Refreshes Prepaid Cards
    public func refreshPrepaidCards() {
        prepaidCardPageList = nil
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

    private func setUpPrepaidCardQueryParam() -> HyperwalletPrepaidCardQueryParam {
        let queryParam = HyperwalletPrepaidCardQueryParam()
        // Only fetch active prepaid cards
        queryParam.status = HyperwalletPrepaidCardQueryParam.QueryStatus.activated.rawValue
        return queryParam
    }
}
