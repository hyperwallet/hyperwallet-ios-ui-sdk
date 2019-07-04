import XCTest

class TransactionDetails {
    var navigationBar: XCUIElement
    // Sections
    var detailSection: XCUIElement
    var feeSection: XCUIElement
    var transactionSection: XCUIElement
    // Payment
    var cellTextLabel: XCUIElement
    var detailTextLabel: XCUIElement
    var detailHeaderTitle: XCUIElement
    // Detail
    var receiptIdLabel: XCUIElement
    var dateLabel: XCUIElement
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

    // Values label
    var receiptIdValue: XCUIElement
    var dateValue: XCUIElement
    var clientTransactionIdValue: XCUIElement
    var charityNameValue: XCUIElement
    var checkNumValue: XCUIElement
    var websiteValue: XCUIElement
    var notesValue: XCUIElement
    var amountValue: XCUIElement
    var feeValue: XCUIElement
    var transactionValue: XCUIElement

    var app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
        navigationBar = app.navigationBars["Transaction Details"]
        detailHeaderTitle = app.navigationBars["Transaction Details"].otherElements["Transaction Details"]
        cellTextLabel = app.tables["receiptDetailTableView"].staticTexts["ListReceiptTableViewCellTextLabel"]
        detailTextLabel = app.tables["receiptDetailTableView"].staticTexts["ListReceiptTableViewDetailTextLabel"]
        detailSection = app.tables["receiptDetailTableView"].staticTexts["Details"]
        feeSection = app.tables["receiptDetailTableView"].staticTexts["Fee Specification"]
        transactionSection = app.tables["receiptDetailTableView"].staticTexts["Transaction"]
        receiptIdLabel = app.tables["receiptDetailTableView"].staticTexts["Receipt ID:"]
        dateLabel = app.tables["receiptDetailTableView"].staticTexts["Date:"]
        clientTransactionIdLabel = app.tables["receiptDetailTableView"].staticTexts["Client Transaction ID:"]
        charityNameLabel = app.tables["receiptDetailTableView"].staticTexts["Charity Name:"]
        checkNumLabel = app.tables["receiptDetailTableView"].staticTexts["Check Number:"]
        promoWebSiteLabel = app.tables["receiptDetailTableView"].staticTexts["Promo Website:"]
        noteSectionLabel = app.tables["receiptDetailTableView"].staticTexts["Notes"]
        amountLabel = app.tables["receiptDetailTableView"].staticTexts["Amount:"]
        feeLabel = app.tables["receiptDetailTableView"].staticTexts["Fee:"]
        transactionLabel = app.tables["receiptDetailTableView"].staticTexts["Transaction:"]
        backButton = navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0)

        receiptIdValue = app.tables["receiptDetailTableView"].staticTexts["Receipt ID:_value"]
        dateValue = app.tables["receiptDetailTableView"].staticTexts["Date:_value"]
        clientTransactionIdValue = app.tables["receiptDetailTableView"].staticTexts["Client Transaction ID:_value"]
        charityNameValue = app.tables["receiptDetailTableView"].staticTexts["Charity Name:_value"]
        checkNumValue = app.tables["receiptDetailTableView"].staticTexts["Check Number:_value"]
        websiteValue = app.tables["receiptDetailTableView"].staticTexts["Promo Website:_value"]
        notesValue = app.tables["receiptDetailTableView"].staticTexts["ReceiptDetailSectionNotesTextLabel"]
        amountValue = app.tables["receiptDetailTableView"].staticTexts["Amount:_value"]
        feeValue = app.tables["receiptDetailTableView"].staticTexts["Fee:_value"]
        transactionValue = app.tables["receiptDetailTableView"].staticTexts["Transaction:_value"]
    }

    func openReceipt(row: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: row)
        if row.exists {
            row.tap()
        }
    }
}
