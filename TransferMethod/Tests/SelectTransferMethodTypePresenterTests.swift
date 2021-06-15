#if !COCOAPODS
import Common
#endif
import Hippolyte
import HyperwalletSDK
@testable import TransferMethod
import XCTest

class SelectTransferMethodTypePresenterTests: XCTestCase {
    private var presenter: SelectTransferMethodTypePresenter!
    private let mockView = SelectTransferMethodTypeViewMock()
    private lazy var mockResponseData = HyperwalletTestHelper.getDataFromJson("TransferMethodConfigurationKeysResponse")
    private lazy var userMockResponseData = HyperwalletTestHelper.getDataFromJson("UserIndividualResponse")
    private var hyperwalletInsightsMock = HyperwalletInsightsMock()
    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = SelectTransferMethodTypePresenter(mockView, hyperwalletInsightsMock)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
        hyperwalletInsightsMock.resetStates()
    }

    func testLoadTransferMethodKeys_success() {
        // Given
        addGetIndividualHyperwalletUserResponse()
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertFalse(mockView.isShowAlertPerformed, "The showAlert should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")

        XCTAssertTrue(!presenter.selectedCountry.isEmpty, "A country should be selected by default")
        XCTAssertTrue(!presenter.selectedCurrency.isEmpty, "A currency should be selected by default")
        XCTAssertTrue(mockView.isCountryCurrencyTableViewReloadDataPerformed,
                      "The countryCurrencyTableViewReloadData should be performed")
        XCTAssertTrue(mockView.isTransferMethodTypeTableViewReloadDataPerformed,
                      "The transferMethodTypeTableViewReloadData should be performed")

        XCTAssertNotNil(HyperwalletInsights.shared, "HyperwalletInsights should be initialized")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackImpression,
                      "HyperwalletInsights.trackImpression should be called")
    }

    func testLoadTransferMethodKeys_getUserWithoutCountry() {
        // Given
        addGetHyperwalletUserResponse(fileName: "UserIndividualResponseWithoutCountry")
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertFalse(mockView.isShowAlertPerformed, "The showAlert should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")

        XCTAssertTrue(!presenter.selectedCountry.isEmpty, "A country should be selected by default")
        XCTAssertTrue(!presenter.selectedCurrency.isEmpty, "A currency should be selected by default")
        XCTAssertEqual(presenter.selectedCountry, "CA", "The selectedCountry should be CA")
    }

    func testLoadTransferMethodKeys_returnsNoCountry() {
        // Given
        addGetIndividualHyperwalletUserResponse()

        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys(
            fileName: "TransferMethodConfigurationKeysEmptyCountriesResponse"))

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isShowAlertPerformed, "The showAlert should not be performed")

        XCTAssertEqual(mockView.alertMessages[0], "There is no country available")
    }

    func testLoadTransferMethodKeys_returnsNoCurrencies() {
        // Given
        addGetIndividualHyperwalletUserResponse()

        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys(
            fileName: "TransferMethodConfigurationKeysEmptyCurrenciesResponse"))

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isShowAlertPerformed, "The showAlert should not be performed")

        XCTAssertEqual(mockView.alertMessages[0], "There is no currency available for country US")
    }

    func testLoadTransferMethodKeys_returnsNoTransferMethodTypes() {
        // Given
        addGetIndividualHyperwalletUserResponse()

        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys(
            fileName: "TransferMethodConfigurationKeysEmptyTransferMethodTypesResponse"))

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")
        XCTAssertTrue(mockView.isShowAlertPerformed, "The showAlert should be performed")

        XCTAssertEqual(mockView.alertMessages[0], "There is no transfer method available for US and USD")
    }

    func testLoadTransferMethodKeys_failureWithError() {
        // Given
        addGetIndividualHyperwalletUserResponse()
        HyperwalletTestHelper.setUpMockServer(request:
            setUpTransferMethodConfigurationKeys(NSError(domain: "", code: -1009, userInfo: nil)))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isCountryCurrencyTableViewReloadDataPerformed,
                       "The countryCurrencyTableViewReloadData should not be performed")
        XCTAssertFalse(mockView.isTransferMethodTypeTableViewReloadDataPerformed,
                       "The transferMethodTypeTableViewReloadData should not be performed")
    }

    func testLoadTransferMethodKeys_getUserRequestFail() {
        // Given
        addGetIndividualHyperwalletUserResponse(NSError(domain: "", code: -1009, userInfo: nil))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "The showError should be performed")
        XCTAssertFalse(mockView.isCountryCurrencyTableViewReloadDataPerformed,
                       "The countryCurrencyTableViewReloadData should not be performed")
        XCTAssertFalse(mockView.isTransferMethodTypeTableViewReloadDataPerformed,
                       "The transferMethodTypeTableViewReloadData should not be performed")
    }

    func testNavigateToAddTransferMethod_success() {
        let indexPath = IndexPath(row: 0, section: 0)
        // Given
        addGetIndividualHyperwalletUserResponse()
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)

        // When
        presenter.navigateToAddTransferMethod(0)

        // Then
        XCTAssertEqual(presenter.selectedCountry, "US", "The country should be US")
        XCTAssertEqual(presenter.selectedCurrency, "CAD", "The currency should be CAD")
        XCTAssertTrue(mockView.isNavigateToAddTransferMethodControllerPerformed,
                      "The navigateToAddTransferMethodControllerPerformed should be performed")

        XCTAssertEqual(mockView.profileType, "INDIVIDUAL", "The profileType should be INDIVIDUAL")
        XCTAssertEqual(presenter.countryCurrencySectionData.count, 2, "The countryCurrencyCount should be 2")
        XCTAssertEqual(presenter.sectionData.count, 1, "The transferMethodTypesCount should be 1")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick, "HyperwalletInsights.trackClick should be called")
        XCTAssertNotNil(presenter.getCountryCurrencyConfiguration(indexPath: indexPath),
                        "The country currency cell configuration should not be nil")
    }

    func testTrackCountryClick_success() {
        let countryIndex = 0
        addGetIndividualHyperwalletUserResponse()
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())
        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)
        mockView.ignoreXCTestExpectation = true
        presenter.performShowSelectCountryOrCurrencyView(index: countryIndex)
        XCTAssertTrue(mockView.isShowGenericTableViewPerformed, "Show Generic Table View should be performed")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick, "HyperwalletInsights.trackClick should be called")
    }

    func testTrackCurrencyClick_success() {
        let currencyIndex = 1
        addGetIndividualHyperwalletUserResponse()
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())
        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation
        presenter.loadTransferMethodKeys(true)
        wait(for: [expectation], timeout: 1)
        mockView.ignoreXCTestExpectation = true
        presenter.performShowSelectCountryOrCurrencyView(index: currencyIndex)
        XCTAssertTrue(mockView.isShowGenericTableViewPerformed, "Show Generic Table View should be performed")
        XCTAssertTrue(hyperwalletInsightsMock.didTrackClick, "HyperwalletInsights.trackClick should be called")
       }

    private func loadTransferMethodKeys() {
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        presenter.loadTransferMethodKeys()
        wait(for: [expectation], timeout: 1)
    }

    private func setUpTransferMethodConfigurationKeys(_ error: NSError? = nil) -> StubRequest {
        return setUpTransferMethodConfigurationKeys(payload: mockResponseData, error)
    }

    private func setUpTransferMethodConfigurationKeys(fileName: String) -> StubRequest {
        let responseData = HyperwalletTestHelper.getDataFromJson(fileName)
        return setUpTransferMethodConfigurationKeys(payload: responseData, nil)
    }

    private func setUpTransferMethodConfigurationKeys(payload: Data, _ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: payload, error: error)
        return HyperwalletTestHelper.buildPostRequest(baseUrl: HyperwalletTestHelper.graphQlURL, response)
    }

    private func addGetIndividualHyperwalletUserResponse(_ error: NSError? = nil) {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: userMockResponseData, error: error)
        let request = HyperwalletTestHelper.buildGetRequest(baseUrl: HyperwalletTestHelper.userRestURL, response)
        Hippolyte.shared.add(stubbedRequest: request)
    }

    private func addGetHyperwalletUserResponse(fileName: String) {
        let response = HyperwalletTestHelper.okHTTPResponse(for: fileName)
        let request = HyperwalletTestHelper.buildGetRequest(baseUrl: HyperwalletTestHelper.userRestURL, response)
        Hippolyte.shared.add(stubbedRequest: request)
    }
}

class SelectTransferMethodTypeViewMock: SelectTransferMethodTypeView {
    var isHideLoadingPerformed = false
    var isShowLoadingPerformed = false
    var isShowGenericTableViewPerformed = false
    var isShowSelectCurrencyTablePerformed = false
    var isNavigateToAddTransferMethodControllerPerformed = false
    var isShowAlertPerformed = false
    var isShowErrorPerformed = false
    var isTransferMethodTypeTableViewReloadDataPerformed = false
    var isCountryCurrencyTableViewReloadDataPerformed = false
    var ignoreXCTestExpectation = false
    var alertMessages = [String]()
    var profileType: String?

    var expectation: XCTestExpectation?

    func resetStates() {
        isHideLoadingPerformed = false
        isShowLoadingPerformed = false
        isShowGenericTableViewPerformed = false
        isNavigateToAddTransferMethodControllerPerformed = false
        isShowAlertPerformed = false
        isShowErrorPerformed = false
        isTransferMethodTypeTableViewReloadDataPerformed = false
        isCountryCurrencyTableViewReloadDataPerformed = false
        ignoreXCTestExpectation = false
        alertMessages = [String]()
        profileType = nil

        expectation = nil
    }

    func showGenericTableView(items: [GenericCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping SelectItemHandler,
                              markCellHandler: @escaping MarkCellHandler,
                              filterContentHandler: @escaping FilterContentHandler) {
        if title == "mobileCountryRegion".localized() {
            let country = CountryCurrencyCellConfiguration(title: "United States", value: "US")
            selectItemHandler(country)
            _ = markCellHandler(country)
            _ = filterContentHandler(items, "")
        }

        if title == "mobileCurrencyLabel".localized() {
            let currency = CountryCurrencyCellConfiguration(title: "US Dollar", value: "USD")
            selectItemHandler(currency)
            _ = markCellHandler(currency)
            _ = filterContentHandler(items, "")
        }

        isShowGenericTableViewPerformed = true
    }

    func navigateToAddTransferMethodController(country: String,
                                               currency: String,
                                               profileType: String,
                                               transferMethodTypeCode: String) {
        isNavigateToAddTransferMethodControllerPerformed = true
        self.profileType = profileType
    }

    func showAlert(message: String?) {
        isShowAlertPerformed = true
        if let alertMessage = message {
            alertMessages.append(alertMessage)
        }
    }

    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry?()
    }

    func showLoading() {
         isShowLoadingPerformed = true
    }

    func hideLoading() {
        isHideLoadingPerformed = true

        if !ignoreXCTestExpectation {
            expectation?.fulfill()
        }
    }

    func reloadTransferMethodTypeData() {
        isTransferMethodTypeTableViewReloadDataPerformed = true
    }

    func reloadCountryCurrencyData() {
        isCountryCurrencyTableViewReloadDataPerformed = true
    }
}
