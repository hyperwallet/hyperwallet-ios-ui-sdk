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

    var transferFundsTable: XCUIElement

    var invalidAmountError: XCUIElement

    var transferMethodRequireError: XCUIElement

    var noteLabel: String

    let title = "Transfer funds"
    let mobileTransferFundsHeader =  "mobileTransferFundsHeader".localized()
    let mobileConfirmationHeader = "mobileConfirmationHeader".localized()
    let mobileTransferToLabel = "mobileTransferToLabel".localized()
    let mobileNoteLabel = "mobileNoteLabel".localized()
    let continueButtonLabel = "continueButtonLabel".localized()
    let transferAmountInvalid = "transferAmountInvalid".localized()
    let noTransferMethodAdded = "noTransferMethodAdded".localized()

    init(app: XCUIApplication) {
        self.app = app
        transferFundTitle = app.navigationBars[title].staticTexts[title]
        transferFundsTable = app.tables["createTransferTableView"]

        // ERROR
        invalidAmountError = transferFundsTable.staticTexts["transferAmountInvalid".localized()]
        transferMethodRequireError = transferFundsTable.staticTexts["noTransferMethodAdded".localized()]

        // "DESTINATIONS"
        addSelectDestinationSectionLabel = transferFundsTable
            .staticTexts[mobileTransferToLabel]
        addSelectDestinationLabel = transferFundsTable.staticTexts["transferDestinationTitleLabel"]
        addSelectDestinationPlaceholderString = ""
        addSelectDestinationDetailLabel = transferFundsTable.staticTexts["transferDestinationSubtitleLabel"]

        transferSectionLabel = transferFundsTable.staticTexts[mobileTransferToLabel]
        transferAmountLabel = transferFundsTable.staticTexts["transferAmountTitleLabel"]
        transferAmount = transferFundsTable.textFields["transferAmountTextField"]
        transferCurrency = transferFundsTable.textFields["transferAmountCurrencyLabel"]
        transferAllFundsLabel = transferFundsTable.staticTexts["transferAllFundsTitleLabel"]
        transferMaxAllFunds = transferFundsTable.buttons["transferMaxAmountTitleLabel"]

        notesSectionLabel = transferFundsTable.staticTexts[mobileNoteLabel]
        noteLabel = "mobileConfirmNotesLabel".localized()
        notesDescriptionTextField = transferFundsTable.textFields["transferNotesTextField"]
        notesDescriptionOptionLabel = transferFundsTable.staticTexts["receiptTransactionTypeLabel"]

        availableBalance = transferFundsTable.staticTexts["available_balance_footer"]
        nextLabel = transferFundsTable.buttons["scheduleTransferLabel"]
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
        sleep(1)
        app.menuItems["Paste"].tap()
        sleep(1)
    }

    func tapContinueButton() {
        app.scroll(to: nextLabel)
        nextLabel.tap()
    }

    func verifyTransferFundsTitle() {
          if #available(iOS 11.4, *) {
              XCTAssertTrue(transferFundTitle.exists)
          } else {
              XCTAssertTrue(app.navigationBars[title].exists)
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
