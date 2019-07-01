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
    var charityNameLabel: XCUIElement
    var checkNumLabel: XCUIElement
    var promoWebSiteLabel: XCUIElement
    // Fee
    var amountLabel: XCUIElement
    var feeLabel: XCUIElement
    var transactionLabel: XCUIElement
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
        detailTextLabel = receiptDetailTableviewTable.staticTexts["ListReceiptTableViewDetailTextLabel"]
        detailSection = receiptDetailTableviewTable.staticTexts["Details"]
        feeSection = receiptDetailTableviewTable.staticTexts["Fee Specification"]
        transactionSection = receiptDetailTableviewTable.staticTexts["Transaction"]
        receiptIdLabel = receiptDetailTableviewTable.staticTexts["Receipt ID:"]
        receiptIdValue = receiptDetailTableviewTable.staticTexts["Receipt ID:_value"]
        dateLabel = receiptDetailTableviewTable.staticTexts["Date:"]
        dateValue = receiptDetailTableviewTable.staticTexts["Date:_value"]
        clientTransactionIdLabel = receiptDetailTableviewTable.staticTexts["Client Transaction ID:"]
        charityNameLabel = receiptDetailTableviewTable.staticTexts["Charity Name:"]
        checkNumLabel = receiptDetailTableviewTable.staticTexts["Check Number:"]
        promoWebSiteLabel = receiptDetailTableviewTable.staticTexts["Promo Website:"]
        noteSectionLabel = receiptDetailTableviewTable.staticTexts["Notes"]
        amountLabel = receiptDetailTableviewTable.staticTexts["Amount:"]
        feeLabel = receiptDetailTableviewTable.staticTexts["Fee:"]
        transactionLabel = receiptDetailTableviewTable.staticTexts["Transaction:"]
        backButton = navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0)
    }

    func openReceipt(row: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: row)
        if row.exists {
            row.tap()
        }
    }
}
