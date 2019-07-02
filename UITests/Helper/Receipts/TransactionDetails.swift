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
        cellTextLabel = receiptDetailTableviewTable.staticTexts["ListReceiptTableViewCellTextLabel"]
        detailTextLabel = receiptDetailTableviewTable.staticTexts["ListReceiptTableViewCellDetailTextLabel"]
        detailSection = receiptDetailTableviewTable.staticTexts["Details"]
        feeSection = receiptDetailTableviewTable.staticTexts["Fee Specification"]
        transactionSection = receiptDetailTableviewTable.staticTexts["Transaction"]
        receiptIdLabel = receiptDetailTableviewTable.staticTexts["JournalId"]
        receiptIdValue = receiptDetailTableviewTable.staticTexts["JournalId_value"]
        dateLabel = receiptDetailTableviewTable.staticTexts["CreatedOn"]
        dateValue = receiptDetailTableviewTable.staticTexts["CreatedOn_value"]
        clientTransactionIdLabel = receiptDetailTableviewTable.staticTexts["ClientPaymentId"]
        clientTransactionIdValue = receiptDetailTableviewTable.staticTexts["ClientPaymentId_value"]

        charityNameLabel = receiptDetailTableviewTable.staticTexts["CharityName"]
        charityNameValue = receiptDetailTableviewTable.staticTexts["CharityName_value"]
        checkNumLabel = receiptDetailTableviewTable.staticTexts["CheckNumber"]
        checkNumValue = receiptDetailTableviewTable.staticTexts["CheckNumber_value"]
        promoWebSiteLabel = receiptDetailTableviewTable.staticTexts["Website"]
        promoWebSiteValue = receiptDetailTableviewTable.staticTexts["Website_value"]

        noteSectionLabel = receiptDetailTableviewTable.staticTexts["Notes"]

        amountLabel = receiptDetailTableviewTable.staticTexts["Amount"]
        amountValue = receiptDetailTableviewTable.staticTexts["Amount_value"]
        feeLabel = receiptDetailTableviewTable.staticTexts["Fee"]
        feeValue = receiptDetailTableviewTable.staticTexts["Fee_value"]
        transactionLabel = receiptDetailTableviewTable.staticTexts["Transaction"]
        transactionValue = receiptDetailTableviewTable.staticTexts["Transaction_value"]
        backButton = navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0)
    }

    func openReceipt(row: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: row)
        if row.exists {
            row.tap()
        }
    }
}
