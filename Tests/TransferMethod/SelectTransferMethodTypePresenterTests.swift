import Hippolyte
import HyperwalletSDK
@testable import HyperwalletUISDK
import XCTest

class SelectTransferMethodTypePresenterTests: XCTestCase {
    private var presenter: SelectTransferMethodTypePresenter!
    private let mockView = MockSelectTransferMethodTypeView()
    private lazy var mockResponseData = HyperwalletTestHelper.getDataFromJson("TransferMethodConfigurationKeysResponse")
    private lazy var userMockResponseData = HyperwalletTestHelper.getDataFromJson("UserIndividualResponse")
    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        presenter = SelectTransferMethodTypePresenter(view: mockView)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
    }

    func testLoadTransferMethodKeys_success() {
        // Given
        setUpGetIndividualHyperwalletUser()
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys()
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertFalse(mockView.isShowErrorPerformed, "The showError should not be performed")
        XCTAssertTrue(mockView.isShowLoadingPerformed, "The showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "The hideLoading should be performed")

        XCTAssertTrue(!presenter.selectedCountry.isEmpty, "A country should be selected by default")
        XCTAssertTrue(!presenter.selectedCurrency.isEmpty, "A currency should be selected by default")

        XCTAssertTrue(mockView.isCountryCurrencyTableViewReloadDataPerformed,
                      "The countryCurrencyTableViewReloadData should be performed")
        XCTAssertTrue(mockView.isTransferMethodTypeTableViewReloadDataPerformed,
                      "The transferMethodTypeTableViewReloadData should be performed")
    }

    func testLoadTransferMethodKeys_failureWithError() {
        // Given
        setUpGetIndividualHyperwalletUser()
        HyperwalletTestHelper.setUpMockServer(request:
            setUpTransferMethodConfigurationKeys(NSError(domain: "", code: -1009, userInfo: nil)))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys()
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
        setUpGetIndividualHyperwalletUser(NSError(domain: "", code: -1009, userInfo: nil))

        let expectation = self.expectation(description: "load transfer methods")
        mockView.expectation = expectation

        // When
        presenter.loadTransferMethodKeys()
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
        // Given
        setUpGetBusinessHyperwalletUser()
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())

        let countryIndex = 0
        let currencyIndex = 1
        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        presenter.loadTransferMethodKeys()
        wait(for: [expectation], timeout: 1)

        presenter.performShowSelectCountryOrCurrencyView(index: countryIndex)

        presenter.performShowSelectCountryOrCurrencyView(index: currencyIndex)

        // When
        presenter.navigateToAddTransferMethod(0)

        // Then
        XCTAssertEqual(presenter.selectedCountry, "US", "The country should be US")
        XCTAssertEqual(presenter.selectedCurrency, "USD", "The currency should be USD")
        XCTAssertTrue(mockView.isNavigateToAddTransferMethodControllerPerformed,
                      "The navigateToAddTransferMethodControllerPerformed should be performed")

        XCTAssertEqual(presenter.countryCurrencyCount, 2, "The countryCurrencyCount should be 2")
        XCTAssertEqual(presenter.transferMethodTypesCount, 1, "The transferMethodTypesCount should be 1")
        XCTAssertNotNil(presenter.getCellConfiguration(for: 0), "The getCellConfiguration should not be nil")
        XCTAssertNotNil(presenter.getCountryCurrencyCellConfiguration(for: 0),
                        "The getCellConfiguration should not be nil")
    }

    private func loadTransferMethodKeys() {
        HyperwalletTestHelper.setUpMockServer(request: setUpTransferMethodConfigurationKeys())

        let expectation = self.expectation(description: "load transfer methods keys")
        mockView.expectation = expectation

        presenter.loadTransferMethodKeys()
        wait(for: [expectation], timeout: 1)
    }

    private func setUpTransferMethodConfigurationKeys(_ error: NSError? = nil) -> StubRequest {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: mockResponseData, error: error)
        return HyperwalletTestHelper.buildPostResquest(baseUrl: HyperwalletTestHelper.graphQlURL, response)
    }

    private func setUpGetIndividualHyperwalletUser(_ error: NSError? = nil) {
        let response = HyperwalletTestHelper.setUpMockedResponse(payload: userMockResponseData, error: error)
        let request = HyperwalletTestHelper.buildGetRequest(baseUrl: HyperwalletTestHelper.userRestURL, response)
        Hippolyte.shared.add(stubbedRequest: request)
    }

    private func setUpGetBusinessHyperwalletUser() {
        let response = HyperwalletTestHelper.okHTTPResponse(for: "UserBusinessResponse")
        let request = HyperwalletTestHelper.buildGetRequest(baseUrl: HyperwalletTestHelper.userRestURL, response)
        Hippolyte.shared.add(stubbedRequest: request)
    }
}

class MockSelectTransferMethodTypeView: SelectTransferMethodTypeView {
    var isHideLoadingPerformed = false
    var isShowLoadingPerformed = false
    var isShowGenericTableViewPerformed = false
    var isShowSelectCurrencyTablePerformed = false
    var isNavigateToAddTransferMethodControllerPerformed = false
    var isShowAlertPerformed = false
    var isShowErrorPerformed = false
    var isTransferMethodTypeTableViewReloadDataPerformed = false
    var isCountryCurrencyTableViewReloadDataPerformed = false

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

        expectation = nil
    }

    func showGenericTableView(items: [CountryCurrencyCellConfiguration],
                              title: String,
                              selectItemHandler: @escaping (CountryCurrencyCellConfiguration) -> Void,
                              markCellHandler: @escaping (CountryCurrencyCellConfiguration) -> Bool,
                              filterContentHandler: @escaping (([CountryCurrencyCellConfiguration], String)
                                                                -> [CountryCurrencyCellConfiguration])) {
        if title == "Select Country" {
            let country = CountryCurrencyCellConfiguration(title: "United States", value: "US")
            selectItemHandler(country)
            _ = markCellHandler(country)
            _ = filterContentHandler(items, "")
        }

        if title == "Select Currency" {
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
                                               detail: TransferMethodTypeDetail) {
        isNavigateToAddTransferMethodControllerPerformed = true
    }

    func showAlert(message: String?) {
        isShowAlertPerformed = true
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry?()
    }

    func showLoading() {
         isShowLoadingPerformed = true
    }

    func hideLoading() {
        isHideLoadingPerformed = true
        expectation?.fulfill()
    }

    func transferMethodTypeTableViewReloadData() {
        isTransferMethodTypeTableViewReloadDataPerformed = true
    }

    func countryCurrencyTableViewReloadData() {
        isCountryCurrencyTableViewReloadDataPerformed = true
    }
}
