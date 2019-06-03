import Hippolyte
import HyperwalletSDK
@testable import HyperwalletUISDK
import XCTest

class ListReceiptPresenterTests: XCTestCase {
    private var presenter: ListReceiptViewPresenter!
    private let mockView = MockListReceiptView()
    private lazy var listReceiptPayload = HyperwalletTestHelper
        .getDataFromJson("UserReceiptResponse")
    private lazy var listReceiptNextPagePayload = HyperwalletTestHelper
        .getDataFromJson("UserReceiptNextPageResponse")

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = ListReceiptViewPresenter(view: mockView)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
    }

    func testListReceipt_success() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listReceiptPayload))

        let expectation = self.expectation(description: "load receipts")
        mockView.expectation = expectation

        // When
        presenter.listReceipt()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isLoadReceiptPerformed, "The loadReceipt should be performed")

        XCTAssertEqual(presenter.groupedSectionArray.count, 3)
        XCTAssertEqual(presenter.groupedSectionArray[2].value.count, 2)
        XCTAssertNotNil(presenter.getCellConfiguration(for: 0, in: 0))

        // Load more receipts
        // Given
        HyperwalletTestHelper.setUpMockServer(request: setUpReceiptRequest(listReceiptNextPagePayload))

        let expectationLoadMore = self.expectation(description: "load more receipts")
        mockView.expectation = expectationLoadMore

        // When
        presenter.listReceipt()
        wait(for: [expectationLoadMore], timeout: 1)

        // Then
        XCTAssertEqual(presenter.groupedSectionArray.count, 5)
        XCTAssertEqual(presenter.groupedSectionArray[2].value.count, 5)
        XCTAssertEqual(presenter.groupedSectionArray.last?.value.count, 3)
    }

    func testListReceipt_failureWithError() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request:
            setUpReceiptRequest(listReceiptPayload, (NSError(domain: "", code: -1009, userInfo: nil))))

        let expectation = self.expectation(description: "load receipt")
        mockView.expectation = expectation

        // When
        presenter.listReceipt()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isLoadReceiptPerformed, "The loadReceipt should not be performed")

        XCTAssertEqual(presenter.groupedSectionArray.count, 0, "The groupedSectionArray should be equals 0")
    }

    private func setUpReceiptRequest(_ payload: Data, _ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: payload, error: error)
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, "/receipts?")
        return HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
    }
}

class MockListReceiptView: ListReceiptView {
    var isHideLoadingPerformed = false
    var isShowLoadingPerformed = false
    var isShowErrorPerformed = false
    var isLoadReceiptPerformed = false

    var expectation: XCTestExpectation?

    func resetStates() {
        isHideLoadingPerformed = false
        isShowLoadingPerformed = false
        isShowErrorPerformed = false
        isLoadReceiptPerformed = false
        expectation = nil
    }

    func hideLoading() {
        isHideLoadingPerformed = true
    }

    func loadReceipts() {
        isLoadReceiptPerformed = true
        expectation?.fulfill()
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry!()
        expectation?.fulfill()
    }

    func showLoading() {
        isShowLoadingPerformed = true
    }
}
