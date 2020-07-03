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

    var transferMaxAllFunds: XCUIElement

    var notesSectionLabel: XCUIElement

    var notesDescriptionTextField: XCUIElement

    var notesDescriptionOptionLabel: XCUIElement

    var availableBalance: XCUIElement

    var nextLabel: XCUIElement

    var createTable: XCUIElement

    var invalidAmountError: XCUIElement

    var transferMethodRequireError: XCUIElement

    var noteLabel: String

    init(app: XCUIApplication) {
        self.app = app
        let title = "Transfer funds"
        transferFundTitle = app.navigationBars[title].staticTexts[title]
        createTable = app.tables["createTransferTableView"]

        // ERROR
        invalidAmountError = createTable.staticTexts["transferAmountInvalid".localized()]
        transferMethodRequireError = createTable.staticTexts["noTransferMethodAdded".localized()]

        // "DESTINATIONS"
        addSelectDestinationSectionLabel = createTable
            .staticTexts["mobileTransferToLabel".localized()]
        addSelectDestinationLabel = createTable.staticTexts["transferDestinationTitleLabel"]
        addSelectDestinationPlaceholderString = ""
        addSelectDestinationDetailLabel = createTable.staticTexts["transferDestinationSubtitleLabel"]
        transferSectionLabel = createTable
            .staticTexts.containing(.staticText, identifier: "TRANSFER TO")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'TRANSFER'"))
        transferAmountLabel = createTable.staticTexts["transferAmountTitleLabel"]
        transferAmount = createTable.textFields["transferAmountTextField"]
        transferCurrency = createTable.textFields["transferAmountCurrencyLabel"]
        transferAllFundsLabel = createTable.staticTexts["transferAllFundsTitleLabel"]
        transferMaxAllFunds = createTable.buttons["transferMaxAmountTitleLabel"]
        notesSectionLabel = createTable
            .staticTexts.containing(.staticText, identifier: "NOTES")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'NOTES'"))
        notesSectionLabel = createTable.staticTexts["Note"]
        noteLabel = "mobileConfirmNotesLabel".localized()

        //notesPlaceHolderString = "transfer_description".localized()
        notesDescriptionTextField = createTable.textFields["transferNotesTextField"]
        notesDescriptionOptionLabel = createTable.staticTexts["receiptTransactionTypeLabel"]
        availableBalance = createTable.staticTexts["available_balance_footer"]
        nextLabel = createTable.buttons["scheduleTransferLabel"]
    }

    func tabTransferMaxFunds() {
        // transferMaxAllFunds.tap()
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

    func tapContinueButton() {
        app.scroll(to: nextLabel)
        nextLabel.tap()
    }

    func verifyTransferFundsTitle() {
          if #available(iOS 11.4, *) {
              XCTAssertTrue(transferFundTitle.exists)
          } else {
              XCTAssertTrue(app.navigationBars["Transfer funds"].exists)
          }
      }

    func verifyBankAccountDestination(type: String, endingDigit: String) {
          XCTAssertTrue(addSelectDestinationSectionLabel.exists)
          XCTAssertEqual(addSelectDestinationLabel.label, type)

          let destinationDetail = addSelectDestinationDetailLabel.label
          XCTAssertTrue(destinationDetail == "United States\nending in \(endingDigit)"
              || destinationDetail == "United States ending in \(endingDigit)")
      }

    func verifyNotes() {
        if #available(iOS 11.0, *) {
            enterNotes(description: "testing")
            XCTAssertEqual(notesDescriptionTextField.value as? String, "testing")
        }
    }
}
