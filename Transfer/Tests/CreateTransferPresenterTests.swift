#if !COCOAPODS
import Common
#endif
import Hippolyte
import HyperwalletSDK
@testable import Transfer
import TransferMethodRepository
import UserRepository
import XCTest

class CreateTransferTests: XCTestCase {
    private var presenter: CreateTransferPresenter!
    private var mockView = MockCreateTransferView()
    private let clientTransferId = "6712348070812"
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
        presenter.initializeSections()
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

        XCTAssertEqual(presenter.sectionData.count, 4, "Section data count should be 4")

        XCTAssertEqual(presenter.sectionData[0].createTransferSectionHeader,
                       .destination,
                       "Section type should be Destination")
        XCTAssertEqual(presenter.sectionData[1].createTransferSectionHeader,
                       .transfer,
                       "Section type should be Transfer")
        XCTAssertEqual(presenter.sectionData[2].createTransferSectionHeader,
                       .notes,
                       "Section type should be Notes")
        XCTAssertEqual(presenter.sectionData[3].createTransferSectionHeader,
                       .button,
                       "Section type should be Button")
    }

    func testLoadCreateTransfer_selectedTransferMethodIsNotNil() {
        initializePresenter()

        XCTAssertEqual(presenter.sectionData.count, 4, "Section data count should be 4")

        XCTAssertEqual(presenter.sectionData[0].createTransferSectionHeader,
                       .destination,
                       "Section type should be Destination")
        XCTAssertEqual(presenter.sectionData[1].createTransferSectionHeader,
                       .transfer,
                       "Section type should be Transfer")
        XCTAssertEqual(presenter.sectionData[2].createTransferSectionHeader,
                       .notes,
                       "Section type should be Notes")
        XCTAssertEqual(presenter.sectionData[3].createTransferSectionHeader,
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
        let section = presenter.sectionData[0]
        XCTAssertEqual(section.title, "DESTINATION", "Section title should be DESTINATION")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .destination, "Section type should be .destination")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       "transferDestinationCellIdentifier",
                       "Section cellIdentifier should be transferDestinationCellIdentifier")
    }

    func testCreateTransferSectionDestinationData_validateProperties() {
        initializePresenter(transferMethodResult: .noContent)
        let section = presenter.sectionData[0]
        XCTAssertEqual(section.title, "DESTINATION", "Section title should be DESTINATION")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .destination, "Section type should be .destination")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       "transferDestinationCellIdentifier",
                       "Section cellIdentifier should be transferDestinationCellIdentifier")
    }

    func testCreateTransferSectionTransferData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[1]
        XCTAssertEqual(section.title, "TRANSFER", "Section title should be TRANSFER")
        XCTAssertEqual(section.rowCount, 2, "Section rowCount should be 2")
        XCTAssertEqual(section.createTransferSectionHeader, .transfer, "Section type should be .transfer")
        XCTAssertEqual(section.cellIdentifiers.count, 2, "Section cellIdentifiers.count should be 2")
        XCTAssertEqual(section.cellIdentifiers[0],
                       "transferAmountCellIdentifier",
                       "Section cellIdentifier should be transferAmountCellIdentifier")
        XCTAssertEqual(section.cellIdentifiers[1],
                       "transferAllFundsCellIdentifier",
                       "Section cellIdentifier should be transferAllFundsCellIdentifier")
    }

    func testCreateTransferSectionButtonData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[2]
        XCTAssertEqual(section.title, "NOTES", "Section title should be NOTES")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .notes, "Section type should be .notes")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
    }

    func testCreateTransferSectionNotesData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[3]
        XCTAssertNil(section.title, "Section title should be Nil")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .button, "Section type should be .button")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       "transferButtonCellIdentifier",
                       "Section cellIdentifier should be transferButtonCellIdentifier")
    }

    func testTransferAllFundsIsOn_selectedTransferMethodIsNil() {
        initializePresenter(transferMethodResult: .noContent)
        XCTAssertFalse(presenter.transferAllFundsIsOn, "transferAllFundsIsOn should be False")
        XCTAssertFalse(mockView.isUpdateTransferSectionPerformed, "updateTransferSection should not be performed")
        XCTAssertNil(presenter.amount, "Amount should be nil")
        XCTAssertNil(presenter.availableBalance, "availableBalance should be Nil")
        presenter.transferAllFundsIsOn = true
        XCTAssertTrue(mockView.isUpdateTransferSectionPerformed, "updateTransferSection should not be performed")
        XCTAssertNil(presenter.amount, "Amount should be nil")
    }

    func testTransferAllFundsIsOn_selectedTransferMethodIsNotNil() {
        initializePresenter()
        XCTAssertFalse(presenter.transferAllFundsIsOn, "transferAllFundsIsOn should be False")
        XCTAssertFalse(mockView.isUpdateTransferSectionPerformed, "updateTransferSection should not be performed")
        XCTAssertNil(presenter.amount, "Amount should be nil")
        XCTAssertEqual(presenter.availableBalance, "62.29", "availableBalance should be 62.29")

        presenter.transferAllFundsIsOn = true
        XCTAssertTrue(mockView.isUpdateTransferSectionPerformed, "updateTransferSection should be performed")
        XCTAssertEqual(presenter.amount, "62.29", "Amount should be 62.29")

        mockView.isUpdateTransferSectionPerformed = false
        presenter.transferAllFundsIsOn = false
        XCTAssertTrue(mockView.isUpdateTransferSectionPerformed, "updateTransferSection should be performed")
        XCTAssertNil(presenter.amount, "Amount should be Nil")
    }

    func testDestinationCurrency_selectedTransferMethodIsNil() {
        initializePresenter(transferMethodResult: .noContent)
        XCTAssertNil(presenter.destinationCurrency, "destinationCurrency should be Nil")
    }

    func testDestinationCurrency_selectedTransferMethodIsNotNil() {
        initializePresenter()
        XCTAssertEqual(presenter.destinationCurrency, "USD", "destinationCurrency should be USD")
    }

    func testCreateTransfer_emptyAmount_transferAllFundsIsOn_success() {
        initializePresenter()
        mockView.resetStates()
        presenter.transferAllFundsIsOn = true
        presenter.createTransfer()
        wait(for: [mockView.showScheduleTransferExpectation], timeout: 1)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertFalse(mockView.isShowErrorPerformed, "showError should not be performed")
    }

    func testCreateTransfer_notEmptyAmount_transferAllFundsIsOn_success() {
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

    func testShowSelectDestinationAccountView_success() {
        initializePresenter()
        presenter.showSelectDestinationAccountView()
        XCTAssertTrue(mockView.isShowGenericTableViewPerformed, "isShowGenericTableViewPerformed should be performed")
        XCTAssertNotNil(presenter.selectedTransferMethod, "selectedTransferMethod should not be nil")
        XCTAssertNil(presenter.amount, "amount should be nil")
        XCTAssertTrue(mockView.isShowCreateTransferPerformed, "isShowCreateTransferPerformed should be performed")
    }

    func testShowSelectDestinationAccountView_failure() {
        presenter = CreateTransferPresenter(clientTransferId, nil, view: mockView)
        TransferMethodRepositoryRequestHelper.setupFailureRequest()
        presenter.showSelectDestinationAccountView()
        wait(for: [mockView.showErrorExpectation], timeout: 1)
        XCTAssertFalse(mockView.isShowGenericTableViewPerformed,
                       "isShowGenericTableViewPerformed should not be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "isShowErrorPerformed should be performed")
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
    var isUpdateTransferSectionPerformed = false
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

    func showCreateTransfer() {
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

    func showGenericTableView(items: [HyperwalletTransferMethod],
                              title: String,
                              selectItemHandler: @escaping CreateTransferView.SelectItemHandler,
                              markCellHandler: @escaping CreateTransferView.MarkCellHandler) {
        isShowGenericTableViewPerformed = true
        selectItemHandler(items.first!)
        _ = markCellHandler(items.first!)
    }

    func showLoading() {
        isShowLoadingPerformed = true
    }

    func showScheduleTransfer(_ transfer: HyperwalletTransfer) {
        isShowScheduleTransferPerformed = true
        showScheduleTransferExpectation?.fulfill()
    }

    func updateTransferSection() {
        isUpdateTransferSectionPerformed = true
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
        isUpdateTransferSectionPerformed = false
        isAreAllFieldsValidPerformed = false
        isUpdateFooterPerformed = false

        stopOnError = false

        loadCreateTransferExpectation = XCTestExpectation(description: "loadCreateTransferExpectation")
        showErrorExpectation = XCTestExpectation(description: "showErrorExpectation")
        showScheduleTransferExpectation = XCTestExpectation(description: "showScheduleTransferExpectation")
        updateFooterExpectation = XCTestExpectation(description: "updateFooterExpectation")
    }
}
