import Common
import XCTest

// Transfer Funds Page Object
class TransferFunds {
    var app: XCUIApplication

    var transferFundTitle: XCUIElement

    var addSelectDestinationSectionLabel: XCUIElement

    var addSelectDestinationPlaceholderString: String

    var addSelectDestinationLabel: XCUIElement

    var addSelectDestinationDetailLabel: XCUIElement

    var transferSectionLabel: XCUIElement

    var transferAmountLabel: XCUIElement

    var transferAmount: XCUIElement

    var transferCurrency: XCUIElement

    var transferAllFundsLabel: XCUIElement

    var transferAllFundsSwitch: XCUIElement

    var notesSectionLabel: XCUIElement

    var notesPlaceHolderString: String

    var notesDescriptionTextField: XCUIElement

    var notesDescriptionOptionLabel: XCUIElement

    var availableBalance: XCUIElement

    var nextLabel: XCUIElement

    var createTable: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        transferFundTitle = app.navigationBars["Transfer Funds"].staticTexts["Transfer Funds"]
        createTable = app.tables["createTransferTableView"]

        // "DESTINATIONS"
        addSelectDestinationSectionLabel = createTable
            .staticTexts.containing(.staticText, identifier: "DESTINATION")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'DESTINATION'"))
        addSelectDestinationLabel = createTable.staticTexts["transferDestinationTitleLabel"]
        addSelectDestinationPlaceholderString = ""
        addSelectDestinationDetailLabel = createTable.staticTexts["transferDestinationSubtitleLabel"]
        transferSectionLabel = createTable
            .staticTexts.containing(.staticText, identifier: "TRANSFER")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'TRANSFER'"))
        transferAmountLabel = createTable.staticTexts["transferAmountTitleLabel"]
        transferAmount = createTable.textFields["transferAmountTextField"]
        transferCurrency = createTable.staticTexts["transferAmountCurrencyLabel"]
        transferAllFundsLabel = createTable.staticTexts["transferMaxAmountTitleLabel"]
        transferAllFundsSwitch = createTable.switches["transferAllFundsSwitch"]
        notesSectionLabel = createTable
            .staticTexts.containing(.staticText, identifier: "NOTES")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'NOTES'"))
        notesDescriptionTextField = createTable.textFields["transferNotesTextField"]
        notesDescriptionOptionLabel = createTable.staticTexts["receiptTransactionTypeLabel"]
        availableBalance = createTable.staticTexts["mobileAvailableBalance"]
        nextLabel = createTable.staticTexts["createTransferNextLabel"]
    }

    func toggleTransferAllFundsSwitch() {
        transferAllFundsSwitch.tap()
    }

    func enterNotes(description: String) {
        notesDescriptionTextField.clearAndEnterText(text: description)
    }

    func enterTransferAmount(amount: String) {
        transferAmount.clearAndEnterText(text: amount)
    }

    func pasteAmountToTransferAmount(amount: String) {
        UIPasteboard.general.string = amount
        transferAmount.doubleTap()
        app.menuItems["Paste"].tap()
    }

    func tapNextButton() {
        app.scroll(to: nextLabel)
        nextLabel.tap()
    }
}
