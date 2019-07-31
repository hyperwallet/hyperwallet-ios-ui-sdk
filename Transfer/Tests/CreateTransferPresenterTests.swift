#if !COCOAPODS
import Common
#endif
import Hippolyte
import HyperwalletSDK
@testable import Transfer
import XCTest

class TransferTests: XCTestCase {
    private var presenter: CreateTransferPresenter!
    private var mockView = MockCreateTransferView()

    private let clientTransferId = "client-trasnsfer-id-123456789"
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

    private func initializePresenterEmptySource() {
        presenter = CreateTransferPresenter(clientTransferId, nil, view: mockView)
        presenter.loadCreateTransfer()
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

    func testInitializeSectionsWhenSelectedTransferMethodIsNil() {
        initializePresenterEmptySource()
        XCTAssertEqual(presenter.sectionData.count, 3, "")
    }

    func testInitializeSectionsWhenSelectedTransferMethodIsNotNil() {
        initializePresenterEmptySource()
        XCTAssertEqual(presenter.sectionData.count, 4, "")
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
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
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
