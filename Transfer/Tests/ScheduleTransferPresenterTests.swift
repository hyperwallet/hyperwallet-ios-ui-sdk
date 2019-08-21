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
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        transfer = getTransfer(from: HyperwalletTestHelper.getDataFromJson("CreateTransferResponse"))!
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
        TransferRequestHelper.setupSuccessRequest("ScheduleTransferResponse", requestUrl)
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

    public func testScheduleSectionData_allSections() {
        XCTAssertEqual(presenter.sectionData.count, 5)
        assertDestinationSectionResult(destinationSection: presenter.sectionData.first!)
        assertForeignExchangeSectionResult(foreignExchangeSection: presenter.sectionData[1])
        assertSummarySectionResult(summarySection: presenter.sectionData[2])
        assertNotesSectionResult(notesSection: presenter.sectionData[3])
        assertButtonSectionResult(buttonSection: presenter.sectionData.last!)
    }

    public func testScheduleSectionData_withoutForeignExchangeAndNotesSection() {
        transfer = getTransfer(from: HyperwalletTestHelper
            .getDataFromJson("CreateTransferWithoutForeignExchangeResponse"))!
        presenter = ScheduleTransferPresenter(view: mockView, transferMethod: transferMethod, transfer: transfer)

        XCTAssertEqual(presenter.sectionData.count, 3)
        assertDestinationSectionResult(destinationSection: presenter.sectionData.first!)
        assertSummarySectionWithoutFeeResult(summarySection: presenter.sectionData[1])
        assertButtonSectionResult(buttonSection: presenter.sectionData.last!)
    }

    private func getTransfer(from jsonData: Data) -> HyperwalletTransfer? {
        let decoder = JSONDecoder()
        return try? decoder.decode(HyperwalletTransfer.self, from: jsonData)
    }

    private func assertDestinationSectionResult(destinationSection: ScheduleTransferSectionData) {
        XCTAssertEqual(destinationSection.rowCount, 1, "Destination section should have 1 row")
        XCTAssertNotNil(destinationSection.title, "The title of Destination section should not be nil")
        XCTAssertNotNil(destinationSection.scheduleTransferSectionHeader,
                        "The header of Destination section should not be nil")
        XCTAssertNotNil(destinationSection.cellIdentifier,
                        "The cellIdentifier of Destination section should not be nil")
    }

    private func assertForeignExchangeSectionResult(foreignExchangeSection: ScheduleTransferSectionData) {
        XCTAssertEqual(foreignExchangeSection.rowCount, 11, "Foreign exchange section should have 11 rows")
        XCTAssertNotNil(foreignExchangeSection.title, "The title of foreign exchange section should not be nil")
        XCTAssertNotNil(foreignExchangeSection.scheduleTransferSectionHeader,
                        "The header of foreign exchange section should not be nil")
        XCTAssertNotNil(foreignExchangeSection.cellIdentifier,
                        "The cellIdentifier of foreign exchange section should not be nil")
    }

    private func assertSummarySectionResult(summarySection: ScheduleTransferSectionData) {
        XCTAssertEqual(summarySection.rowCount, 3, "Summary section should have 3 rows")
        XCTAssertNotNil(summarySection.title, "The title of summary section should not be nil")
        XCTAssertNotNil(summarySection.scheduleTransferSectionHeader,
                        "The header of summary section should not be nil")
        XCTAssertNotNil(summarySection.cellIdentifier,
                        "The cellIdentifier of summary section should not be nil")
    }

    private func assertSummarySectionWithoutFeeResult(summarySection: ScheduleTransferSectionData) {
        XCTAssertEqual(summarySection.rowCount, 1, "Summary section should have 1 row")
        XCTAssertNotNil(summarySection.title, "The title of summary section should not be nil")
        XCTAssertNotNil(summarySection.scheduleTransferSectionHeader,
                        "The header of summary section should not be nil")
        XCTAssertNotNil(summarySection.cellIdentifier,
                        "The cellIdentifier of summary section should not be nil")
    }

    private func assertNotesSectionResult(notesSection: ScheduleTransferSectionData) {
        XCTAssertEqual(notesSection.rowCount, 1, "Notes section should have 1 row")
        XCTAssertNotNil(notesSection.scheduleTransferSectionHeader,
                        "The header of notes section should not be nil")
        XCTAssertNotNil(notesSection.cellIdentifier,
                        "The cellIdentifier of notes section should not be nil")
    }

    private func assertButtonSectionResult(buttonSection: ScheduleTransferSectionData) {
        XCTAssertEqual(buttonSection.rowCount, 1, "Button section should have 1 row")
        XCTAssertNotNil(buttonSection.scheduleTransferSectionHeader,
                        "The header of button section should not be nil")
        XCTAssertNotNil(buttonSection.cellIdentifier,
                        "The cellIdentifier of button section should not be nil")
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
