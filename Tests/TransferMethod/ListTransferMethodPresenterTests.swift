import Hippolyte
import HyperwalletSDK
@testable import HyperwalletUISDK
import XCTest

class ListTransferMethodPresenterTests: XCTestCase {
    private var presenter: ListTransferMethodPresenter!
    private let mockView = MockListTransferMethodView()
    private lazy var listTransferMethodPayload = HyperwalletTestHelper
        .getDataFromJson("TransferMethodMockedSuccessResponse")
    private lazy var deactivateTransferMethodPayload = HyperwalletTestHelper
        .getDataFromJson("StatusTransitionMockedResponseSuccess")
    private let transferMethodToken = "trm-123456789"

    private lazy var bankAccount: HyperwalletBankAccount = {
        let bankAccount = HyperwalletBankAccount.Builder(transferMethodCountry: "US",
                                                         transferMethodCurrency: "USD",
                                                         transferMethodProfileType: .individual)
            .build()
        bankAccount.setField(key: HyperwalletTransferMethod.TransferMethodField.token.rawValue,
                             value: transferMethodToken)
        return bankAccount
    }()

    private lazy var bankCard: HyperwalletBankCard = {
        let bankCard = HyperwalletBankCard.Builder(transferMethodCountry: "US",
                                                   transferMethodCurrency: "USD",
                                                   transferMethodProfileType: "INDIVIDUAL")
            .build()
        bankCard.setField(key: HyperwalletTransferMethod.TransferMethodField.token.rawValue,
                          value: transferMethodToken)
        return bankCard
    }()

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = ListTransferMethodPresenter(view: mockView)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
    }

    func testListTransferMethod_success() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request: setUpListTransferMethodRequest())

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.listTransferMethod()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isShowTransferMethodsPerformed, "The showTransferMethods should be performed")

        XCTAssertTrue(presenter.transferMethodExists(at: 0), "The transferMethodExists should return true")
        XCTAssertGreaterThan(presenter.numberOfCells, 0, "The numberOfCells should be greater than 0")
        XCTAssertNotNil(presenter.getCellConfiguration(for: 0), "The getCellConfiguration should not be nil")
    }

    func testListTransferMethod_failureWithError() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request:
            setUpListTransferMethodRequest(NSError(domain: "", code: -1009, userInfo: nil)))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.listTransferMethod()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isShowTransferMethodsPerformed, "The showTransferMethods should not be performed")

        XCTAssertFalse(presenter.transferMethodExists(at: 0), "The transferMethodExists should return false")
        XCTAssertEqual(presenter.numberOfCells, 0, "The numberOfCells should be equals 0")
        XCTAssertNil(presenter.getCellConfiguration(for: 0), "The getCellConfiguration should be nil")
    }

    func testDeactivateBankAccount_success() {
        // Given
        loadMockTransfermethods()
        HyperwalletTestHelper.setUpMockServer(request: setUpDeactivateTransferMethodRequest("/bank-accounts/"))

        let expectation = self.expectation(description: "deactivate a bank account")
        mockView.expectation = expectation

        // When
        presenter.deactivateTransferMethod(at: 0)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowProcessingPerformed, "The showProcessing should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
    }

    func testDeactivateBankAccount_failureWithError() {
        // Given
        loadMockTransfermethods()
        HyperwalletTestHelper.setUpMockServer(request:
            setUpDeactivateTransferMethodRequest("/bank-accounts/",
                                                 NSError(domain: "", code: -1009, userInfo: nil)))

        let expectation = self.expectation(description: "deactivate a bank account")
        mockView.expectation = expectation

        // When
        presenter.deactivateTransferMethod(at: 0)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowProcessingPerformed, "The showProcessing should be performed")
        XCTAssertTrue(mockView.isDismissProcessingPerformed, "The dismissProcessing should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showConfirmation should not be performed")
    }

    func testDeactivateBankCard_success() {
        // Given
        loadMockTransfermethods()
        HyperwalletTestHelper.setUpMockServer(request: setUpDeactivateTransferMethodRequest("/bank-cards/"))

        let expectation = self.expectation(description: "deactivate a bank account")
        mockView.expectation = expectation

        // When
        presenter.deactivateTransferMethod(at: 1)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowProcessingPerformed, "The showProcessing should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
    }

    func testDeactivatePayPalAccount_success() {
        // Given
        loadMockTransfermethods()
        HyperwalletTestHelper.setUpMockServer(request: setUpDeactivateTransferMethodRequest("/paypal-accounts/"))

        let expectation = self.expectation(description: "deactivate a PayPal account")
        mockView.expectation = expectation

        // When
        presenter.deactivateTransferMethod(at: 2)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowProcessingPerformed, "The showProcessing should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
    }

    func testDeactivateBankCard_failureWithError() {
        // Given
        loadMockTransfermethods()
        HyperwalletTestHelper.setUpMockServer(request:
            setUpDeactivateTransferMethodRequest("/bank-cards/", NSError(domain: "", code: -1009, userInfo: nil)))

        let expectation = self.expectation(description: "deactivate a bank card")
        mockView.expectation = expectation

        // When
        presenter.deactivateTransferMethod(at: 1)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowProcessingPerformed, "The showProcessing should be performed")
        XCTAssertTrue(mockView.isDismissProcessingPerformed, "The dismissProcessing should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showConfirmation should not be performed")
    }

    private func setUpPresenter() {
    }

    private func loadMockTransfermethods() {
        let bankAccount = HyperwalletBankAccount.Builder(transferMethodCountry: "US",
                                                         transferMethodCurrency: "USD",
                                                         transferMethodProfileType: .individual)
            .build()
        bankAccount.setField(key: "token", value: "trm-123456789")

        let bankCard = HyperwalletBankCard.Builder(transferMethodCountry: "CA",
                                                   transferMethodCurrency: "CAD",
                                                   transferMethodProfileType: "INDIVIDUAL")
            .build()
        bankCard.setField(key: "token", value: "trm-123456789")

        let payPalAccount = HyperwalletPayPalAccount.Builder(transferMethodCountry: "US",
                                                             transferMethodCurrency: "USD")
            .build()
        payPalAccount.setField(key: "token", value: "trm-123456789")

        let transferMethods = [bankAccount, bankCard, payPalAccount]
        presenter.transferMethods = transferMethods
    }

    private func setUpListTransferMethodRequest(_ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: listTransferMethodPayload, error: error)
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, "/transfer-methods?")
        return HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response)
    }

    private func setUpDeactivateTransferMethodRequest(_ path: String, _ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: deactivateTransferMethodPayload, error: error)
        let url = String(format: "%@%@%@%@",
                         HyperwalletTestHelper.userRestURL,
                         path,
                         transferMethodToken,
                         "/status-transitions")
        return HyperwalletTestHelper.buildPostResquest(baseUrl: url, response)
    }
}

class MockListTransferMethodView: ListTransferMethodView {
    var isHideLoadingPerformed = false
    var isShowLoadingPerformed = false
    var isShowTransferMethodsPerformed = false
    var isShowProcessingPerformed = false
    var isDismissProcessingPerformed = false
    var isShowConfirmationPerformed = false
    var isShowErrorPerformed = false
    var isNotificationSent = false

    var expectation: XCTestExpectation?

    func resetStates() {
        isHideLoadingPerformed = false
        isShowLoadingPerformed = false
        isShowProcessingPerformed = false
        isDismissProcessingPerformed = false
        isShowConfirmationPerformed = false
        isShowErrorPerformed = false
        isShowTransferMethodsPerformed = false
        isNotificationSent = false
        expectation = nil
    }

    func hideLoading() {
        isHideLoadingPerformed = true
    }

    func showLoading() {
        isShowLoadingPerformed = true
    }

    func showProcessing() {
        isShowProcessingPerformed = true
    }

    func dismissProcessing(handler: @escaping () -> Void) {
        isDismissProcessingPerformed = true
        handler()
    }

    func showConfirmation(handler: @escaping (() -> Void)) {
        isShowConfirmationPerformed = true
        handler()
        expectation?.fulfill()
    }

    func showTransferMethods() {
        isShowTransferMethodsPerformed = true
        expectation?.fulfill()
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry?()
        expectation?.fulfill()
    }

    func notifyTransferMethodDeactivated(_ hyperwalletStatusTransition: HyperwalletStatusTransition) {
        isNotificationSent = true
    }
}
