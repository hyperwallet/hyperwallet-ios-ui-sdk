import XCTest

class TransactionDetails {
    var navigationBar: XCUIElement
    // Sections
    var detailSection: XCUIElement
    var feeSection: XCUIElement
    var transactionSection: XCUIElement
    // Payment
    var paymentLabel: XCUIElement
    var paymentAmountLabel: XCUIElement
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
    var notesValue: XCUIElement
    var amountValue: XCUIElement
    var feeValue: XCUIElement
    var transactionValue: XCUIElement
    var promoWebSiteValue: XCUIElement

    var app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
        navigationBar = app.navigationBars["Transaction Details"]
        detailHeaderTitle = app.navigationBars["Transaction Details"].otherElements["Transaction Details"]
        paymentLabel = app.tables["receiptDetailTableView"].staticTexts["ListReceiptTableViewCellTextLabel"]
        paymentAmountLabel = app.tables["receiptDetailTableView"].staticTexts["ListReceiptTableViewCellDetailTextLabel"]
        detailSection = app.tables["receiptDetailTableView"].staticTexts["Details"]
        feeSection = app.tables["receiptDetailTableView"].staticTexts["Fee Specification"]
        transactionSection = app.tables["receiptDetailTableView"].staticTexts["Transaction"]
        receiptIdLabel = app.tables["receiptDetailTableView"].staticTexts["journalIdLabel"]
        receiptIdValue = app.tables["receiptDetailTableView"].staticTexts["journalIdValue"]
        dateLabel = app.tables["receiptDetailTableView"].staticTexts["createdOnLabel"]
        dateValue = app.tables["receiptDetailTableView"].staticTexts["createdOnValue"]
        clientTransactionIdLabel = app.tables["receiptDetailTableView"].staticTexts["clientPaymentIdLabel"]
        clientTransactionIdValue = app.tables["receiptDetailTableView"].staticTexts["clientPaymentIdValue"]

        charityNameLabel = app.tables["receiptDetailTableView"].staticTexts["charityNameLabel"]
        charityNameValue = app.tables["receiptDetailTableView"].staticTexts["charityNameValue"]
        checkNumLabel = app.tables["receiptDetailTableView"].staticTexts["checkNumberLabel"]
        checkNumValue = app.tables["receiptDetailTableView"].staticTexts["checkNumberValue"]
        promoWebSiteLabel = app.tables["receiptDetailTableView"].staticTexts["websiteLabel"]
        promoWebSiteValue = app.tables["receiptDetailTableView"].staticTexts["websiteValue"]

        noteSectionLabel = app.tables["receiptDetailTableView"].staticTexts["Notes"]

        amountLabel = app.tables["receiptDetailTableView"].staticTexts["amountLabel"]
        amountValue = app.tables["receiptDetailTableView"].staticTexts["amountValue"]
        feeLabel = app.tables["receiptDetailTableView"].staticTexts["feeLabel"]
        feeValue = app.tables["receiptDetailTableView"].staticTexts["feeValue"]
        transactionLabel = app.tables["receiptDetailTableView"].staticTexts["transactionLabel"]
        transactionValue = app.tables["receiptDetailTableView"].staticTexts["transactionValue"]
        backButton = navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0)

        notesValue = app.tables["receiptDetailTableView"].staticTexts["ReceiptDetailSectionNotesTextLabel"]
    }

    func openReceipt(row: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: row)
        if row.exists {
            row.tap()
        }
    }
}
