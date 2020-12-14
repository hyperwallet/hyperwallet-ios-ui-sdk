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
    private var hyperwalletInsightsMock = HyperwalletInsightsMock()
    private var inputHandler: () -> Void = {}
    private let transferMethodToken = "trm-123456789"

    private lazy var bankCard: HyperwalletBankCard = {
        let bankCard = HyperwalletBankCard.Builder(transferMethodCountry: "US",
                                                   transferMethodCurrency: "USD",
                                                   transferMethodProfileType: "INDIVIDUAL")
            .build()
        bankCard.setField(key: HyperwalletTransferMethod.TransferMethodField.token.rawValue,
                          value: transferMethodToken)
        return bankCard
    }()

    private lazy var bankAccount: HyperwalletBankAccount = {
        let bankCard = HyperwalletBankAccount.Builder(transferMethodCountry: "US",
                                                      transferMethodCurrency: "USD",
                                                      transferMethodProfileType: "INDIVIDUAL",
                                                      transferMethodType: HyperwalletTransferMethod.TransferMethodType
                                                        .bankAccount.rawValue)
            .build()
        bankCard.setField(key: HyperwalletTransferMethod.TransferMethodField.token.rawValue,
                          value: transferMethodToken)
        return bankCard
    }()

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
//        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
//                      "HyperwalletInsights.trackImpression should be called")
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
        let response = HyperwalletTestHelper.okHTTPResponse(for: "BankAccountIndividualUpdateResposne")
        let request = HyperwalletTestHelper.buildPutRequest(baseUrl: url, response)
        HyperwalletTestHelper.setUpMockServer(request: request)

        var expectation = self.expectation(description: "Load transfer method configuration fields")
        mockView.expectations = [mockView.expectation: expectation]

        presenter.loadTransferMethodUpdateConfigurationFields()
        wait(for: Array(mockView.expectations!.values), timeout: 1)

        // Add fields to the form
        mockView.mockFieldValuesReturnResult.append((name: "bankAccountId", value: "000"))
        mockView.mockFieldValuesReturnResult.append((name: "branchId", value: "123"))
        mockView.mockFieldStatusReturnResult.append(true)

        // press the create transfer method button
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

    private func setupTransferMethodConfigurationFields(_ payload: Data, _ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: payload,
                                                                 error: error)
        return HyperwalletTestHelper.buildPostRequest(baseUrl: HyperwalletTestHelper.graphQlURL, response)
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
