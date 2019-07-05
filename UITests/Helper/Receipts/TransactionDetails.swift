import XCTest

class TransactionDetails {
    var navigationBar: XCUIElement
    var receiptDetailTableviewTable: XCUIElement
    var detailSection: XCUIElement
    var feeSection: XCUIElement
    var transactionSection: XCUIElement
    var cellTextLabel: XCUIElement
    var detailTextLabel: XCUIElement
    var detailHeaderTitle: XCUIElement
    // Detail
    var receiptIdLabel: XCUIElement
    var receiptIdValue: XCUIElement
    var dateLabel: XCUIElement
    var dateValue: XCUIElement
    var clientTransactionIdLabel: XCUIElement
    var clientTransactionIdValue: XCUIElement
    var charityNameLabel: XCUIElement
    var charityNameValue: XCUIElement
    var checkNumLabel: XCUIElement
    var checkNumValue: XCUIElement
    var promoWebSiteLabel: XCUIElement
    var promoWebSiteValue: XCUIElement
    // Fee
    var amountLabel: XCUIElement
    var amountValue: XCUIElement
    var feeLabel: XCUIElement
    var feeValue: XCUIElement
    var transactionLabel: XCUIElement
    var transactionValue: XCUIElement
    // Note
    var noteSectionLabel: XCUIElement
    // Back button
    var backButton: XCUIElement

    var app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
        navigationBar = app.navigationBars["Transaction Details"]
        detailHeaderTitle = app.navigationBars["Transaction Details"].otherElements["Transaction Details"]
        receiptDetailTableviewTable = app.tables["receiptDetailTableView"]
        cellTextLabel = receiptDetailTableviewTable.staticTexts["listReceiptTableViewCellTextLabel"]
        detailTextLabel = receiptDetailTableviewTable.staticTexts["listReceiptTableViewCellDetailTextLabel"]
        detailSection = receiptDetailTableviewTable.staticTexts["Details"]
        feeSection = receiptDetailTableviewTable.staticTexts["Fee Specification"]
        transactionSection = receiptDetailTableviewTable.staticTexts["Transaction"]
        receiptIdLabel = receiptDetailTableviewTable.staticTexts["journalIdLabel"]
        receiptIdValue = receiptDetailTableviewTable.staticTexts["journalIdValue"]
        dateLabel = receiptDetailTableviewTable.staticTexts["createdOnLabel"]
        dateValue = receiptDetailTableviewTable.staticTexts["createdOnValue"]
        clientTransactionIdLabel = receiptDetailTableviewTable.staticTexts["clientPaymentIdLabel"]
        clientTransactionIdValue = receiptDetailTableviewTable.staticTexts["clientPaymentIdValue"]

        charityNameLabel = receiptDetailTableviewTable.staticTexts["charityNameLabel"]
        charityNameValue = receiptDetailTableviewTable.staticTexts["charityNameValue"]
        checkNumLabel = receiptDetailTableviewTable.staticTexts["checkNumberLabel"]
        checkNumValue = receiptDetailTableviewTable.staticTexts["checkNumberValue"]
        promoWebSiteLabel = receiptDetailTableviewTable.staticTexts["websiteLabel"]
        promoWebSiteValue = receiptDetailTableviewTable.staticTexts["websiteValue"]

        noteSectionLabel = receiptDetailTableviewTable.staticTexts["Notes"]

        amountLabel = receiptDetailTableviewTable.staticTexts["amountLabel"]
        amountValue = receiptDetailTableviewTable.staticTexts["amountValue"]
        feeLabel = receiptDetailTableviewTable.staticTexts["feeLabel"]
        feeValue = receiptDetailTableviewTable.staticTexts["feeValue"]
        transactionLabel = receiptDetailTableviewTable.staticTexts["transactionLabel"]
        transactionValue = receiptDetailTableviewTable.staticTexts["transactionValue"]
        backButton = navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0)
    }

    func openReceipt(row: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: row)
        if row.exists {
            row.tap()
        }
    }
}
