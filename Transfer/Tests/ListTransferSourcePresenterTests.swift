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

#if !COCOAPODS
import Common
#endif
@testable import Transfer
import XCTest

class ListTransferSourcePresenterTests: XCTestCase {
    private var presenter: ListTransferSourcePresenter!

    func testInit() {
        var data = [TransferSourceCellConfiguration]()
        data.append(buildTransferSourceCellConfiguration(for: .user, isSelected: true))
        data.append(buildTransferSourceCellConfiguration(for: .prepaidCard, isSelected: false))
        presenter = ListTransferSourcePresenter(transferSources: data)

        XCTAssertEqual(presenter.sectionData.count, data.count, "count should be same")
        var index = 0
        presenter.sectionData.forEach {
            assertSectionData(inputData: data[index], initializedData: $0)
            index += 1
        }
    }

    private func assertSectionData(inputData: TransferSourceCellConfiguration?,
                                   initializedData: TransferSourceCellConfiguration?) {
        XCTAssertEqual(inputData?.token, initializedData?.token, "token should be same")
        XCTAssertEqual(inputData?.type, initializedData?.type, "type should be same")
        XCTAssertEqual(inputData?.isSelected, initializedData?.isSelected, "isSelected should be same")
        XCTAssertEqual(inputData?.title, initializedData?.title, "title should be same")
        XCTAssertEqual(inputData?.fontIcon, initializedData?.fontIcon, "fontIcon should be same")
    }

    private func buildTransferSourceCellConfiguration(for transferSourceType: TransferSourceType,
                                                      isSelected: Bool) -> TransferSourceCellConfiguration {
        let transferSourceCellConfiguration =
            TransferSourceCellConfiguration(isSelectedTransferSource: isSelected,
                                            type: transferSourceType,
                                            token: transferSourceType == .user ? "usr-1234" : "trm-1234",
                                            title: transferSourceType == .user ?
                                                "mobileAvailableFunds".localized() : "prepaid_card".localized(),
                                            fontIcon: transferSourceType == .user ? .bankAccount : .prepaidCard)
        return transferSourceCellConfiguration
    }
}
