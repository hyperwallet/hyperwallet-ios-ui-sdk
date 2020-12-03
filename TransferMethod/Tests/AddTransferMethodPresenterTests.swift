#if !COCOAPODS
import Common
#endif
import Hippolyte
import HyperwalletSDK
@testable import TransferMethod
import XCTest

class AddTransferMethodPresenterTests: XCTestCase {
    private var presenter: AddTransferMethodPresenter!
    private let mockView = AddTransferMethodViewMock()
    private lazy var transferMethodConfigurationFieldsResponse = HyperwalletTestHelper
        .getDataFromJson("TransferMethodConfigurationFieldsResponse")
    private var hyperwalletInsightsMock = HyperwalletInsightsMock()
    private var inputHandler: () -> Void = {}

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = AddTransferMethodPresenter(mockView,
                                               "US",
                                               "USD",
                                               "INDIVIDUAL",
                                               HyperwalletTransferMethod.TransferMethodType.bankAccount.rawValue,
                                               hyperwalletInsightsMock)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
        hyperwalletInsightsMock.resetStates()
    }

    public func testLoadTransferMethodConfigurationFields_success() {
        HyperwalletTestHelper.setUpMockServer(request: setupTransferMethodConfigurationFields())

        let expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodConfigurationFields(true)

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertEqual(mockView.fieldGroups.count, 2, "The `response.getFields()` should be 2")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    public func testLoadTransferMethodConfigurationFields_failure() {
        // Given
        HyperwalletTestHelper.setUpMockServer(request:
            setupTransferMethodConfigurationFields(NSError(domain: "", code: -1009, userInfo: nil)))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectations = [mockView.expectation: expectation]

        // When
        presenter.loadTransferMethodConfigurationFields(true)
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showError should not be performed")
    }

    func testCreateTransferMethod_createBankAccount() {
        presenter = AddTransferMethodPresenter(mockView,
                                               "US",
                                               "USD",
                                               "INDIVIDUAL",
                                               HyperwalletTransferMethod.TransferMethodType.bankAccount.rawValue,
                                               hyperwalletInsightsMock)
        let url = String(format: "%@/bank-accounts", HyperwalletTestHelper.userRestURL)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "BankAccountIndividualResponse")
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        // Add fields to the form
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountId", value: "000"))
        mockView.mockFieldValuesReturnResult.append((name: "branchId", value: "123"))
        mockView.mockFieldStatusReturnResult.append(true)

        // press the create transfer method button
        let expectation = self.expectation(description: "Create bank account completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.createTransferMethod()

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

    func testCreateTransferMethod_createWireAccount() {
        presenter = AddTransferMethodPresenter(mockView,
                                               "US",
                                               "USD",
                                               "INDIVIDUAL",
                                               "WIRE_ACCOUNT",
                                               hyperwalletInsightsMock)
        let url = String(format: "%@/bank-accounts", HyperwalletTestHelper.userRestURL)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "WireAccountIndividualResponse")
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        // Add fields to the form
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountId", value: "675825207"))
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountPurpose", value: "CHECKING"))
        mockView.mockFieldValuesReturnResult.append((name: "branchId", value: "026009593"))
        mockView.mockFieldStatusReturnResult.append(true)

        // press the create transfer method button
        let expectation = self.expectation(description: "Create wire account completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.createTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
    }

    func testCreateTransferMethod_createBankCard() {
        presenter = AddTransferMethodPresenter(mockView,
                                               "US",
                                               "USD",
                                               "INDIVIDUAL",
                                               "BANK_CARD",
                                               hyperwalletInsightsMock)

        let url = String(format: "%@/bank-cards", HyperwalletTestHelper.userRestURL)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "BankCardResponse")
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        // Add fields to the form
        mockView.mockFieldValuesReturnResult.append((name: "cardNumber", value: "1111111111111111"))
        mockView.mockFieldValuesReturnResult.append((name: "dateOfExpiry", value: "2050-12"))
        mockView.mockFieldValuesReturnResult.append((name: "cvv", value: "123"))

        // press the create transfer method button
        let expectation = self.expectation(description: "Create bank card completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.createTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertTrue(mockView.isFieldValuesPerformed, "The FieldValues should be performed")
        XCTAssertTrue(mockView.areAllFieldsValidPerformed, "All fields validation should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
    }

    func testCreateTransferMethod_createPayPalAccount() {
        presenter = AddTransferMethodPresenter(mockView,
                                               "US",
                                               "USD",
                                               "INDIVIDUAL",
                                               "PAYPAL_ACCOUNT",
                                               hyperwalletInsightsMock)
        let url = String(format: "%@/paypal-accounts", HyperwalletTestHelper.userRestURL)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "PayPalAccountResponse")
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        // Add fields to the form
        mockView.mockFieldValuesReturnResult.append((name: "email", value: "carroll.lynn@byteme.com"))
        mockView.mockFieldStatusReturnResult.append(true)

        // press the create transfer method button
        let expectation = self.expectation(description: "Create PayPal account completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.createTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
    }

    func testCreateTransferMethod_createVenmoAccount() {
        presenter = AddTransferMethodPresenter(mockView,
                                               "US",
                                               "USD",
                                               "INDIVIDUAL",
                                               HyperwalletTransferMethod.TransferMethodType.venmoAccount.rawValue,
                                               hyperwalletInsightsMock)
        let url = String(format: "%@/venmo-accounts", HyperwalletTestHelper.userRestURL)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "VenmoAccountResponse")
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        // Add fields to the form
        mockView.mockFieldValuesReturnResult.append((name: "accountId", value: "9876543210"))
        mockView.mockFieldStatusReturnResult.append(true)

        // press the create transfer method button
        let expectation = self.expectation(description: "Create Venmo account completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.createTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
    }

    func testCreateTransferMethod_createPaperCheck() {
        presenter = AddTransferMethodPresenter(mockView,
                                               "US",
                                               "USD",
                                               "INDIVIDUAL",
                                               HyperwalletTransferMethod.TransferMethodType.paperCheck.rawValue,
                                               hyperwalletInsightsMock)
        let url = String(format: "%@/paper-checks", HyperwalletTestHelper.userRestURL)
        let response = HyperwalletTestHelper.okHTTPResponse(for: "PapercheckAccountResponse")
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        // Add fields to the form
        mockView.mockFieldValuesReturnResult.append((name: "postalCode", value: "43210"))
        mockView.mockFieldStatusReturnResult.append(true)

        // press the create transfer method button
        let expectation = self.expectation(description: "Create PaperCheck account completed")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.createTransferMethod()

        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowConfirmationPerformed, "The showConfirmation should be performed")
        XCTAssertTrue(mockView.isNotificationSent, "The notification should be sent")
    }

    func testCreateTransferMethod_failure_businessErrorWithValidationError() {
        // Given
        setupBadResponseMockServer(for: "BankAccountErrorResponseWithValidationError")
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountId", value: "000"))
        mockView.mockFieldStatusReturnResult.append(true)

        let showErrorExpectation = self.expectation(description: "Create bank account failed")
        let updateFooterContentExpectation = self.expectation(description: "Create bank account failed")
        mockView.expectations = [
            mockView.expectation: showErrorExpectation,
            mockView.updateFooterContentExpectation: updateFooterContentExpectation
        ]

        // When
        presenter.createTransferMethod()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertTrue(mockView.isFieldValuesPerformed, "The FieldValues should be performed")
        XCTAssertTrue(mockView.areAllFieldsValidPerformed, "All fields validation should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showConfirmation should not be performed")
        XCTAssertFalse(mockView.isNotificationSent, "The notification should not be sent")
    }

    func testCreateTransferMethod_failure_businessErrorWithMissingField() {
        // Given
        setupBadResponseMockServer(for: "BankAccountErrorResponseWithMissingField")
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountId", value: "000"))
        mockView.mockFieldStatusReturnResult.append(true)

        let updateFooterContentExpectation = self.expectation(description: "Create bank account failed")
        mockView.expectations = [mockView.updateFooterContentExpectation: updateFooterContentExpectation]

        // When
        presenter.createTransferMethod()
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

    func testCreateTransferMethod_failure_unexpectedError() {
        // Given
        let url = String(format: "%@/bank-accounts", HyperwalletTestHelper.userRestURL)
        let response = HyperwalletTestHelper
            .unexpectedErrorHTTPResponse(for: "UnexpectedErrorResponse")
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        let expectation = self.expectation(description: "Create bank account failed")
        mockView.expectations = [mockView.expectation: expectation]

        // When
        presenter.createTransferMethod()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Then
        XCTAssertTrue(mockView.isFieldValuesPerformed, "The FieldValues should be performed")
        XCTAssertTrue(mockView.areAllFieldsValidPerformed, "All fields validation should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showConfirmation should not be performed")
        XCTAssertFalse(mockView.isNotificationSent, "The notification should not be sent")
    }

    func testCreateTransferMethod_inlineFailure() {
        // Given
        mockView.mockFieldStatusReturnResult.append(false)

        // When
        presenter.createTransferMethod()

        // Then
        XCTAssertTrue(mockView.areAllFieldsValidPerformed, "All fields validation should be performed")
        XCTAssertFalse(mockView.isFieldValuesPerformed, "The FieldValues should not be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showConfirmation should not be performed")
        XCTAssertFalse(mockView.isNotificationSent, "The notification should not be sent")
    }

    func testCreateTransferMethod_notSupportedTransferMethodType() {
        // Given
        presenter = AddTransferMethodPresenter(mockView,
                                               "US",
                                               "USD",
                                               "INDIVIDUAL",
                                               "PREPAID_CARD",
                                               hyperwalletInsightsMock)
        mockView.mockFieldStatusReturnResult.append(true)

        // When
        presenter.createTransferMethod()

        // Then
        XCTAssertTrue(mockView.areAllFieldsValidPerformed, "All fields validation should be performed")
        XCTAssertTrue(mockView.isTransferMethodSupported, "Transfer Method is not supported")
        XCTAssertFalse(mockView.isFieldValuesPerformed, "The FieldValues should not be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertFalse(mockView.isShowConfirmationPerformed, "The showConfirmation should not be performed")
        XCTAssertFalse(mockView.isNotificationSent, "The notification should not be sent")
    }

    private func setupTransferMethodConfigurationFields(_ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: transferMethodConfigurationFieldsResponse,
                                                                 error: error)
        return HyperwalletTestHelper.buildPostRequest(baseUrl: HyperwalletTestHelper.graphQlURL, response)
    }

    private func setupBadResponseMockServer(for responseFileName: String) {
        let url = String(format: "%@/bank-accounts", HyperwalletTestHelper.userRestURL)
        let response = HyperwalletTestHelper
            .badRequestHTTPResponse(for: responseFileName)
        let request = HyperwalletTestHelper.buildPostRequest(baseUrl: url, response)
        Hippolyte.shared.add(stubbedRequest: setupTransferMethodConfigurationFields())
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
                                            pageName: AddTransferMethodPresenter.addTransferMethodPageName,
                                            pageGroup: AddTransferMethodPresenter.addTransferMethodPageGroup,
                                            inputHandler: self.inputHandler)})
                let section = AddTransferMethodSectionData(
                    fieldGroup: fieldGroup,
                    country: "US",
                    currency: "USD",
                    cells: newWidgets
                )
                self.presenter.sectionData.append(section)
            }
        }
        presenter.loadTransferMethodConfigurationFields(true)
        wait(for: Array(mockView.expectations!.values), timeout: 1)
    }
}

class AddTransferMethodViewMock: AddTransferMethodView {
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

    func areAllFieldsValid() -> Bool {
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

    func reloadData(_ fieldGroups: [HyperwalletFieldGroup], _ transferMethodType: HyperwalletTransferMethodType) {
        self.fieldGroups = fieldGroups
        isShowTransferMethodFieldsPerformed = true
        showTransferMethodFieldsHandler?(fieldGroups)
        expectations?[expectation]?.fulfill()
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

    func notifyTransferMethodAdded(_ transferMethod: HyperwalletTransferMethod) {
        isNotificationSent = true
        expectations?[expectation]?.fulfill()
    }

    func showFooterViewWithUpdatedSectionData(for sections: [AddTransferMethodSectionData]) {
        isDisplayErrorMessageInFooterPerformed = true
        expectations?[updateFooterContentExpectation]?.fulfill()
    }
}
