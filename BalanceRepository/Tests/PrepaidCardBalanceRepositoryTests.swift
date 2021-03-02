// import Hippolyte
// import HyperwalletSDK
//
// class PrepaidCardBalanceRepositoryTests: XCTestCase {
//    private static let restURL =
//    "\(host)/rest/v3/users/yourUserToken/prepaid-cards/yourPrepaidCardToken/balances?"
//    private static let applicationJson = "application/json"
//    private var factory: BalanceRepositoryFactory!
//    private var prepaidCardBalanceRepository: PrepaidCardBalanceRepository!
//    private var balanceExpectation: XCTestExpectation!
//
//    override func setUp() {
//        Hyperwallet.setup(AuthenticationTokenProviderMock())
//        factory = BalanceRepositoryFactory.shared
//        prepaidCardBalanceRepository = factory.prepaidCardBalanceRepository()
//        balanceExpectation = self.expectation(description: "load Prepaid Card balance")
//    }
//
//    override func tearDown() {
//        BalanceRepositoryFactory.clearInstance()
//        MockServer.stopMockServer()
//    }
//
//    func testListPrepaidCardBalance_success() {
//        var prepaidCardBalanceList = [HyperwalletBalance]()
//        let request = setUpPrepaicCardBalanceRequest("PrepaidCardBalanceResponseSuccess")
//        MockServer.setUpMockServer(request: request)
//        prepaidCardBalanceRepository.listPrepaidCardBalances(prepaidCardToken: "yourPrepaidCardToken",
//                                                             offset: 0,
//                                                             limit: 10) { [weak balanceExpectation] result in
//            switch result {
//            case .success(let balanceList):
//                guard let balanceList = balanceList else {
//                    XCTFail("The Prepaid Card's balance list should not be empty")
//                    return
//                }
//                prepaidCardBalanceList = balanceList.data!
//                balanceExpectation?.fulfill()
//
//            case .failure:
//                XCTFail("Unexpected error")
//            }
//        }
//
//        wait(for: [balanceExpectation], timeout: 1)
//        XCTAssertFalse(prepaidCardBalanceList.isEmpty, "The Prepaid Card's balance list should not be empty")
//        XCTAssertEqual(prepaidCardBalanceList.count, 1, "The Prepaid Card's balance list count should be 1")
//        XCTAssertNotNil(prepaidCardBalanceList.first?.amount,
//                        "The Prepaid Card's balance list amount should not be nil")
//    }
//
//    func testListPrepaidCardBalance_failure() {
//        let request = setUpPrepaicCardBalanceRequest("PrepaidCardBalanceResponseSuccess",
//                                                     NSError(domain: NSURLErrorDomain, code: 500, userInfo: nil))
//        MockServer.setUpMockServer(request: request)
//        prepaidCardBalanceRepository.listPrepaidCardBalances(prepaidCardToken: "yourPrepaidCardToken",
//                                                             offset: 0,
//                                                             limit: 20) { [weak balanceExpectation] result in
//            switch result {
//            case .success:
//                XCTFail("The listPrepaidCardBalances method should return Error")
//
//            case .failure(let error):
//                XCTAssertNotNil(error, "Error should not be nil")
//                balanceExpectation?.fulfill()
//            }
//        }
//        wait(for: [balanceExpectation], timeout: 1)
//    }
//
//    private func setUpPrepaicCardBalanceRequest(_ responseFile: String,
//                                                _ error: NSError? = nil,
//                                                _ httpCode: Int = 200) -> StubRequest {
//        let data = MockServer.getDataFromJson(responseFile)
//        return MockServer.buildGetRequestRegexMatcher(pattern: PrepaidCardBalanceRepositoryTests.restURL,
//                                                      MockServer.setUpMockedResponse(data,
//                                                                                     error,
//                                                                                     PrepaidCardBalanceRepositoryTests
//                                                                                        .applicationJson,
//                                                                                     httpCode),
//        PrepaidCardBalanceRepositoryTests.applicationJson)
//    }
// }
