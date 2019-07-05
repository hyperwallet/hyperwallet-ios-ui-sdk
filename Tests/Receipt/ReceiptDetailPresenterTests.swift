import HyperwalletSDK
@testable import HyperwalletUISDK
import XCTest

class ReceiptDetailPresenterTests: XCTestCase {
    let receiptsData = HyperwalletTestHelper.getDataFromJson("UserReceiptDetails")
    var presenterNoNotes: ReceiptDetailViewPresenter!
    var presenterWithNotes: ReceiptDetailViewPresenter!
    var presenterWithIntegerAmount: ReceiptDetailViewPresenter!

    override func setUp() {
        guard let receipts = try? JSONDecoder().decode([HyperwalletReceipt].self, from: receiptsData) else {
            XCTFail("Can't decode user receipts from test data")
            return
        }
        presenterNoNotes = ReceiptDetailViewPresenter(with: receipts[0])
        presenterWithNotes = ReceiptDetailViewPresenter(with: receipts[1])
        presenterWithIntegerAmount = ReceiptDetailViewPresenter(with: receipts[2])
    }

    func testSectionDataShouldNotBeEmpty() {
        XCTAssertEqual(presenterNoNotes.sectionData.count, 3)
        XCTAssertEqual(presenterWithNotes.sectionData.count, 4)
    }

    func testSectionTransactionDataShouldNotBeEmpty() {
        guard let section = presenterNoNotes.sectionData[0] as? ReceiptDetailSectionTransactionData else {
            XCTFail("Section Transaction Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .transaction)
        XCTAssertEqual(section.cellIdentifier, ReceiptTransactionTableViewCell.reuseIdentifier)
        XCTAssertEqual(section.title, "Transaction")
        XCTAssertEqual(section.rowCount, 1)

        let cellConfig = section.tableViewCellConfiguration
        XCTAssertEqual(cellConfig.type, "Payment")
        XCTAssertEqual(cellConfig.entry, "CREDIT")
        XCTAssertEqual(cellConfig.amount, "6.00")
        XCTAssertEqual(cellConfig.currency, "USD")
        //XCTAssertEqual(cellConfig.createdOn, "Apr 28, 2019")
    }

    func testSectionDetailDataShouldNotBeEmpty() {
        guard let section = presenterNoNotes.sectionData[1] as? ReceiptDetailSectionDetailData else {
            XCTFail("Section Detail Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .details)
        XCTAssertEqual(section.cellIdentifier, ReceiptDetailTableViewCell.reuseIdentifier)
        XCTAssertEqual(section.title, "Details")
        XCTAssertEqual(section.rowCount, 3)

        XCTAssertTrue(rowEqual(section.rows[0], ("Receipt ID:", "55176986")))
        //XCTAssertTrue(rowEqual(section.rows[1], ("Date:", "Sun, Apr 28, 2019, 9:16 PM")))
        XCTAssertTrue(rowEqual(section.rows[2], ("Client Transaction ID:", "DyClk0VG2a")))
    }

    func testSectionCreditFeeDataShouldNotBeEmpty() {
        guard let section = presenterNoNotes.sectionData[2] as? ReceiptDetailSectionFeeData else {
            XCTFail("Section Fee Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .fee)
        XCTAssertEqual(section.cellIdentifier, ReceiptFeeTableViewCell.reuseIdentifier)
        XCTAssertEqual(section.title, "Fee Specification")
        XCTAssertEqual(section.rowCount, 3)

        XCTAssertTrue(rowEqual(section.rows[0], ("Amount:", "6.00 USD")))
        XCTAssertTrue(rowEqual(section.rows[1], ("Fee:", "1.11 USD")))
        XCTAssertTrue(rowEqual(section.rows[2], ("Transaction:", "4.89 USD")))
    }

    func testSectionDebitFeeDataShouldNotBeEmpty() {
        guard let section = presenterWithNotes.sectionData[3] as? ReceiptDetailSectionFeeData else {
            XCTFail("Section Fee Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .fee)
        XCTAssertEqual(section.cellIdentifier, ReceiptFeeTableViewCell.reuseIdentifier)
        XCTAssertEqual(section.rowCount, 3)

        XCTAssertTrue(rowEqual(section.rows[0], ("Amount:", "-9.87 USD")))
        XCTAssertTrue(rowEqual(section.rows[1], ("Fee:", "0.11 USD")))
        XCTAssertTrue(rowEqual(section.rows[2], ("Transaction:", "9.76 USD")))
    }

    func testSectionFeeDataWithIntegerAmountShouldNotBeEmpty() {
        guard let section = presenterWithIntegerAmount.sectionData[2] as? ReceiptDetailSectionFeeData else {
            XCTFail("Section Fee Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .fee)
        XCTAssertEqual(section.cellIdentifier, ReceiptFeeTableViewCell.reuseIdentifier)
        XCTAssertEqual(section.rowCount, 3)

        XCTAssertTrue(rowEqual(section.rows[0], ("Amount:", "-100500 KRW")))
        XCTAssertTrue(rowEqual(section.rows[1], ("Fee:", "500 KRW")))
        XCTAssertTrue(rowEqual(section.rows[2], ("Transaction:", "100000 KRW")))
    }

    func testSectionNotesDataShouldNotBeEmpty() {
        guard let section = presenterWithNotes.sectionData[2] as? ReceiptDetailSectionNotesData else {
            XCTFail("Section Notes shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .notes)
        XCTAssertEqual(section.cellIdentifier, ReceiptNotesTableViewCell.reuseIdentifier)
        XCTAssertEqual(section.title, "Notes")
        XCTAssertEqual(section.rowCount, 1)

        XCTAssertNotNil(section.notes)
        XCTAssertFalse(section.notes!.isEmpty)
    }

    private func rowEqual<T: Equatable> (_ tuple1: (T, T), _ tuple2: (T, T)) -> Bool {
        return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
    }
}
