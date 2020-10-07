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

    private enum LoadPrepaidCardResultType {
        case success, failure, noContent
        func setUpRequest() {
            switch self {
            case .success:
                PrepaidCardRepositoryRequestHelper
                    .setupSuccessRequest(responseFile: "GetPrepaidCardSuccessResponse",
                                         prepaidCardToken: PrepaidCardRepositoryRequestHelper.clientSourceToken)

            case .failure:
                PrepaidCardRepositoryRequestHelper
                    .setupFailureRequest(prepaidCardToken: PrepaidCardRepositoryRequestHelper.clientSourceToken)

            case .noContent:
                PrepaidCardRepositoryRequestHelper
                    .setupNoContentRequest(prepaidCardToken: PrepaidCardRepositoryRequestHelper.clientSourceToken)
            }
        }
    }

    private enum ListPrepaidCardsResultType {
        case success, failure, noContent
        func setUpRequest() {
            switch self {
            case .success:
                PrepaidCardRepositoryRequestHelper.setupSuccessRequest(responseFile: "ListPrepaidCardResponse",
                                                                       prepaidCardToken: nil)

            case .failure:
                PrepaidCardRepositoryRequestHelper.setupFailureRequest(prepaidCardToken: nil)

            case .noContent:
                PrepaidCardRepositoryRequestHelper.setupNoContentRequest(prepaidCardToken: nil)
            }
        }
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

    private func initializePresenter(prepaidCardResult: LoadPrepaidCardResultType = .success,
                                     transferMethodResult: LoadTransferMethodsResultType = .success,
                                     createTransferResult: CreateTransferResultType = .success,
                                     getUserResult: GetUserResultType = .success,
                                     listPrepaidCardResult: ListPrepaidCardsResultType = .success,
                                     sourceToken: String? = nil,
                                     showAllAvailableSources: Bool = false) {
        var expectations = [XCTestExpectation]()
        if sourceToken != nil {
            prepaidCardResult.setUpRequest()
        } else if showAllAvailableSources {
            listPrepaidCardResult.setUpRequest()
        } else {
            getUserResult.setUpRequest()
        }
        transferMethodResult.setUpRequest()
        createTransferResult.setUpRequest()
        presenter = CreateTransferPresenter(clientTransferId, sourceToken, showAllAvailableSources, view: mockView)

        if mockView.stopOnError {
            expectations.append(mockView.showErrorExpectation)
        } else {
            expectations.append(mockView.loadCreateTransferExpectation)
        }

        presenter.loadCreateTransfer()
        wait(for: expectations, timeout: 1)
    }

    private func assertResponse(isShowErrorPerformed: Bool,
                                transferSourceCellConfigurationsCount: Int,
                                transferSourceType: TransferSourceType,
                                selectedTransferDestination: Bool,
                                isAvailableBalancePresent: Bool) {
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertEqual(mockView.isShowErrorPerformed,
                       isShowErrorPerformed,
                       "showError should be \(isShowErrorPerformed)")
        XCTAssertEqual(presenter.transferSourceCellConfigurations.count,
                       transferSourceCellConfigurationsCount,
                       "transferSourceCellConfigurations should be \(transferSourceCellConfigurationsCount)")
        if presenter.transferSourceCellConfigurations.isNotEmpty {
            XCTAssertNotNil(presenter.transferSourceCellConfigurations.first(where: { $0.isSelected }),
                            "transferSourceCellConfigurations isSelected should not be nil")
            XCTAssertEqual(presenter.transferSourceCellConfigurations.first(where: { $0.isSelected })?.type,
                           transferSourceType,
                           "TransferSourceType shoould be \(transferSourceType)")
        }
        XCTAssertEqual(presenter.selectedTransferDestination != nil,
                       selectedTransferDestination,
                       "selectedTransferDestination != nil should be \(selectedTransferDestination)")
        XCTAssertEqual(presenter.availableBalance != nil,
                       isAvailableBalancePresent,
                       "availableBalance != nil should be \(isAvailableBalancePresent)")
    }

    func testLoadCreateTransfer_sourceTokenIsNil() {
        initializePresenter()
        assertResponse(isShowErrorPerformed: false,
                       transferSourceCellConfigurationsCount: 1,
                       transferSourceType: .user,
                       selectedTransferDestination: true,
                       isAvailableBalancePresent: true)
    }

    func testLoadCreateTransfer_sourceTokenIsNil_userErrorResponse() {
        mockView.stopOnError = true
        initializePresenter(getUserResult: .failure)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 0,
                       transferSourceType: .user,
                       selectedTransferDestination: false,
                       isAvailableBalancePresent: false)
    }

    func testLoadCreateTransfer_sourceTokenIsNotNil() {
        initializePresenter(sourceToken: PrepaidCardRepositoryRequestHelper.clientSourceToken)
        assertResponse(isShowErrorPerformed: false,
                       transferSourceCellConfigurationsCount: 1,
                       transferSourceType: .prepaidCard,
                       selectedTransferDestination: true,
                       isAvailableBalancePresent: true)
    }

    func testLoadCreateTransfer_sourceTokenIsNotNil_prepaidCardErrorResponse() {
        mockView.stopOnError = true
        initializePresenter(prepaidCardResult: .failure,
                            sourceToken: PrepaidCardRepositoryRequestHelper.clientSourceToken)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 1,
                       transferSourceType: .prepaidCard,
                       selectedTransferDestination: false,
                       isAvailableBalancePresent: false)
    }

    func testLoadCreateTransfer_showAllAvailableSources_walletModel_activePrepaidCards() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .walletModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        initializePresenter(showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: false,
                       transferSourceCellConfigurationsCount: 3,
                       transferSourceType: .user,
                       selectedTransferDestination: true,
                       isAvailableBalancePresent: true)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_walletModel_transferMethodErrorResponse() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .walletModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        mockView.stopOnError = true
        initializePresenter(transferMethodResult: .failure, showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 3,
                       transferSourceType: .user,
                       selectedTransferDestination: false,
                       isAvailableBalancePresent: false)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_walletModel_createInitialTransferErrorResponse() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .walletModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        mockView.stopOnError = true
        initializePresenter(createTransferResult: .failure, showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 3,
                       transferSourceType: .user,
                       selectedTransferDestination: true,
                       isAvailableBalancePresent: false)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_pay2CardModel() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .pay2CardModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        initializePresenter(showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: false,
                       transferSourceCellConfigurationsCount: 2,
                       transferSourceType: .prepaidCard,
                       selectedTransferDestination: true,
                       isAvailableBalancePresent: true)
        Hyperwallet.clearInstance()
    }
    
    func testLoadCreateTransfer_showAllAvailableSources_pay2CardModel_transferMethodErrorResponse() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .pay2CardModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        mockView.stopOnError = true
        initializePresenter(transferMethodResult: .failure, showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 2,
                       transferSourceType: .prepaidCard,
                       selectedTransferDestination: false,
                       isAvailableBalancePresent: false)
        Hyperwallet.clearInstance()
    }
    
    func testLoadCreateTransfer_showAllAvailableSources_pay2CardModel_createInitialTransferErrorResponse() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .pay2CardModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        mockView.stopOnError = true
        initializePresenter(createTransferResult: .failure, showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 2,
                       transferSourceType: .prepaidCard,
                       selectedTransferDestination: true,
                       isAvailableBalancePresent: false)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_cardOnlyModel() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .cardOnlyModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        initializePresenter(showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: false,
                       transferSourceCellConfigurationsCount: 2,
                       transferSourceType: .prepaidCard,
                       selectedTransferDestination: true,
                       isAvailableBalancePresent: true)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_walletModel_configurationErrorResponse() {
        Hyperwallet.clearInstance()
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProviderWithErrorResponse)
        mockView.stopOnError = true
        initializePresenter(showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 0,
                       transferSourceType: .user,
                       selectedTransferDestination: false,
                       isAvailableBalancePresent: false)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_walletModel_listPrepaidCardsNoResponse() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .walletModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        initializePresenter(listPrepaidCardResult: .noContent, showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: false,
                       transferSourceCellConfigurationsCount: 1,
                       transferSourceType: .user,
                       selectedTransferDestination: true,
                       isAvailableBalancePresent: true)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_walletModel_listPrepaidCardsErrorResponse() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .walletModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        mockView.stopOnError = true
        initializePresenter(listPrepaidCardResult: .failure, showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 1,
                       transferSourceType: .user,
                       selectedTransferDestination: false,
                       isAvailableBalancePresent: false)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_pay2CardModel_listPrepaidCardsNoResponse() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .pay2CardModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        mockView.stopOnError = true
        initializePresenter(listPrepaidCardResult: .noContent, showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: false,
                       transferSourceCellConfigurationsCount: 0,
                       transferSourceType: .prepaidCard,
                       selectedTransferDestination: false,
                       isAvailableBalancePresent: false)
        XCTAssertTrue(mockView.isShowAlertPerformed, "showAlert should be performed")
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_showAllAvailableSources_pay2CardModel_listPrepaidCardsErrorResponse() {
        Hyperwallet.clearInstance()
        HyperwalletTestHelper.programModel = .pay2CardModel
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        mockView.stopOnError = true
        initializePresenter(listPrepaidCardResult: .failure, showAllAvailableSources: true)
        assertResponse(isShowErrorPerformed: true,
                       transferSourceCellConfigurationsCount: 0,
                       transferSourceType: .prepaidCard,
                       selectedTransferDestination: false,
                       isAvailableBalancePresent: false)
        Hyperwallet.clearInstance()
    }

    func testLoadCreateTransfer_selectedTransferMethodIsNil() {
        initializePresenter(transferMethodResult: .noContent)

        XCTAssertEqual(presenter.sectionData.count,
                       CreateTransferSectionHeader.allCases.count,
                       "Section data count should be \(CreateTransferSectionHeader.allCases.count)")

        XCTAssertEqual(presenter.sectionData[0].createTransferSectionHeader,
                       .amount,
                       "Section type should be Amount")
        XCTAssertEqual(presenter.sectionData[1].createTransferSectionHeader,
                       .transferAll,
                       "Section type should be TransferAll")
        XCTAssertEqual(presenter.sectionData[2].createTransferSectionHeader,
                       .source,
                       "Section type should be Source")
        XCTAssertEqual(presenter.sectionData[3].createTransferSectionHeader,
                       .destination,
                       "Section type should be Destination")
        XCTAssertEqual(presenter.sectionData[4].createTransferSectionHeader,
                       .notes,
                       "Section type should be Notes")
        XCTAssertEqual(presenter.sectionData[5].createTransferSectionHeader,
                       .button,
                       "Section type should be Button")
    }

    func testLoadCreateTransfer_selectedTransferMethodIsNotNil() {
        initializePresenter()

        XCTAssertEqual(presenter.sectionData.count,
                       CreateTransferSectionHeader.allCases.count,
                       "Section data count should be \(CreateTransferSectionHeader.allCases.count)")

        XCTAssertEqual(presenter.sectionData[0].createTransferSectionHeader,
                       .amount,
                       "Section type should be Amount")
        XCTAssertEqual(presenter.sectionData[1].createTransferSectionHeader,
                       .transferAll,
                       "Section type should be TransferAll")
        XCTAssertEqual(presenter.sectionData[2].createTransferSectionHeader,
                       .source,
                       "Section type should be Source")
        XCTAssertEqual(presenter.sectionData[3].createTransferSectionHeader,
                       .destination,
                       "Section type should be Destination")
        XCTAssertEqual(presenter.sectionData[4].createTransferSectionHeader,
                       .notes,
                       "Section type should be Notes")
        XCTAssertEqual(presenter.sectionData[5].createTransferSectionHeader,
                       .button,
                       "Section type should be Button")
    }

    func testLoadCreateTransfer_loadTransferMethods_failure() {
        mockView.stopOnError = true
        initializePresenter(transferMethodResult: .failure)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "showError should be performed")
        XCTAssertNil(presenter.selectedTransferDestination, "selectedTransferMethod should be nil")
    }

    func testLoadCreateTransfer_createInitialQuote_failure() {
        mockView.stopOnError = true
        initializePresenter(createTransferResult: .failure)
        XCTAssertTrue(mockView.isShowLoadingPerformed, "showLoading should be performed")
        XCTAssertTrue(mockView.isHideLoadingPerformed, "hideLoading should be performed")
        XCTAssertTrue(mockView.isShowErrorPerformed, "showError should be performed")
        XCTAssertNotNil(presenter.selectedTransferDestination, "selectedTransferMethod should not be nil")
        XCTAssertNil(presenter.availableBalance, "availableBalance should be nil")
    }

    func testCreateTransferSectionTransferFromData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[2]
        XCTAssertEqual(section.title, "mobileTransferFromLabel".localized(), "Section title should be TRANSFER FROM")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .source, "Section type should be .source")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       TransferSourceCell.reuseIdentifier,
                       "Section cellIdentifier should be \(TransferSourceCell.reuseIdentifier)")
    }

    func testCreateTransferSectionAddDestinationAccountData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[3]
        XCTAssertEqual(section.title, "TRANSFER TO", "Section title should be TRANSFER TO")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .destination, "Section type should be .destination")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       TransferDestinationCell.reuseIdentifier,
                       "Section cellIdentifier should be \(TransferDestinationCell.reuseIdentifier)")
    }

    func testCreateTransferSectionDestinationData_validateProperties() {
        initializePresenter(transferMethodResult: .noContent)
        let section = presenter.sectionData[3]
        XCTAssertEqual(section.title, "TRANSFER TO", "Section title should be TRANSFER TO")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .destination, "Section type should be .destination")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       TransferDestinationCell.reuseIdentifier,
                       "Section cellIdentifier should be \(TransferDestinationCell.reuseIdentifier)")
    }

    func testCreateTransferSectionAmountData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[0]
        XCTAssertNil(section.title, "Section title should be nil")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .amount, "Section type should be .amount")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       TransferAmountCell.reuseIdentifier,
                       "Section cellIdentifier should be \(TransferAmountCell.reuseIdentifier)")
    }

    func testCreateTransferSectionTransferAllData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[1]
        XCTAssertNil(section.title, "Section title should be nil")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .transferAll, "Section type should be .transferAll")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       TransferAllFundsCell.reuseIdentifier,
                       "Section cellIdentifier should be \(TransferAllFundsCell.reuseIdentifier)")
    }

    func testCreateTransferSectionNotesData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[4]
        XCTAssertEqual(section.title, "Note", "Section title should be Note")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .notes, "Section type should be .notes")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       TransferNotesCell.reuseIdentifier,
                       "Section cellIdentifier should be \(TransferNotesCell.reuseIdentifier)")
    }

    func testCreateTransferSectionButtonData_validateProperties() {
        initializePresenter()
        let section = presenter.sectionData[5]
        XCTAssertNil(section.title, "Section title should be nil")
        XCTAssertEqual(section.rowCount, 1, "Section rowCount should be 1")
        XCTAssertEqual(section.createTransferSectionHeader, .button, "Section type should be .button")
        XCTAssertEqual(section.cellIdentifiers.count, 1, "Section cellIdentifiers.count should be 1")
        XCTAssertEqual(section.cellIdentifiers[0],
                       TransferButtonCell.reuseIdentifier,
                       "Section cellIdentifier should be \(TransferButtonCell.reuseIdentifier)")
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
        presenter.didTapTransferAllFunds = true
        XCTAssertTrue(mockView.isUpdateTransferAmountSectionPerformed,
                      "updateTransferAmountSection should be performed")
        XCTAssertEqual(presenter.amount, "62.29", "Amount should be 62.29")
    }

    func testDestinationCurrency_selectedTransferMethodIsNil() {
        initializePresenter(transferMethodResult: .noContent)
        XCTAssertNil(presenter.destinationCurrency, "destinationCurrency should be Nil")
        XCTAssertEqual(presenter.amount, "0", "amount should be 0")
        XCTAssertNil(presenter.availableBalance, "availableBalance should be Nil")
        XCTAssertNil(presenter.notes, "notes should be Nil")
    }

    func testDestinationCurrency_selectedTransferMethodIsNotNil() {
        initializePresenter()
        XCTAssertEqual(presenter.destinationCurrency, "USD", "destinationCurrency should be USD")
        XCTAssertNotNil(presenter.availableBalance, "availableBalance should not be Nil")
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
    var isShowAlertPerformed = false
    var isShowGenericTableViewPerformed = false
    var isShowLoadingPerformed = false
    var isShowScheduleTransferPerformed = false
    var isUpdateTransferAmountSectionPerformed = false
    var isAreAllFieldsValidPerformed = false
    var isUpdateFooterPerformed = false
    var isRetryPerformed = false

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

    func showAlert(message: String?) {
        isShowAlertPerformed = true
        showErrorExpectation?.fulfill()
    }

    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        if retry != nil, !isRetryPerformed {
            isRetryPerformed = true
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
        isShowAlertPerformed = false
        isShowGenericTableViewPerformed = false
        isShowLoadingPerformed = false
        isShowScheduleTransferPerformed = false
        isUpdateTransferAmountSectionPerformed = false
        isAreAllFieldsValidPerformed = false
        isUpdateFooterPerformed = false
        isRetryPerformed = false

        stopOnError = false

        loadCreateTransferExpectation = XCTestExpectation(description: "loadCreateTransferExpectation")
        showErrorExpectation = XCTestExpectation(description: "showErrorExpectation")
        showScheduleTransferExpectation = XCTestExpectation(description: "showScheduleTransferExpectation")
        updateFooterExpectation = XCTestExpectation(description: "updateFooterExpectation")
    }
}
