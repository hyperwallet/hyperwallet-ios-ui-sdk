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
    let prepaidCard = "prepaid_card".localized()
    let prepaidCardVisa = "visa".localized()
    let prepaidCardMaster = "mastercard".localized()
    let numberMask = " \u{2022}\u{2022}\u{2022}\u{2022} "
    let noPPCReceiptLabel: XCUIElement

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
        noPPCReceiptLabel = app.staticTexts["EmptyListLabelAccessibilityIdentifier"]
        navigationBar = app.navigationBars["Transaction Details"]
        typeLabel = app.tables["receiptDetailTableView"].buttons["receiptTransactionTypeLabel"]
        paymentAmountLabel = app.tables["receiptDetailTableView"].buttons["receiptTransactionAmountLabel"]
        createdOnLabel = app.tables["receiptDetailTableView"].buttons["receiptTransactionCreatedOnLabel"]
        currencyLabel = app.tables["receiptDetailTableView"].buttons["receiptTransactionCurrencyLabel"]

        detailSection = app.tables["receiptDetailTableView"].staticTexts["mobileTransactionDetailsLabel".localized()]
        feeSection = app.tables["receiptDetailTableView"].staticTexts["mobileFeeInfoLabel".localized()]
        transactionSection = app.tables["receiptDetailTableView"].staticTexts["mobileTransactionTypeLabel".localized()]
        receiptIdLabel = app.tables["receiptDetailTableView"].buttons["journalIdLabel"]
        receiptIdValue = app.tables["receiptDetailTableView"].buttons["journalIdValue"]
        dateLabel = app.tables["receiptDetailTableView"].buttons["createdOnLabel"]
        dateValue = app.tables["receiptDetailTableView"].buttons["createdOnValue"]
        clientTransactionIdLabel = app.tables["receiptDetailTableView"].buttons["clientPaymentIdLabel"]
        clientTransactionIdValue = app.tables["receiptDetailTableView"].buttons["clientPaymentIdValue"]

        charityNameLabel = app.tables["receiptDetailTableView"].buttons["charityNameLabel"]
        charityNameValue = app.tables["receiptDetailTableView"].buttons["charityNameValue"]
        checkNumLabel = app.tables["receiptDetailTableView"].buttons["checkNumberLabel"]
        checkNumValue = app.tables["receiptDetailTableView"].buttons["checkNumberValue"]
        promoWebSiteLabel = app.tables["receiptDetailTableView"].buttons["websiteLabel"]
        promoWebSiteValue = app.tables["receiptDetailTableView"].buttons["websiteValue"]

        noteSectionLabel = app.tables["receiptDetailTableView"].staticTexts["mobileConfirmNotesLabel".localized()]

        amountLabel = app.tables["receiptDetailTableView"].buttons["amountLabel"]
        amountValue = app.tables["receiptDetailTableView"].buttons["amountValue"]
        feeLabel = app.tables["receiptDetailTableView"].buttons["feeLabel"]
        feeValue = app.tables["receiptDetailTableView"].buttons["feeValue"]
        transactionLabel = app.tables["receiptDetailTableView"].buttons["transactionLabel"]
        transactionValue = app.tables["receiptDetailTableView"].buttons["transactionValue"]
        backButton = navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0)

        notesValue = app.tables["receiptDetailTableView"].buttons["ReceiptDetailSectionNotesTextLabel"]

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

    func getPPCTabBy(label: String) -> XCUIElement {
        app.tables.buttons[label]
    }
    func getTransactionsPPCTabBy(label: String) -> XCUIElement {
        app.tables.buttons[label]
    }
    func getPPCInfoTab(digit: String, type: String) -> String {
        return "\(type)\(numberMask)\(digit)"
    }
    func getNoTransactionStrings() -> String {
        return "mobileNoTransactions".localized()
    }
    func getPPCNoTransactionStringYear() -> String {
        return "mobilePrepaidCardNoTransactions".localized()
    }
}
