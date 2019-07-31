//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Hippolyte
import HyperwalletSDK
@testable import Transfer
import XCTest

class TransferTests: XCTestCase {
    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        //presenter = CreateTransferPresenter()
    }

    override func tearDown() {
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
        //mockView.resetStates()
    }
}

class MockCreateTransferView: CreateTransferView {
    func notifyTransferCreated(_ transfer: HyperwalletTransfer) {
    }

    func showCreateTransfer() {
    }

    func showGenericTableView(items: [HyperwalletTransferMethod],
                              title: String,
                              selectItemHandler: @escaping CreateTransferView.SelectItemHandler,
                              markCellHandler: @escaping CreateTransferView.MarkCellHandler) {
    }

    func showScheduleTransfer(_ transfer: HyperwalletTransfer) {
    }

    func updateTransferSection() {
    }

    var isHideLoadingPerformed = false
    var isShowLoadingPerformed = false
    var isShowErrorPerformed = false
    var isLoadReceiptPerformed = false

    var expectation: XCTestExpectation?

    func resetStates() {
        isHideLoadingPerformed = false
        isShowLoadingPerformed = false
        isShowErrorPerformed = false
        isLoadReceiptPerformed = false
        expectation = nil
    }

    func hideLoading() {
        isHideLoadingPerformed = true
    }

    func loadReceipts() {
        isLoadReceiptPerformed = true
        expectation?.fulfill()
    }

    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?) {
        isShowErrorPerformed = true
        retry!()
        expectation?.fulfill()
    }

    func showLoading() {
        isShowLoadingPerformed = true
    }
}
