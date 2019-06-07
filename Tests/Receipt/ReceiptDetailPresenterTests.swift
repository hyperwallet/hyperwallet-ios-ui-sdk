import HyperwalletSDK
@testable import HyperwalletUISDK
import XCTest

class ReceiptDetailPresenterTests: XCTestCase {
    let receiptData = HyperwalletTestHelper.getDataFromJson("UserReceipt")
    var presenter: ReceiptDetailViewPresenter!

    override func setUp() {
        guard let receipt = try? JSONDecoder().decode(HyperwalletReceipt.self, from: receiptData) else {
            XCTFail("Can't decode user receipt from test data")
            return
        }
        presenter = ReceiptDetailViewPresenter(with: receipt)
    }

    func testSectionDataShouldNotBeEmpty() {
        XCTAssertEqual(presenter.sectionData.count, 3)
    }

    func testSectionTransactionDataShouldNotBeEmpty() {
        guard let section = presenter.sectionData[0] as? ReceiptDetailSectionTransactionData else {
            XCTFail("Section Transaction Data shouldn't be epty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .transaction)
        XCTAssertEqual(section.cellIdentifier, ReceiptTransactionTableViewCell.reuseIdentifier)

        let cellConfig = section.tableViewCellConfiguration
        XCTAssertEqual(cellConfig.type, "Payment")
        XCTAssertEqual(cellConfig.entry, "CREDIT")
        XCTAssertEqual(cellConfig.amount, "6.00")
        XCTAssertEqual(cellConfig.currency, "USD")
        XCTAssertEqual(cellConfig.createdOn, "Apr 28, 2019")
    }

    func testSectionDetailDataShouldNotBeEmpty() {
        guard let section = presenter.sectionData[1] as? ReceiptDetailSectionDetailData else {
            XCTFail("Section Detail Data shouldn't be epty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .details)
        XCTAssertEqual(section.cellIdentifier, ReceiptDetailTableViewCell.reuseIdentifier)

        XCTAssertEqual(section.rowCount, 3)
        XCTAssertTrue(rowEqual(section.rows[0], ("Receipt ID:", "55176986")))
        XCTAssertTrue(rowEqual(section.rows[1], ("Date:", "Sun, Apr 28, 2019, 9:16 PM")))
        XCTAssertTrue(rowEqual(section.rows[2], ("Client Transaction ID:", "DyClk0VG2a")))
    }

    func testSectionFeeDataShouldNotBeEmpty() {
        guard let section = presenter.sectionData[2] as? ReceiptDetailSectionFeeData else {
            XCTFail("Section Fee Data shouldn't be epty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .fee)
        XCTAssertEqual(section.cellIdentifier, ReceiptFeeTableViewCell.reuseIdentifier)

        XCTAssertEqual(section.rowCount, 3)
        XCTAssertTrue(rowEqual(section.rows[0], ("Amount:", "+6.00 USD")))
        XCTAssertTrue(rowEqual(section.rows[1], ("Fee:", "1.11 USD")))
        XCTAssertTrue(rowEqual(section.rows[2], ("Transaction:", "4.89 USD")))
    }

    private func rowEqual<T: Equatable> (_ tuple1: (T, T), _ tuple2: (T, T)) -> Bool {
        return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
    }
}
