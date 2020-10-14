import HyperwalletSDK
@testable import Receipt
import XCTest

class ReceiptDetailPresenterTests: XCTestCase {
    let receiptsData = HyperwalletTestHelper.getDataFromJson("UserReceiptDetails")
    var presenterNoNotes: ReceiptDetailPresenter!
    var presenterWithNotes: ReceiptDetailPresenter!
    var presenterWithIntegerAmount: ReceiptDetailPresenter!

    override func setUp() {
        guard let receipts = try? JSONDecoder().decode([HyperwalletReceipt].self, from: receiptsData) else {
            XCTFail("Can't decode user receipts from test data")
            return
        }
        presenterNoNotes = ReceiptDetailPresenter(with: receipts[0])
        presenterWithNotes = ReceiptDetailPresenter(with: receipts[1])
        presenterWithIntegerAmount = ReceiptDetailPresenter(with: receipts[2])
    }

    func testSectionDataShouldNotBeEmpty() {
        XCTAssertEqual(presenterNoNotes.sectionData.count, 3)
        XCTAssertEqual(presenterWithNotes.sectionData.count, 4)
    }

    func testSectionFeeIsNil() {
        guard let receipts = try? JSONDecoder().decode([HyperwalletReceipt].self, from: receiptsData) else {
            XCTFail("Can't decode user receipts from test data")
            return
        }

        XCTAssertNil(ReceiptDetailSectionFeeData(from: receipts[3]))
        XCTAssertNil(ReceiptDetailSectionFeeData(from: receipts[4]))
    }

    func testSectionTransactionDataShouldNotBeEmpty() {
        guard let section = presenterNoNotes.sectionData[0] as? ReceiptDetailSectionTransactionData else {
            XCTFail("Section Transaction Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .transaction)
        XCTAssertEqual(section.cellIdentifier, ReceiptTransactionCell.reuseIdentifier)
        XCTAssertEqual(section.title, "mobileTransactionTypeLabel".localized())
        XCTAssertEqual(section.rowCount, 1)

        let receipt = section.receipt
        XCTAssertEqual(receipt.type?.rawValue.lowercased().localized(), "Payment")
        XCTAssertEqual(receipt.entry?.rawValue, "CREDIT")
        XCTAssertEqual(receipt.amount, "6.00")
        XCTAssertEqual(receipt.currency, "USD")
        XCTAssertEqual(receipt.createdOn, "2019-04-28T18:16:04")
    }

    func testSectionDetailDataShouldNotBeEmpty() {
        guard let section = presenterNoNotes.sectionData[1] as? ReceiptDetailSectionDetailData else {
            XCTFail("Section Detail Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .details)
        XCTAssertEqual(section.cellIdentifier, ReceiptDetailCell.reuseIdentifier)
        XCTAssertEqual(section.title, "mobileTransactionDetailsLabel".localized())
        XCTAssertEqual(section.rowCount, 3)

        XCTAssertTrue(rowEqual(section.rows[0], "mobileJournalNumberLabel".localized(), "55176986", "journalId"))
        let expectedDateTime = ISO8601DateFormatter.ignoreTimeZone
            .date(from: "2019-04-28T18:16:04")!
            .format(for: .dateTime)
        XCTAssertTrue(rowEqual(section.rows[1], "date".localized(), expectedDateTime, "createdOn"))
        XCTAssertTrue(rowEqual(section.rows[2],
                               "mobileTransactionIdLabel".localized(),
                               "DyClk0VG2a",
                               "clientPaymentId"))
    }

    func testSectionCreditFeeDataShouldNotBeEmpty() {
        guard let section = presenterNoNotes.sectionData[2] as? ReceiptDetailSectionFeeData else {
            XCTFail("Section Fee Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .fee)
        XCTAssertEqual(section.cellIdentifier, ReceiptFeeCell.reuseIdentifier)
        XCTAssertEqual(section.title, "mobileFeeInfoLabel".localized())
        XCTAssertEqual(section.rowCount, 3)

        XCTAssertTrue(rowEqual(section.rows[0], "amount".localized(), "$6.00 USD", "amount"))
        XCTAssertTrue(rowEqual(section.rows[1], "mobileFeeLabel".localized(), "$1.11 USD", "fee"))
        XCTAssertTrue(rowEqual(section.rows[2], "mobileTransactionDetailsTotal".localized(), "$4.89 USD", "transaction"))
    }

    func testSectionDebitFeeDataShouldNotBeEmpty() {
        guard let section = presenterWithNotes.sectionData[3] as? ReceiptDetailSectionFeeData else {
            XCTFail("Section Fee Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .fee)
        XCTAssertEqual(section.cellIdentifier, ReceiptFeeCell.reuseIdentifier)
        XCTAssertEqual(section.rowCount, 3)

        XCTAssertTrue(rowEqual(section.rows[0], "amount".localized(), "-$9.87 USD", "amount"))
        XCTAssertTrue(rowEqual(section.rows[1], "mobileFeeLabel".localized(), "$0.11 USD", "fee"))
        XCTAssertTrue(rowEqual(section.rows[2], "mobileTransactionDetailsTotal".localized(), "$9.76 USD", "transaction"))
    }

    func testSectionFeeDataWithIntegerAmountShouldNotBeEmpty() {
        guard let section = presenterWithIntegerAmount.sectionData[2] as? ReceiptDetailSectionFeeData else {
            XCTFail("Section Fee Data shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .fee)
        XCTAssertEqual(section.cellIdentifier, ReceiptFeeCell.reuseIdentifier)
        XCTAssertEqual(section.rowCount, 3)

        XCTAssertTrue(rowEqual(section.rows[0], "amount".localized(), "-₩100,500 KRW", "amount"))
        XCTAssertTrue(rowEqual(section.rows[1], "mobileFeeLabel".localized(), "₩500 KRW", "fee"))
        XCTAssertTrue(rowEqual(section.rows[2],
                               "mobileTransactionDetailsTotal".localized(),
                               "₩100,000 KRW",
                               "transaction"))
    }

    func testSectionNotesDataShouldNotBeEmpty() {
        guard let section = presenterWithNotes.sectionData[2] as? ReceiptDetailSectionNotesData else {
            XCTFail("Section Notes shouldn't be empty")
            return
        }
        XCTAssertEqual(section.receiptDetailSectionHeader, .notes)
        XCTAssertEqual(section.cellIdentifier, ReceiptNotesCell.reuseIdentifier)
        XCTAssertEqual(section.title, "mobileConfirmNotesLabel".localized())
        XCTAssertEqual(section.rowCount, 1)

        XCTAssertNotNil(section.notes)
        XCTAssertFalse(section.notes!.isEmpty)
    }

    private func rowEqual(_ row: ReceiptDetailRow, _ title: String, _ value: String, _ field: String) -> Bool {
        return row.title == title && row.value == value && row.field == field
    }
}
