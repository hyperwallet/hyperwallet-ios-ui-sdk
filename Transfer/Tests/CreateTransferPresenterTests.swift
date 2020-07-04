#if !COCOAPODS
import Common
import TransferMethodRepository
import UserRepository
#endif
import Hippolyte
import HyperwalletSDK
@testable import Transfer
import XCTest

class CreateTransferTests: XCTestCase {
    private var presenter: CreateTransferPresenter!
    private var mockView = MockCreateTransferView()
    private let clientTransferId = UUID().uuidString
    private let clientSourceToken = "trm-123456789"

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        mockView.resetStates()
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        UserRepositoryFactory.clearInstance()
        TransferMethodRepositoryFactory.clearInstance()
    }

    private enum LoadTransferMethodsResultType {
        case success, failure, noContent
        func setUpRequest() {
            switch self {
            case .success:
                TransferMethodRepositoryRequestHelper.setupSuccessRequest()

            case .failure:
                TransferMethodRepositoryRequestHelper.setupFailureRequest()

            case .noContent:
                TransferMethodRepositoryRequestHelper.setupNoContentRequest()
            }
        }
    }

    private enum CreateTransferResultType {
        case success, failure, noContent
        func setUpRequest() {
            switch self {
            case .success:
                CreateTransferRequestHelper.setupSuccessRequest()

            case .failure:
                CreateTransferRequestHelper.setupFailureRequestWithoutFieldName()

            case .noContent:
                CreateTransferRequestHelper.setupNoContentRequest()
            }
        }
    }

    private enum GetUserResultType {
        case success, failure
        func setUpRequest() {
            switch self {
            case .success:
                UserRepositoryRequestHelper.setupSuccessRequest()

            case .failure:
                UserRepositoryRequestHelper.setupFailureRequest()
            }
        }
    }

    private func initializePresenter(transferMethodResult: LoadTransferMethodsResultType = .success,
                                     createTransferResult: CreateTransferResultType = .success,
                                     getUserResultType: GetUserResultType = .success,
                                     sourceToken: String? = nil) {
        transferMethodResult.setUpRequest()
        createTransferResult.setUpRequest()
        getUserResultType.setUpRequest()

        presenter = CreateTransferPresenter(clientTransferId, sourceToken, view: mockView)
        var expectations = [XCTestExpectation]()

        if mockView.stopOnError {
            expectations.append(mockView.showErrorExpectation)
        } else {
            expectations.append(mockView.loadCreateTransferExpectation)
        }

        presenter.loadCreateTransfer()
        wait(for: expectations, timeout: 1)
    }

    func testLoadCreateTransfer_sourceTokenIsNil() {
        initializePresenter()
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "showError should not be performed")
        XCTAssertNotNil(presenter.selectedTransferMethod, "selectedTransferMethod should not be nil")
    }

    func testLoadCreateTransfer_sourceTokenIsNotNil() {
        initializePresenter(sourceToken: clientSourceToken)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "showError should not be performed")
        XCTAssertNotNil(presenter.selectedTransferMethod, "selectedTransferMethod should not be nil")
    }

    func testLoadCreateTransfer_getUser_success() {
        initializePresenter(sourceToken: clientSourceToken)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "showError should not be performed")
        XCTAssertNotNil(presenter.selectedTransferMethod, "selectedTransferMethod should not be nil")
    }

    func testLoadCreateTransfer_getUser_failure() {
        mockView.stopOnError = true
        initializePresenter(getUserResultType: .failure)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "showError should be performed")
        XCTAssertNil(presenter.selectedTransferMethod, "selectedTransferMethod should be nil")
    }

    func testLoadCreateTransfer_selectedTransferMethodIsNil() {
        initializePresenter(transferMethodResult: .noContent)

        XCTAssertEqual(presenter.sectionData.count, 5, "Section data count should be 5")

        XCTAssertEqual(presenter.sectionData[0].createTransferSectionHeader,
                       .amount,
                       "Section type should be Amount")
        XCTAssertEqual(presenter.sectionData[1].createTransferSectionHeader,
                       .transferAll,
                       "Section type should be TransferAll")
        XCTAssertEqual(presenter.sectionData[2].createTransferSectionHeader,
                       .destination,
                       "Section type should be Destination")
        XCTAssertEqual(presenter.sectionData[3].createTransferSectionHeader,
                       .notes,
                       "Section type should be Notes")
        XCTAssertEqual(presenter.sectionData[4].createTransferSectionHeader,
                       .button,
                       "Section type should be Button")
    }

    func testLoadCreateTransfer_selectedTransferMethodIsNotNil() {
        initializePresenter()

        XCTAssertEqual(presenter.sectionData.count, 5, "Section data count should be 5")

        XCTAssertEqual(presenter.sectionData[0].createTransferSectionHeader,
                       .amount,
                       "Section type should be Amount")
        XCTAssertEqual(presenter.sectionData[1].createTransferSectionHeader,
                       .transferAll,
                       "Section type should be TransferAll")
        XCTAssertEqual(presenter.sectionData[2].createTransferSectionHeader,
                       .destination,
                       "Section type should be Destination")
        XCTAssertEqual(presenter.sectionData[3].createTransferSectionHeader,
                       .notes,
                       "Section type should be Notes")
        XCTAssertEqual(presenter.sectionData[4].createTransferSectionHeader,
                       .button,
                       "Section type should be Button")
    }

    func testLoadCreateTransfer_loadTransferMethods_failure() {
        mockView.stopOnError = true
        initializePresenter(transferMethodResult: .failure)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "showError should be performed")
        XCTAssertNil(presenter.selectedTransferMethod, "selectedTransferMethod should be nil")
    }

    func testLoadCreateTransfer_createInitialQuote_failure() {
        mockView.stopOnError = true
        initializePresenter(createTransferResult: .failure)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "showError should be performed")
        XCTAssertNotNil(presenter.selectedTransferMethod, "selectedTransferMethod should not be nil")
        XCTAssertNil(presenter.availableBalance, "availableBalance should be nil")
    }

    func testCreateTransferSectionAddDestinationAccountData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[2]
        XCTAssertEqual(section.title, "TRANSFER TO", "Section title should be TRANSFER TO")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .destination, "Section type should be .destination")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       "transferDestinationCellIdentifier",
                       "Section cellIdentifier should be transferDestinationCellIdentifier")
    }

    func testCreateTransferSectionDestinationData_validateProperties() {
        initializePresenter(transferMethodResult: .noContent)
        let section = presenter.sectionData[2]
        XCTAssertEqual(section.title, "TRANSFER TO", "Section title should be TRANSFER TO")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .destination, "Section type should be .destination")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       "transferDestinationCellIdentifier",
                       "Section cellIdentifier should be transferDestinationCellIdentifier")
    }

    //todo
    func testCreateTransferSectionTransferAllData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[1]
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .transferAll, "Section type should be .transferAll")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       "transferAllFundsCellIdentifier",
                       "Section cellIdentifier should be transferAllFundsCellIdentifier")
    }

    func testCreateTransferSectionButtonData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[3]
        XCTAssertEqual(section.title, "Note", "Section title should be Note")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .notes, "Section type should be .notes")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
    }

    func testCreateTransferSectionNotesData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[3]
        XCTAssertEqual(section.title, "Note", "Section title should be Note")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .notes, "Section type should be .notes")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       "transferNotesCellIdentifier",
                       "Section cellIdentifier should be transferNotesCellIdentifier")
    }

    func testIsTransferMaxAmount_selectedTransferMethodIsNil() {
        initializePresenter(transferMethodResult: .noContent)
        XCTAssertFalse(mockView.isUpdateTransferAmountSectionPerformed,
                       "updateTransferAmountSection should not be performed")
        XCTAssertEqual(presenter.amount, "0", "Amount should be 0")
        XCTAssertNil(presenter.availableBalance, "availableBalance should be Nil")
        XCTAssertFalse(mockView.isUpdateTransferAmountSectionPerformed,
                       "updateTransferAmountSection should not be performed")
        XCTAssertEqual(presenter.amount, "0", "Amount should be 0")
    }

    func testIsTransferMaxAmount_selectedTransferMethodIsNotNil() {
        initializePresenter()
        XCTAssertFalse(mockView.isUpdateTransferAmountSectionPerformed,
                       "updateTransferAmountSection should not be performed")
        XCTAssertEqual(presenter.amount, "0", "Amount should be 0")
        XCTAssertEqual(presenter.availableBalance, "62.29", "availableBalance should be 62.29")

        XCTAssertTrue(mockView.isUpdateTransferAmountSectionPerformed,
                      "updateTransferAmountSection should be performed")
        XCTAssertEqual(presenter.amount, "62.29", "Amount should be 62.29")

        mockView.isUpdateTransferAmountSectionPerformed = false
        XCTAssertTrue(mockView.isUpdateTransferAmountSectionPerformed,
                      "updateTransferAmountSection should be performed")
        XCTAssertEqual(presenter.amount, "0", "Amount should be 0")
    }

    func testDestinationCurrency_selectedTransferMethodIsNil() {
        initializePresenter(transferMethodResult: .noContent)
        XCTAssertNil(presenter.destinationCurrency, "destinationCurrency should be Nil")
    }

    func testDestinationCurrency_selectedTransferMethodIsNotNil() {
        initializePresenter()
        XCTAssertEqual(presenter.destinationCurrency, "USD", "destinationCurrency should be USD")
    }

    func testCreateTransfer_emptyAmount_isTransferMaxAmount_success() {
        initializePresenter()
        mockView.resetStates()
        presenter.createTransfer()
        wait(for: [mockView.showScheduleTransferExpectation], timeout: 1)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "showError should not be performed")
    }

    func testCreateTransfer_notEmptyAmount_isTransferMaxAmount_success() {
        initializePresenter()
        mockView.resetStates()
        presenter.amount = "1.00"
        presenter.createTransfer()
        wait(for: [mockView.showScheduleTransferExpectation], timeout: 1)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "showError should not be performed")
    }

    func testCreateTransfer_failureWithFieldName() {
        initializePresenter()
        mockView.resetStates()
        presenter.amount = "1.00"
        CreateTransferRequestHelper.setupFailureRequestWithFieldName()
        presenter.createTransfer()
        wait(for: [mockView.updateFooterExpectation], timeout: 1)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertNotNil(presenter.sectionData[1].errorMessage, "errorMessage should not be nil")
    }

    func testCreateTransfer_failureWithoutFieldName() {
        initializePresenter()
        mockView.resetStates()
        presenter.amount = "1.00"
        CreateTransferRequestHelper.setupFailureRequestWithoutFieldName()
        presenter.createTransfer()
        wait(for: [mockView.showErrorExpectation], timeout: 1)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "showError should be performed")
    }

    func testCreateTransfer_unexpectedErrorFailure() {
        initializePresenter()
        mockView.resetStates()
        presenter.amount = "1.00"
        CreateTransferRequestHelper.setupUnexpectedFailureRequest()
        presenter.createTransfer()
        wait(for: [mockView.showErrorExpectation], timeout: 1)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "showError should be performed")
    }
}

class MockCreateTransferView: CreateTransferView {
    var isHideLoadingPerformed = false
    var isNotifyTransferCreatedPerformed = false
    var isShowCreateTransferPerformed = false
    var isShowErrorPerformed = false
    var isShowGenericTableViewPerformed = false
    var isShowLoadingPerformed = false
    var isShowScheduleTransferPerformed = false
    var isUpdateTransferAmountSectionPerformed = false
    var isAreAllFieldsValidPerformed = false
    var isUpdateFooterPerformed = false

    var stopOnError = false

    var loadCreateTransferExpectation: XCTestExpectation!
    var showErrorExpectation: XCTestExpectation!
    var showScheduleTransferExpectation: XCTestExpectation!
    var updateFooterExpectation: XCTestExpectation!

    func hideLoading() {
        isHideLoadingPerformed = true
    }

    func notifyTransferCreated(_ transfer: HyperwalletTransfer) {
        isNotifyTransferCreatedPerformed = true
    }

    func reloadData() {
        isShowCreateTransferPerformed = true
        loadCreateTransferExpectation?.fulfill()
    }

    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        if retry != nil {
            retry!()
        }
        showErrorExpectation?.fulfill()
    }

    func showLoading() {
        isShowLoadingPerformed = true
    }

    func showScheduleTransfer(_ transfer: HyperwalletTransfer) {
        isShowScheduleTransferPerformed = true
        showScheduleTransferExpectation?.fulfill()
    }

    func updateTransferAmountSection() {
        isUpdateTransferAmountSectionPerformed = true
    }

    func areAllFieldsValid() -> Bool {
        isAreAllFieldsValidPerformed = true
        return true
    }

    func updateFooter(for section: CreateTransferController.FooterSection) {
        isUpdateFooterPerformed = true
        updateFooterExpectation?.fulfill()
    }

    func resetStates() {
        isHideLoadingPerformed = false
        isNotifyTransferCreatedPerformed = false
        isShowCreateTransferPerformed = false
        isShowErrorPerformed = false
        isShowGenericTableViewPerformed = false
        isShowLoadingPerformed = false
        isShowScheduleTransferPerformed = false
        isUpdateTransferAmountSectionPerformed = false
        isAreAllFieldsValidPerformed = false
        isUpdateFooterPerformed = false

        stopOnError = false

        loadCreateTransferExpectation = XCTestExpectation(description: "loadCreateTransferExpectation")
        showErrorExpectation = XCTestExpectation(description: "showErrorExpectation")
        showScheduleTransferExpectation = XCTestExpectation(description: "showScheduleTransferExpectation")
        updateFooterExpectation = XCTestExpectation(description: "updateFooterExpectation")
    }
}
