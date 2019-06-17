import XCTest


class TransactionDetails {

    var receiptdetailtableviewTable:XCUIElement
    var detailSection:XCUIElement
    var feeSection:XCUIElement
    var transactionSection:XCUIElement
    var cellTextLabel: XCUIElement
    var detailTextLabel: XCUIElement
    var detailHeaderTitle:XCUIElement

    // Detail
    var receiptIdLabel:XCUIElement
    var dateLabel:XCUIElement
    var clientTransactionIdLabel:XCUIElement
    // Fee
    var amountLabel: XCUIElement
    var feeLabel: XCUIElement
    var transactionLabel: XCUIElement
    // Back button
    var backButton: XCUIElement

    var app: XCUIApplication

    init(app:XCUIApplication) {
        self.app = app
        detailHeaderTitle = app.navigationBars["Transaction Details"].otherElements["Transaction Details"]
        receiptdetailtableviewTable = app.tables["receiptDetailTableView"]
        // "ListReceiptTableViewCellTextLabel"
        cellTextLabel = receiptdetailtableviewTable.staticTexts["ListReceiptTableViewCellTextLabel"]
        detailTextLabel = receiptdetailtableviewTable.staticTexts["ListReceiptTableViewDetailTextLabel"]
        detailSection = receiptdetailtableviewTable.staticTexts["Details"]
        feeSection  = receiptdetailtableviewTable.staticTexts["Fee Specification"]
        transactionSection  = receiptdetailtableviewTable.staticTexts["Transaction"]
        receiptIdLabel = receiptdetailtableviewTable.staticTexts["Receipt ID:"]
        dateLabel = receiptdetailtableviewTable.staticTexts["Date:"]
        clientTransactionIdLabel = receiptdetailtableviewTable.staticTexts["Client Transaction ID:"]
        amountLabel = receiptdetailtableviewTable.staticTexts["Amount:"]
        feeLabel = receiptdetailtableviewTable.staticTexts["Fee:"]
        transactionLabel = receiptdetailtableviewTable.staticTexts["Transaction:"]
        backButton = app.navigationBars["Transaction Details"].buttons["Back"]
    }

    
    
}
