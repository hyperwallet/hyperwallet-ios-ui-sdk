import HyperwalletSDK
import XCTest

class TransactionDetails {
    var navigationBar: XCUIElement
    // Sections
    var detailSection: XCUIElement
    var feeSection: XCUIElement
    var transactionSection: XCUIElement
    // Payment
    var typeLabel: XCUIElement
    var paymentAmountLabel: XCUIElement
    var createdOnLabel: XCUIElement
    var currencyLabel: XCUIElement
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

    let dateFormatterDateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yMMMEdjm")
        formatter.formattingContext = .beginningOfSentence
        // try to add this
        formatter.locale = Locale(identifier: Locale.preferredLanguages[0])
        return formatter
    }()

    let localizedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yMMMMd")
        formatter.formattingContext = .beginningOfSentence
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: Locale.preferredLanguages[0])
        return formatter
    }()

    init(app: XCUIApplication) {
        self.app = app
        navigationBar = app.navigationBars["Transaction Details"]
        typeLabel = app.tables["receiptDetailTableView"].staticTexts["receiptTransactionTypeLabel"]
        paymentAmountLabel = app.tables["receiptDetailTableView"].staticTexts["receiptTransactionAmountLabel"]
        createdOnLabel = app.tables["receiptDetailTableView"].staticTexts["receiptTransactionCreatedOnLabel"]
        currencyLabel = app.tables["receiptDetailTableView"].staticTexts["receiptTransactionCurrencyLabel"]

        detailSection = app.tables["receiptDetailTableView"].staticTexts["mobileTransactionDetailsLabel".localized()]
        feeSection = app.tables["receiptDetailTableView"].staticTexts["mobileFeeInfoLabel".localized()]
        transactionSection = app.tables["receiptDetailTableView"].staticTexts["mobileTransactionTypeLabel".localized()]
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

        noteSectionLabel = app.tables["receiptDetailTableView"].staticTexts["mobileConfirmNotesLabel".localized()]

        amountLabel = app.tables["receiptDetailTableView"].staticTexts["amountLabel"]
        amountValue = app.tables["receiptDetailTableView"].staticTexts["amountValue"]
        feeLabel = app.tables["receiptDetailTableView"].staticTexts["feeLabel"]
        feeValue = app.tables["receiptDetailTableView"].staticTexts["feeValue"]
        transactionLabel = app.tables["receiptDetailTableView"].staticTexts["transactionLabel"]
        transactionValue = app.tables["receiptDetailTableView"].staticTexts["transactionValue"]
        backButton = navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0)

        notesValue = app.tables["receiptDetailTableView"].staticTexts["ReceiptDetailSectionNotesTextLabel"]

        if #available(iOS 13.0, *) {
            detailHeaderTitle = app.navigationBars["mobileTransactionDetailsHeader".localized()]
                .staticTexts["mobileTransactionDetailsHeader".localized()]
        } else {
            detailHeaderTitle = app.navigationBars["mobileTransactionDetailsHeader".localized()]
                .otherElements["mobileTransactionDetailsHeader".localized()]
        }
    }

    func openReceipt(row: Int) {
        let row = app.tables.element.children(matching: .cell).element(boundBy: row)
        if row.exists {
            row.tap()
        }
    }

    func getExpectedDateTimeFormat(datetime: String) -> String {
        let dateUTC = ISO8601DateFormatter.ignoreTimeZone.date(from: datetime)
        return dateFormatterDateAndTime.string(from: dateUTC!)
    }

    func getExpectedDate(date: String) -> String {
        let dateUTC = ISO8601DateFormatter.ignoreTimeZone.date(from: date)
        print(localizedDateFormatter.string(from: dateUTC!))
        return localizedDateFormatter.string(from: dateUTC!)
    }
}
