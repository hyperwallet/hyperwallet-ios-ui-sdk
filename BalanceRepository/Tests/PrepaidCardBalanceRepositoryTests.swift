import BalanceRepository
import Hippolyte
import HyperwalletSDK
import XCTest

 class PrepaidCardBalanceRepositoryTests: XCTestCase {
    private lazy var prepaidCardResponse = HyperwalletTestHelper.getDataFromJson("PrepaidCardBalanceResponseSuccess")
    private var factory: BalanceRepositoryFactory!
    private var prepaidCardBalanceRepository: PrepaidCardBalanceRepository!
    private var balanceExpectation: XCTestExpectation!

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        factory = BalanceRepositoryFactory.shared
        prepaidCardBalanceRepository = factory.prepaidCardBalanceRepository()
        balanceExpectation = self.expectation(description: "load Prepaid Card balance")
    }

    override func tearDown() {
        BalanceRepositoryFactory.clearInstance()
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testListPrepaidCardBalance_success() {
        var prepaidCardBalanceList = [HyperwalletBalance]()
        HyperwalletTestHelper.setUpMockServer(request: PrepaidCardBalanceRequestHelper
                                                .setUpRequest(prepaidCardResponse,
                                                              nil,
                                                              "yourPrepaidCardToken"))
        prepaidCardBalanceRepository.listPrepaidCardBalances(prepaidCardToken: "yourPrepaidCardToken",
                                                             offset: 0,
                                                             limit: 10) { [weak balanceExpectation] result in
            switch result {
            case .success(let balanceList):
                guard let balanceList = balanceList else {
                    XCTFail("The Prepaid Card's balance list should not be empty")
                    return
                }
                prepaidCardBalanceList = balanceList.data!
                balanceExpectation?.fulfill()

            case .failure:
                XCTFail("Unexpected error")
            }
        }

        wait(for: [balanceExpectation], timeout: 1)
        XCTAssertFalse(prepaidCardBalanceList.isEmpty, "The Prepaid Card's balance list should not be empty")
        XCTAssertEqual(prepaidCardBalanceList.count, 1, "The Prepaid Card's balance list count should be 1")
        XCTAssertNotNil(prepaidCardBalanceList.first?.amount,
                        "The Prepaid Card's balance list amount should not be nil")
    }

    func testListPrepaidCardBalance_failure() {
        HyperwalletTestHelper.setUpMockServer(request: PrepaidCardBalanceRequestHelper
                                                .setUpRequest(prepaidCardResponse,
                                                              NSError(domain: NSURLErrorDomain,
                                                                      code: 500,
                                                                      userInfo: nil),
                                                              "yourPrepaidCardToken"))

        prepaidCardBalanceRepository.listPrepaidCardBalances(prepaidCardToken: "yourPrepaidCardToken",
                                                             offset: 0,
                                                             limit: 20) { [weak balanceExpectation] result in
            switch result {
            case .success:
                XCTFail("The listPrepaidCardBalances method should return Error")

            case .failure(let error):
                XCTAssertNotNil(error, "Error should not be nil")
                balanceExpectation?.fulfill()
            }
        }
        wait(for: [balanceExpectation], timeout: 1)
    }
 }
