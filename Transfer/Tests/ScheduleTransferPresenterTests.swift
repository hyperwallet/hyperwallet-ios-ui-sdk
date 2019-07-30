import Hippolyte
import HyperwalletSDK
@testable import Transfer
import XCTest

class ScheduleTransferPresenterTests: XCTestCase {
    private var presenter: ScheduleTransferPresenter!
    private let mockView = MockScheduleTransferViewTests()
    private let transferMethod = HyperwalletBankAccount.Builder(transferMethodCountry: "US",
                                                                transferMethodCurrency: "USD",
                                                                transferMethodProfileType: "INDIVIDUAL",
                                                                transferMethodType: "BANK_ACCOUNT")
        .build()
    private var transfer: HyperwalletTransfer!

    override func setUp() {
        transfer = getTransfer(from: HyperwalletTestHelper.getDataFromJson("CreateTransferResponse"))!
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = ScheduleTransferPresenter(view: mockView, transferMethod: transferMethod, transfer: transfer)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
    }

    public func testScheduleTransfer_success() {
        // Given
        let requestUrl = String(format: "%@transfers/trf-123456/status-transitions", HyperwalletTestHelper.restURL)
        TransferRequestHelper.setupSucessRequest("ScheduleTransferResponse", requestUrl)
        let expectation = self.expectation(description: "Schedule a transfer")
        mockView.expectation = expectation

        // When
        presenter.scheduleTransfer()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The isShowConfirmationPerformed should be performed")
        XCTAssertTrue(mockView.isShowProcessingPerformed, "The isShowProcessingPerformed should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
    }

    public func testScheduleTransfer_failure() {
        // Given
        let requestUrl = String(format: "%@transfers/trf-123456/status-transitions", HyperwalletTestHelper.restURL)
        TransferRequestHelper.setupFailureRequest("ScheduleTransferExpiredTransferResponse", requestUrl)
        let expectation = self.expectation(description: "Schedule a transfer")
        mockView.expectation = expectation

        // When
        presenter.scheduleTransfer()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowProcessingPerformed, "The isShowProcessingPerformed should be performed")
        XCTAssertTrue(mockView.isDismissProcessingPerformed, "The isDismissProcessingPerformed should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The isShowConfirmationPerformed should not be performed")
        XCTAssertFalse(mockView.isNotificationSent, "The notification should not be sent")
    }

    private func getTransfer(from jsonData: Data) -> HyperwalletTransfer? {
        let decoder = JSONDecoder()
        return try? decoder.decode(HyperwalletTransfer.self, from: jsonData)
    }
}

class MockScheduleTransferViewTests: ScheduleTransferView {
    var isShowProcessingPerformed = false
    var isShowConfirmationPerformed = false
    var isDismissProcessingPerformed = false
    var isShowErrorPerformed = false
    var isNotificationSent = false
    var expectation: XCTestExpectation?

    func resetStates() {
        isShowProcessingPerformed = false
        isShowConfirmationPerformed = false
        isDismissProcessingPerformed = false
        isShowErrorPerformed = false
        isNotificationSent = false
        expectation = nil
    }

    func showProcessing() {
        isShowProcessingPerformed = true
    }

    func showConfirmation(handler: @escaping () -> Void) {
        isShowConfirmationPerformed = true
        handler()
    }

    func dismissProcessing(handler: @escaping () -> Void) {
        isDismissProcessingPerformed = true
        handler()
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry!()
        expectation?.fulfill()
    }

    func notifyTransferScheduled(_ hyperwalletStatusTransition: HyperwalletStatusTransition) {
        isNotificationSent = true
        expectation?.fulfill()
    }
}
