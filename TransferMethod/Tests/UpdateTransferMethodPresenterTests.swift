#if !COCOAPODS
import Common
#endif
import Hippolyte
import HyperwalletSDK
@testable import TransferMethod
import XCTest

class UpdateTransferMethodPresenterTests: XCTestCase {
    private var presenter: UpdateTransferMethodPresenter!
    private let mockView = UpdateTransferMethodViewMock()
    private lazy var transferMethodConfigurationFieldsResponse = HyperwalletTestHelper
        .getDataFromJson("TransferMethodUpdateConfigurationFieldsResponse")
    private lazy var transferMethodConfigurationFieldsBankAccountResponse = HyperwalletTestHelper
    .getDataFromJson("TransferMethodUpdateConfigurationFieldsBankAccountResponse")
    private lazy var transferMethodConfigurationFieldsPayPalResponse = HyperwalletTestHelper
    .getDataFromJson("TransferMethodUpdateConfigurationFieldsPaypalResponse")
    private lazy var transferMethodConfigurationFieldsVenmoResponse = HyperwalletTestHelper
    .getDataFromJson("TransferMethodUpdateConfigurationFieldsVenmoResponse")
    private lazy var transferMethodConfigurationFieldsPaperCheckResponse = HyperwalletTestHelper
    .getDataFromJson("TransferMethodUpdateConfigurationFieldsPaperCheckResponse")
    private lazy var transferMethodConfigurationFieldsWireAccountResponse = HyperwalletTestHelper
    .getDataFromJson("TransferMethodUpdateConfigurationFieldsWireAccountResponse")
    private var hyperwalletInsightsMock = HyperwalletInsightsMock()
    private var inputHandler: () -> Void = {}
    private let transferMethodToken = "trm-0001"

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = UpdateTransferMethodPresenter(mockView, transferMethodToken, hyperwalletInsightsMock)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
        hyperwalletInsightsMock.resetStates()
    }

    public func testLoadUpdateTransferMethodConfigurationFields_success() {
        HyperwalletTestHelper.setUpMockServer(request:
            self.setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsResponse))

        let expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertEqual(mockView.fieldGroups.count, 1, "The `response.getFields()` should be 1")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    public func testLoadUpdateTransferMethodConfigurationFields_failure() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request:
            setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsResponse,
                                                   NSError(domain: "", code: -1009, userInfo: nil)))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectations = [mockView.expectation: expectation]

        // When
        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showError should not be performed")
    }

    func testUpdateTransferMethod_bankAccount() {
        HyperwalletTestHelper.setUpMockServer(request:
            setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsBankAccountResponse))
        let url = String(format: "%@/bank-accounts/%@", HyperwalletTestHelper.userRestURL, transferMethodToken)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "BankAccountIndividualUpdateResponse")
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Update fields in the form
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountId", value: "000"))
        mockView.mockFieldValuesReturnResult.append((name: "branchId", value: "123"))
        mockView.mockFieldStatusReturnResult.append(true)

        // press done button
        expectation = self.expectation(description: "Update bank account completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.updateTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick,
                      "HyperwalletInsights.trackClick should be called")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    func testUpdateTransferMethod_bankCard() {
        HyperwalletTestHelper.setUpMockServer(request:
            setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsResponse))
        let url = String(format: "%@/bank-cards/%@", HyperwalletTestHelper.userRestURL, transferMethodToken)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "BankCardUpdateResponse")
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Update fields in the form
        mockView.mockFieldValuesReturnResult.append((name: "cardNumber", value: "1111111111111111"))
        mockView.mockFieldValuesReturnResult.append((name: "dateOfExpiry", value: "2050-12"))
        mockView.mockFieldValuesReturnResult.append((name: "cvv", value: "123"))
        // press done button
        expectation = self.expectation(description: "Update bank account completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.updateTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick,
                      "HyperwalletInsights.trackClick should be called")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    func testUpdateTransferMethod_payPal() {
        HyperwalletTestHelper.setUpMockServer(request:
            setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsPayPalResponse))
        let url = String(format: "%@/paypal-accounts/%@", HyperwalletTestHelper.userRestURL, transferMethodToken)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "PayPalUpdateResponse")
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Update fields in the form
        mockView.mockFieldValuesReturnResult.append((name: "email", value: "hello1@hw.com"))
        mockView.mockFieldStatusReturnResult.append(true)
        // press done button
        expectation = self.expectation(description: "Update payPal completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.updateTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick,
                      "HyperwalletInsights.trackClick should be called")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    func testUpdateTransferMethod_paperCheck() {
        HyperwalletTestHelper.setUpMockServer(request:
            setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsPaperCheckResponse))
        let url = String(format: "%@/paper-checks/%@", HyperwalletTestHelper.userRestURL, transferMethodToken)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "PaperCheckUpdateResponse")
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Update fields in the form
        mockView.mockFieldValuesReturnResult.append((name: "postalCode", value: "43210"))
        mockView.mockFieldValuesReturnResult.append((name: "shippingMethod", value: "EXPEDITED"))
        mockView.mockFieldStatusReturnResult.append(true)
        // press done button
        expectation = self.expectation(description: "Update paper check completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.updateTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick,
                      "HyperwalletInsights.trackClick should be called")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    func testUpdateTransferMethod_venmo() {
        HyperwalletTestHelper.setUpMockServer(request:
            setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsVenmoResponse))
        let url = String(format: "%@/venmo-accounts/%@", HyperwalletTestHelper.userRestURL, transferMethodToken)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "VenmoUpdateResponse")
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Update fields in the form
        mockView.mockFieldValuesReturnResult.append((name: "accountId", value: "9876543210"))
        mockView.mockFieldStatusReturnResult.append(true)
        // press done button
        expectation = self.expectation(description: "Update venmo completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.updateTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick,
                      "HyperwalletInsights.trackClick should be called")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    func testUpdateTransferMethod_wireAccount() {
        HyperwalletTestHelper.setUpMockServer(request:
            setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsWireAccountResponse))
        let url = String(format: "%@/bank-accounts/%@", HyperwalletTestHelper.userRestURL, transferMethodToken)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "WireAccountUpdateResponse")
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Update fields in the form
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountId", value: "675825207"))
        mockView.mockFieldValuesReturnResult.append((name: "bankId", value: "ACMTCAMM"))
        mockView.mockFieldValuesReturnResult.append((name: "firstName", value: "Wire iOS"))
        mockView.mockFieldStatusReturnResult.append(true)
        // press done button
        expectation = self.expectation(description: "Update wire account completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.updateTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick,
                      "HyperwalletInsights.trackClick should be called")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    func testUpdateTransferMethod_failure_unexpectedError() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request:
        setupTransferMethodConfigurationFields(transferMethodConfigurationFieldsBankAccountResponse))
        let url = String(format: "%@/bank-accounts/%@", HyperwalletTestHelper.userRestURL, transferMethodToken)
        let response = HyperwalletTestHelper
            .unexpectedErrorHTTPResponse(for: "UnexpectedErrorResponse")
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        expectation = self.expectation(description: "Update bank account failed")
        mockView.expectations = [mockView.expectation: expectation]

        // When
        presenter.updateTransferMethod()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertTrue(mockView.isFieldValuesPerformed, "The FieldValues should be performed")
        XCTAssertTrue(mockView.areAllFieldsValidPerformed, "All fields validation should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showConfirmation should not be performed")
        XCTAssertFalse(mockView.isNotificationSent, "The notification should not be sent")
    }

    func testUpdateTransferMethod_failure_businessErrorWithMissingField() {
        // Given
        setupBadResponseMockServer(for: "BankAccountErrorResponseWithMissingField")
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountId", value: "000"))
        mockView.mockFieldStatusReturnResult.append(true)

        let updateFooterContentExpectation = self.expectation(description: "Update bank account failed")
        mockView.expectations = [mockView.updateFooterContentExpectation: updateFooterContentExpectation]

        // When
        presenter.updateTransferMethod()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertTrue(mockView.isFieldValuesPerformed, "The FieldValues should be performed")
        XCTAssertTrue(mockView.areAllFieldsValidPerformed, "All fields validation should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isDisplayErrorMessageInFooterPerformed,
                      "The displayErrorMessageInFooter should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showConfirmation should not be performed")
        XCTAssertFalse(mockView.isNotificationSent, "The notification should not be sent")

        XCTAssertTrue(hyperwalletInsightsMock.didTrackError,
                      "HyperwalletInsights.trackError should be called")
    }

    private func setupTransferMethodConfigurationFields(_ payload: Data, _ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: payload,
                                                                 error: error)
        return HyperwalletTestHelper.buildPostRequest(baseUrl: HyperwalletTestHelper.graphQlURL, response)
    }

    private func setupBadResponseMockServer(for responseFileName: String) {
        let url = String(format: "%@/bank-accounts/%@", HyperwalletTestHelper.userRestURL, transferMethodToken)
        let response = HyperwalletTestHelper
            .badRequestHTTPResponse(for: responseFileName)
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        Hippolyte.shared.add(stubbedRequest: setupTransferMethodConfigurationFields(
            transferMethodConfigurationFieldsBankAccountResponse))
        HyperwalletTestHelper.setUpMockServer(request: request)
        let expectation = self.expectation(description: "HTTP bad response")
        mockView.expectations = [mockView.expectation: expectation]
        mockView.showTransferMethodFieldsHandler = { fieldGroups in
            for fieldGroup in fieldGroups {
                guard let fields = fieldGroup.fields, let fieldGroup = fieldGroup.group
                    else {
                        continue
                }
                let newWidgets = fields.map({
                    WidgetFactory.newWidget(field: $0,
                                            pageName: UpdateTransferMethodPresenter.updateTransferMethodPageName,
                                            pageGroup: UpdateTransferMethodPresenter.updateTransferMethodPageGroup,
                                            inputHandler: self.inputHandler)})
                let section = UpdateTransferMethodSectionData(
                    fieldGroup: fieldGroup,
                    country: "US",
                    currency: "USD",
                    cells: newWidgets
                )
                self.presenter.sectionData.append(section)
            }
        }
        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)
    }
}

class UpdateTransferMethodViewMock: UpdateTransferMethodView {
    let expectation: String = "expectation"
    let updateFooterContentExpectation: String = "updateFooterContentExpectation"

    var isUpdateFooterPerformed = false
    var isHideLoadingPerformed = false
    var isShowLoadingPerformed = false
    var isShowProcessingPerformed = false
    var isShowConfirmationPerformed = false
    var isDismissProcessingPerformed = false
    var isFieldFocusPerformed = false
    var fieldFocusField = ""
    var isShowTransferMethodFieldsPerformed = false
    var fieldGroups = [HyperwalletFieldGroup]()
    var isShowErrorPerformed = false
    var isNotificationSent = false
    var isDisplayErrorMessageInFooterPerformed = false
    var isFieldStatusPerformed = false
    var isFieldValuesPerformed = false
    var isTransferMethodSupported = false
    var areAllFieldsValidPerformed = false

    var mockFieldStatusReturnResult = [Bool]()
    var mockFieldValuesReturnResult = [(name: String, value: String)]()
    var showTransferMethodFieldsHandler: (([HyperwalletFieldGroup]) -> Void)?

    var expectations: [String: XCTestExpectation]?

    func resetStates() {
        isUpdateFooterPerformed = false
        isHideLoadingPerformed = false
        isShowLoadingPerformed = false
        isShowProcessingPerformed = false
        isShowConfirmationPerformed = false
        isDismissProcessingPerformed = false
        isFieldFocusPerformed = false
        fieldFocusField = ""
        isShowTransferMethodFieldsPerformed = false
        fieldGroups = [HyperwalletFieldGroup]()
        isShowErrorPerformed = false
        isNotificationSent = false
        isDisplayErrorMessageInFooterPerformed = false
        isFieldStatusPerformed = false
        isFieldValuesPerformed = false
        isTransferMethodSupported = false
        areAllFieldsValidPerformed = false

        mockFieldStatusReturnResult = [Bool]()
        mockFieldValuesReturnResult = [(name: String, value: String)]()
        showTransferMethodFieldsHandler = nil
        expectations = nil
    }

    func fieldStatus() -> [Bool] {
        isFieldStatusPerformed = true
        return mockFieldStatusReturnResult
    }

    func fieldValues() -> [(name: String, value: String)] {
        isFieldValuesPerformed = true
        return mockFieldValuesReturnResult
    }

    func areAllUpdatedFieldsValid() -> Bool {
        areAllFieldsValidPerformed = true
        return mockFieldStatusReturnResult.contains(false) ? false : true
    }

    func updateFooter(for section: Int, description: String?, errorMessage: String?) {
        isUpdateFooterPerformed = true
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

    func showConfirmation(handler: @escaping () -> Void) {
        isShowConfirmationPerformed = true
        handler()
    }

    func dismissProcessing(handler: @escaping () -> Void) {
        isDismissProcessingPerformed = true
        handler()
    }

    func fieldFocus(fieldName: String) {
        isFieldFocusPerformed = true
        fieldFocusField = fieldName
    }

    func showError(title: String, message: String) {
        isTransferMethodSupported = true
    }

    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry?()
        expectations?[expectation]?.fulfill()
    }

    func notifyTransferMethodUpdated(_ transferMethod: HyperwalletTransferMethod) {
        isNotificationSent = true
        expectations?[expectation]?.fulfill()
    }

    func reloadData(_ fieldGroups: [HyperwalletFieldGroup]) {
        self.fieldGroups = fieldGroups
        isShowTransferMethodFieldsPerformed = true
        showTransferMethodFieldsHandler?(fieldGroups)
        expectations?[expectation]?.fulfill()
    }

    func showFooterViewWithUpdatedSectionData(for sections: [UpdateTransferMethodSectionData]) {
        isDisplayErrorMessageInFooterPerformed = true
        expectations?[updateFooterContentExpectation]?.fulfill()
    }
}
