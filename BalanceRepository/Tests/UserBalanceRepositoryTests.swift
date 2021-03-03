import BalanceRepository
import Hippolyte
 import HyperwalletSDK
 import XCTest

 class UserBalanceRepositoryTests: XCTestCase {
    private lazy var individualUserResponse = HyperwalletTestHelper.getDataFromJson("ListBalancesResponseSuccess")
    private var factory: BalanceRepositoryFactory!
    private var userBalanceRepository: UserBalanceRepository!
    private var balanceExpectation: XCTestExpectation!

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        factory = BalanceRepositoryFactory.shared
        userBalanceRepository = factory.balanceRepository()
        balanceExpectation = self.expectation(description: "load user balance")
    }

    override func tearDown() {
        BalanceRepositoryFactory.clearInstance()
    }

    func testListUserBalance_success() {
        var userBalanceList = [HyperwalletBalance]()
        HyperwalletTestHelper.setUpMockServer(request: UserBalanceRequestHelper
                                                .setUpRequest(individualUserResponse))
        userBalanceRepository.listUserBalances(offset: 0, limit: 20) { [weak balanceExpectation] result in
            switch result {
            case .success(let balanceList):
                guard let balanceList = balanceList else {
                    XCTFail("The User's balance list should not be empty")
                    return
                }
                userBalanceList = balanceList.data!
                balanceExpectation?.fulfill()

            case .failure:
                XCTFail("Unexpected error")
            }
        }

        wait(for: [balanceExpectation], timeout: 1)
        XCTAssertFalse(userBalanceList.isEmpty, "The User's balance list should not be empty")
    }

    func testListUserBalance_failure() {
        HyperwalletTestHelper.setUpMockServer(request: UserBalanceRequestHelper
                                                .setUpRequest(individualUserResponse,
                                                              NSError(domain: NSURLErrorDomain,
                                                                      code: 500,
                                                                      userInfo: nil),
                                                              500))
        userBalanceRepository.listUserBalances(offset: 0, limit: 20) { [weak balanceExpectation] result in
            switch result {
            case .success:
                XCTFail("The listUserBalances method should return Error")

            case .failure(let error):
                XCTAssertNotNil(error, "Error should not be nil")
                balanceExpectation?.fulfill()
            }
        }
        wait(for: [balanceExpectation], timeout: 1)
    }
 }
