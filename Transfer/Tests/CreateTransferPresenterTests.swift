#if !COCOAPODS
import Common
#endif
import Hippolyte
import HyperwalletSDK
@testable import Transfer
import XCTest

class CreateTransferTests: XCTestCase {
    private var presenter: CreateTransferPresenter!
    private var mockView = MockCreateTransferView()

    private let clientTransferId = "6712348070812"
    private let sourceToken = "trm-123456789"

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        mockView.resetStates()
    }

    private func initializePresenter(emptyTransferMethods: Bool) {
        if emptyTransferMethods {
            TransferMethodRepositoryRequestHelper.setupNoContentRequest()
        } else {
            TransferMethodRepositoryRequestHelper.setupSucessRequest()
        }
    }

    private func initializePresenter(transferMethodResult: LoadTransferMethodsResultType) {
        transferMethodResult.setUpRequest()
        UserRepositoryRequestHelper.setupSucessRequest()
        CreateTransferRequestHelper.setupSucessRequest()

        presenter = CreateTransferPresenter(clientTransferId, nil, view: mockView)

        let loadCreateTransferExpectation = self.expectation(description: "loadCreateTransferExpectation")
        mockView.expectation = loadCreateTransferExpectation

        presenter.loadCreateTransfer()
        wait(for: [loadCreateTransferExpectation], timeout: 1)
        presenter.initializeSections()
    }

    private func initializePresenterWithSource() {
        presenter = CreateTransferPresenter(clientTransferId, sourceToken, view: mockView)
        presenter.loadCreateTransfer()
    }

    private func initializePresenterEmptyTransferMethods() {
        let response = HyperwalletTestHelper.noContentHTTPResponse()
        let url = String(format: "%@%@", HyperwalletTestHelper.userRestURL, "/transfer-methods?")
        HyperwalletTestHelper.setUpMockServer(request:
            HyperwalletTestHelper.buildGetRequestRegexMatcher(pattern: url, response))
    }

    func testSectionDataWhenSelectedTransferMethodIsNil() {
        initializePresenter(emptyTransferMethods: true)

        XCTAssertEqual(presenter.sectionData.count, 3, "Section data count should be 3")

        XCTAssertEqual(presenter.sectionData[0].createTransferSectionHeader,
                       .destination,
                       "Section type should be Destination")
        XCTAssertEqual(presenter.sectionData[1].createTransferSectionHeader,
                       .notes,
                       "Section type should be Notes")
        XCTAssertEqual(presenter.sectionData[2].createTransferSectionHeader,
                       .button,
                       "Section type should be Button")
    }

    func testSectionDataWhenSelectedTransferMethodIsNotNil() {
        initializePresenter(emptyTransferMethods: false)

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

    func testShowSelectDestinationAccountView_success() {
        initializePresenter(transferMethodResult: .success)
        presenter.showSelectDestinationAccountView()
        XCTAssertTrue(mockView.isShowGenericTableViewPerformed)
    }

    func testShowSelectDestinationAccountView_failure() {
        initializePresenter(transferMethodResult: .failure)
        presenter.showSelectDestinationAccountView()
        XCTAssertFalse(mockView.isShowGenericTableViewPerformed)
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

    var expectation: XCTestExpectation?

    func hideLoading() {
        isHideLoadingPerformed = true
    }

    func notifyTransferCreated(_ transfer: HyperwalletTransfer) {
        isNotifyTransferCreatedPerformed = true
    }

    func showCreateTransfer() {
        isShowCreateTransferPerformed = true
        expectation?.fulfill()
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry!()
        expectation?.fulfill()
    }

    func showGenericTableView(items: [HyperwalletTransferMethod],
                              title: String,
                              selectItemHandler: @escaping CreateTransferView.SelectItemHandler,
                              markCellHandler: @escaping CreateTransferView.MarkCellHandler) {
        isShowGenericTableViewPerformed = true
    }

    func showLoading() {
        isShowLoadingPerformed = true
    }

    func showScheduleTransfer(_ transfer: HyperwalletTransfer) {
        isShowScheduleTransferPerformed = true
    }

    func updateTransferSection() {
        isUpdateTransferSectionPerformed = true
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
        expectation = nil
    }
}
