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

    init(app: XCUIApplication) {
        self.app = app

        transferFundTitle = app.navigationBars["Transfer Funds"].staticTexts["Transfer Funds"]

        // "DESTINATIONS"

        addSelectDestinationSectionLabel =
            app.tables["createTransferTableView"]
                .staticTexts.containing(.staticText, identifier: "DESTINATION")
                .element(matching: NSPredicate(format: "label CONTAINS[c] 'DESTINATION'"))

        addSelectDestinationLabel = app.tables["createTransferTableView"].staticTexts["transferDestinationTitleLabel"]

        addSelectDestinationPlaceholderString = ""

        addSelectDestinationDetailLabel = app.tables["createTransferTableView"].staticTexts["transferDestinationSubtitleLabel"]

        transferSectionLabel = app.tables["createTransferTableView"]
            .staticTexts.containing(.staticText, identifier: "TRANSFER")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'TRANSFER'"))

        transferAmountLabel = app.tables["createTransferTableView"].staticTexts["transferAmountTitleLabel"]

        transferAmount = app.tables["createTransferTableView"].textFields["transferAmountTextField"]

        transferCurrency = app.tables["createTransferTableView"].staticTexts["transferAmountCurrencyLabel"]

        transferAllFundsLabel = app.tables["createTransferTableView"].staticTexts["transferAllFundsTitleLabel"]

        transferAllFundsSwitch = app.tables["createTransferTableView"].switches["transferAllFundsSwitch"]

        notesSectionLabel = app.tables["createTransferTableView"] .staticTexts.containing(.staticText, identifier: "NOTES")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'NOTES'"))

        notesPlaceHolderString = "transfer_description".localized()

        notesDescriptionTextField = app.tables["createTransferTableView"].textFields["transferNotesTextField"]

        notesDescriptionOptionLabel = app.tables["createTransferTableView"].staticTexts["receiptTransactionTypeLabel"]

        availableBalance = app.tables["createTransferTableView"].staticTexts["available_balance_footer"]

        nextLabel = app.tables["createTransferTableView"].staticTexts["addTransferNextLabel"]
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
}
