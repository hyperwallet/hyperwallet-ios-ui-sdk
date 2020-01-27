#if !COCOAPODS
import Common
#endif
import Hippolyte
import HyperwalletSDK
@testable import Transfer
import XCTest

class ListTransferDestinationPresenterTests: XCTestCase {
    private var presenter: ListTransferDestinationPresenter!
    private let mockView = ListTransferDestinationViewMock()

    private lazy var listTransferDestinationPayload = HyperwalletTestHelper
        .getDataFromJson("ListTransferMethodSuccessResponse")

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = ListTransferDestinationPresenter(view: mockView)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
    }

    func testListTransferMethods_success() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request: setUpListTransferMethodsRequest())

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.listTransferMethods()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isShowTransferMethodsPerformed, "The showTransferMethods should be performed")

        XCTAssertTrue(presenter.sectionData.isNotEmpty, "The sectionData should not be empty")
        XCTAssertNotNil(presenter.sectionData[0], "The cell configuration should not be nil")
    }

    func testListTransferMethods_emptyResult() {
        // Given
        let response = HyperwalletTestHelper.noContentHTTPResponse()
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, "/transfer-methods?")
        HyperwalletTestHelper.setUpMockServer(request:
            HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.listTransferMethods()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isShowTransferMethodsPerformed, "The showTransferMethods should be performed")

        XCTAssertTrue(presenter.sectionData.isEmpty, "The sectionData should be empty")
    }

    func testListTransferMethods_failureWithError() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request:
            setUpListTransferMethodsRequest(NSError(domain: "", code: -1009, userInfo: nil)))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.listTransferMethods()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isShowTransferMethodsPerformed, "The showTransferMethods should not be performed")

        XCTAssertTrue(presenter.sectionData.isEmpty, "The sectionData should be empty")
    }

    private func setUpListTransferMethodsRequest(_ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: listTransferDestinationPayload, error: error)
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, "/transfer-methods?")
        return HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
    }
}

class ListTransferDestinationViewMock: ListTransferDestinationView {
    var isHideLoadingPerformed = false
    var isShowLoadingPerformed = false
    var isShowTransferMethodsPerformed = false
    var isShowErrorPerformed = false

    var expectation: XCTestExpectation?

    func resetStates() {
        isHideLoadingPerformed = false
        isShowLoadingPerformed = false
        isShowErrorPerformed = false
        isShowTransferMethodsPerformed = false
        expectation = nil
    }

    func hideLoading() {
        isHideLoadingPerformed = true
    }

    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry?()
        expectation?.fulfill()
    }

    func showLoading() {
        isShowLoadingPerformed = true
    }

    func showTransferMethods() {
        isShowTransferMethodsPerformed = true
        expectation?.fulfill()
    }
}
