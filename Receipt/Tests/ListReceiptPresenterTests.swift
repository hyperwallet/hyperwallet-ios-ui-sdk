#if !COCOAPODS
import Common
#endif
import Hippolyte
import HyperwalletSDK
@testable import Receipt
import TransferMethodRepository
import XCTest

class ListReceiptPresenterTests: XCTestCase {
    private var presenter: ListReceiptPresenter!
    private let mockView = MockListReceiptView()
    private lazy var listReceiptPayload = HyperwalletTestHelper
        .getDataFromJson("UserReceiptResponse")
    private lazy var listReceiptNextPagePayload = HyperwalletTestHelper
        .getDataFromJson("UserReceiptNextPageResponse")
    private lazy var listPrepaidCardReceiptPayload = HyperwalletTestHelper
        .getDataFromJson("PrepaidCardReceiptResponse")
    private lazy var listPrepaidCardReceiptNextPagePayload = HyperwalletTestHelper
        .getDataFromJson("PrepaidCardReceiptNextPageResponse")
    private lazy var listPrepaidCardsPayload = HyperwalletTestHelper
        .getDataFromJson("ListPrepaidCardResponse")

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = ListReceiptPresenter(view: mockView, showAllAvailableSources: false)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
        TransferMethodRepositoryFactory.clearInstance()
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .walletModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
    }

    //swiftlint:disable function_body_length
    func testListUserReceipt_success() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listReceiptPayload))

        let expectation = self.expectation(description: "load user receipts")
        mockView.expectation = expectation

        // When
        presenter.listReceipts()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isLoadReceiptPerformed, "The loadReceipt should be performed")

        XCTAssertEqual(presenter.sectionData.count, 3, "The count of groupedSectionArray should be 3")
        XCTAssertEqual(presenter.sectionData.first?.value.count,
                       9,
                       "The receipt number of the first group should be 9")
        XCTAssertEqual(presenter.sectionData[1].value.count,
                       9,
                       "The receipt number of the second group should be 9")

        XCTAssertEqual(presenter.sectionData.last?.value.count,
                       2,
                       "The receipt number of the last group should be 2")
        let firstReceipt = presenter.sectionData[0].value[0]
        XCTAssertNotNil(firstReceipt, "firstCellConfiguration should not be nil")
        XCTAssertEqual(firstReceipt.amount, "5.00", "The amount should be 5.00")
        XCTAssertEqual(firstReceipt.type?.rawValue.lowercased().localized(), "Payment", "The type should be Payment")
        XCTAssertEqual(firstReceipt.createdOn,
                       "2019-05-24T17:35:20",
                       "The created on should be 2019-05-24T17:35:20")
        XCTAssertEqual(firstReceipt.currency, "USD", "The currency should be USD")
        XCTAssertEqual(firstReceipt.entry?.rawValue, "CREDIT", "The entry should be CREDIT")

        // Load more receipts
        // Given
        HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listReceiptNextPagePayload))

        let expectationLoadMore = self.expectation(description: "load more user receipts")
        mockView.expectation = expectationLoadMore

        // When
        presenter.listReceipts()
        wait(for: [expectationLoadMore], timeout: 1)

        // Then
        XCTAssertEqual(presenter.sectionData.count, 5, "The count of groupedSectionArray should be 5 ")
        XCTAssertEqual(presenter.sectionData.first?.value.count,
                       9,
                       "The receipt number of the first group should be 9")
        XCTAssertEqual(presenter.sectionData[1].value.count,
                       9,
                       "The receipt number of the second group should be 9")
        XCTAssertEqual(presenter.sectionData[2].value.count,
                       5,
                       "The receipt number of the third group should be 5")
        XCTAssertEqual(presenter.sectionData[3].value.count,
                       3,
                       "The receipt number of the fourth group should be 3")
        XCTAssertEqual(presenter.sectionData.last?.value.count,
                       3,
                       "The receipt number of the last group should be 3")
    }

    func testListUserReceipt_failureWithError() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request:
            setUpReceiptRequest(listReceiptPayload, (NSError(domain: "", code: -1009, userInfo: nil))))

        let expectation = self.expectation(description: "load user receipt")
        mockView.expectation = expectation

        // When
        presenter.listReceipts()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isLoadReceiptPerformed, "The loadReceipt should not be performed")

        XCTAssertEqual(presenter.sectionData.count, 0, "The count of sections should be 0")
    }

    func testListPrepaidCardReceipt_success() {
        presenter = ListReceiptPresenter(view: mockView,
                                         prepaidCardToken: "trm-123456789",
                                         showAllAvailableSources: false)

        // Given
        HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listPrepaidCardReceiptPayload,
                                                                           nil,
                                                                           "trm-123456789"))

        let expectation = self.expectation(description: "load prepaid card receipts")
        mockView.expectation = expectation

        // When
        presenter.listReceipts()
        wait(for: [expectation], timeout: 1)

        // Then

        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isLoadReceiptPerformed, "The loadReceipt should be performed")

        XCTAssertEqual(presenter.sectionData.count, 5, "The count of sections should be 5")
        XCTAssertEqual(presenter.sectionData.first?.value.count,
                       2,
                       "The receipt number of the first section should be 2")
        XCTAssertEqual(presenter.sectionData[1].value.count,
                       9,
                       "The receipt number of the second section should be 9")

        XCTAssertEqual(presenter.sectionData[4].value.count,
                       3,
                       "The receipt number of the fifth section should be 2")
    }

    func testListAllSourcesReceipt_userReceiptOnly() {
        presenter = ListReceiptPresenter(view: mockView,
                                         showAllAvailableSources: true)

        HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listReceiptPayload))
        PrepaidCardRepositoryRequestHelper.setupNoContentRequest(prepaidCardToken: nil)

        let expectation = self.expectation(description: "load user receipts")
        mockView.expectation = expectation

        // When
        presenter.listReceipts()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(presenter.segmentedControlItems.count, 1, "There should be 1 segment control item")
        XCTAssertEqual(presenter.segmentedControlItems[0].receiptSourceType,
                       .user,
                       "Segment control item should be of type user")
    }

    func testListAllSourcesReceipt_userReceiptOnlyPrepaidCardFailure() {
        presenter = ListReceiptPresenter(view: mockView,
                                         showAllAvailableSources: true)

        HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listReceiptPayload))
        PrepaidCardRepositoryRequestHelper.setupFailureRequest(prepaidCardToken: nil)

        let expectation = self.expectation(description: "load user receipts")
        mockView.expectation = expectation

        // When
        presenter.listReceipts()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(presenter.segmentedControlItems.count, 1, "There should be 1 segment control item")
        XCTAssertEqual(presenter.segmentedControlItems[0].receiptSourceType,
                       .user,
                       "Segment control item should be of type user")
    }

    func testListAllSourcesReceipt_userAndPrepaidCardReceipt() {
        presenter = ListReceiptPresenter(view: mockView,
                                         showAllAvailableSources: true)

        HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listReceiptPayload))
        PrepaidCardRepositoryRequestHelper.setupSuccessRequest(responseFile: "ListPrepaidCardResponse",
                                                               prepaidCardToken: nil)

        let expectation = self.expectation(description: "load user receipts")
        mockView.expectation = expectation

        // When
        presenter.listReceipts()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(presenter.segmentedControlItems.count,
                       3,
                       "There should be 3 segment control items - 1 user + 2 prepaid cards")
        XCTAssertEqual(presenter.segmentedControlItems[0].receiptSourceType,
                       .user,
                       "Segment control item 1 should be of type user")
        XCTAssertEqual(presenter.segmentedControlItems[1].receiptSourceType,
                       .prepaidCard,
                       "Segment control item 2 should be of type prepaid card")
        XCTAssertEqual(presenter.segmentedControlItems[2].receiptSourceType,
                       .prepaidCard,
                       "Segment control item 3 should be of type prepaid card")
    }

    func testListAllSourcesReceipt_prepaidCardReceipt_pay2Card() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .pay2CardModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = ListReceiptPresenter(view: mockView,
                                         showAllAvailableSources: true)

        //HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listReceiptPayload))
        PrepaidCardRepositoryRequestHelper.setupSuccessRequest(responseFile: "ListPrepaidCardResponse",
                                                               prepaidCardToken: nil)

        let expectation = self.expectation(description: "load user receipts")
        mockView.expectation = expectation

        // When
        presenter.listReceipts()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(presenter.segmentedControlItems.count,
                       2,
                       "There should be 2 segment control items - 2 prepaid cards")
        XCTAssertEqual(presenter.segmentedControlItems[0].receiptSourceType,
                       .prepaidCard,
                       "Segment control item 1 should be of type prepaid card")
        XCTAssertEqual(presenter.segmentedControlItems[1].receiptSourceType,
                       .prepaidCard,
                       "Segment control item 2 should be of type prepaid card")
    }

    func testListPrepaidCardReceipt_failureWithError() {
        // Given
        presenter = ListReceiptPresenter(view: mockView,
                                         prepaidCardToken: "trm-123456789",
                                         showAllAvailableSources: false)

        HyperwalletTestHelper.setUpMockServer(request:
            setUpReceiptRequest(listReceiptPayload, (NSError(domain: "", code: -1009, userInfo: nil)), "trm-123456789"))

        let expectation = self.expectation(description: "load prepaid card receipt")
        mockView.expectation = expectation

        // When
        presenter.listReceipts()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isLoadReceiptPerformed, "The loadReceipt should not be performed")

        XCTAssertEqual(presenter.sectionData.count, 0, "The count of sections should be 0")
    }

    private func setUpReceiptRequest(_ payload: Data,
                                     _ error: NSError? = nil,
                                     _ prepaidCardToken: String? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: payload, error: error)
        let receiptUrl = prepaidCardToken == nil ? "/receipts?":"/prepaid-cards/\(prepaidCardToken!)/receipts?"
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, receiptUrl)
        return HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
    }

    private func setUpPrepaidCardRequest(_ payload: Data,
                                         _ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: payload, error: error)
        let receiptUrl =  "\(HyperwalletTestHelper.userRestURL)/prepaid-cards"
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, receiptUrl)
        return HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
    }
}

class MockListReceiptView: ListReceiptView {
    var isHideLoadingPerformed = false
    var isShowLoadingPerformed = false
    var isShowErrorPerformed = false
    var isLoadReceiptPerformed = false
    var isLoadTableHeaderPerformed = false

    var expectation: XCTestExpectation?

    func resetStates() {
        isHideLoadingPerformed = false
        isShowLoadingPerformed = false
        isShowErrorPerformed = false
        isLoadReceiptPerformed = false
        isLoadTableHeaderPerformed = false
        expectation = nil
    }

    func hideLoading() {
        isHideLoadingPerformed = true
    }

    func reloadData() {
        isLoadReceiptPerformed = true
        expectation?.fulfill()
    }

    func reloadTableViewHeader() {
        isLoadTableHeaderPerformed = true
    }

    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry!()
        expectation?.fulfill()
    }

    func showLoading() {
        isShowLoadingPerformed = true
    }
}
