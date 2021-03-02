// import Hippolyte
// import HyperwalletSDK
// import XCTest
//
// class UserBalanceRepositoryTests: XCTestCase {
//    private static let restURL = "\(host)/rest/v3/users/yourUserToken/balances?"
//    private static let applicationJson = "application/json"
//    private var factory: BalanceRepositoryFactory!
//    private var userBalanceRepository: UserBalanceRepository!
//    private var balanceExpectation: XCTestExpectation!
//
//    override func setUp() {
//        Hyperwallet.setup(AuthenticationTokenProviderMock())
//        factory = BalanceRepositoryFactory.shared
//        userBalanceRepository = factory.balanceRepository()
//        balanceExpectation = self.expectation(description: "load user balance")
//    }
//
//    override func tearDown() {
//        BalanceRepositoryFactory.clearInstance()
//        MockServer.stopMockServer()
//    }
//
//    func testListUserBalance_success() {
//        var userBalanceList = [HyperwalletBalance]()
//        let request = setUpBalanceRequest("ListBalancesResponseSuccess")
//        MockServer.setUpMockServer(request: request)
//        userBalanceRepository.listUserBalances(offset: 0, limit: 20) { [weak balanceExpectation] result in
//            switch result {
//            case .success(let balanceList):
//                guard let balanceList = balanceList else {
//                    XCTFail("The User's balance list should not be empty")
//                    return
//                }
//                userBalanceList = balanceList.data!
//                balanceExpectation?.fulfill()
//
//            case .failure:
//                XCTFail("Unexpected error")
//            }
//        }
//
//        wait(for: [balanceExpectation], timeout: 1)
//        XCTAssertFalse(userBalanceList.isEmpty, "The User's balance list should not be empty")
//    }
//
//    func testListUserBalance_failure() {
//        let request = setUpBalanceRequest("ListBalancesResponseSuccess",
//                                          NSError(domain: NSURLErrorDomain, code: 500, userInfo: nil))
//        MockServer.setUpMockServer(request: request)
//        userBalanceRepository.listUserBalances(offset: 0, limit: 20) { [weak balanceExpectation] result in
//            switch result {
//            case .success:
//                XCTFail("The listUserBalances method should return Error")
//
//            case .failure(let error):
//                XCTAssertNotNil(error, "Error should not be nil")
//                balanceExpectation?.fulfill()
//            }
//        }
//        wait(for: [balanceExpectation], timeout: 1)
//    }
//
//    private func setUpBalanceRequest(_ responseFile: String,
//                                     _ error: NSError? = nil,
//                                     _ httpCode: Int = 200) -> StubRequest {
//        let data = MockServer.getDataFromJson(responseFile)
//        return MockServer.buildGetRequestRegexMatcher(pattern: UserBalanceRepositoryTests.restURL,
//                                                      MockServer.setUpMockedResponse(data,
//                                                                                     error,
//                                                                                     UserBalanceRepositoryTests
//                                                                                        .applicationJson,
//                                                                                     httpCode),
//        UserBalanceRepositoryTests.applicationJson)
//    }
// }
