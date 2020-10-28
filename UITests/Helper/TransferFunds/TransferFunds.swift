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

    let mobileTransferFundsHeader =  "mobileTransferFundsHeader".localized()
    let mobileConfirmationHeader = "mobileConfirmationHeader".localized()
    let mobileTransferToLabel = "mobileTransferToLabel".localized()
    let mobileNoteLabel = "mobileNoteLabel".localized()
    let continueButtonLabel = "continueButtonLabel".localized()
    let transferAmountInvalid = "transferAmountInvalid".localized()
    let noTransferMethodAdded = "noTransferMethodAdded".localized()

    let endingIn: String = "endingIn".localized()

    let title = "mobileTransferFundsHeader".localized()

    // "Available funds %1$@%2$@ %3$@"
    let availableBalanceFormat = "mobileAvailableBalance".localized()

    let availableFunds = "mobileAvailableFunds".localized()

    let prepaidCard = "prepaid_card".localized()

    let prepaidCardVisa = "visa".localized()

    let prepaidCardMaster = "mastercard".localized()

    let numberMask = " \u{2022}\u{2022}\u{2022}\u{2022} "

    // "Total: %1$@%2$@ %3$@"
    let transferFromTotal = "total".localized()

    let transferSourceSubtitleLabel: XCUIElement

    var transferSourceTitleLabel: XCUIElement

    var transferFromSectionLabel: XCUIElement

    let transferFrom = "mobileTransferFromLabel".localized()

    let transferTo = "mobileTransferToLabel".localized()

    var navigationTransferFrom: XCUIElement

    let transferFromHeaderLabel = "mobileTransferFromHeader".localized()

    init(app: XCUIApplication) {
        self.app = app
        transferFundTitle = app.navigationBars[title].staticTexts[title]
        transferFundsTable = app.tables["createTransferTableView"]

        // ERROR
        invalidAmountError = transferFundsTable.staticTexts["transferAmountInvalid".localized()]
        transferMethodRequireError = transferFundsTable.staticTexts["noTransferMethodAdded".localized()]

        // TRANSFER FROM
        transferFromSectionLabel = transferFundsTable
            .staticTexts.containing(.staticText, identifier: "TRANSFER FROM")
            .element(matching: NSPredicate(format: "label CONTAINS[c] '\(transferFrom)'"))
        transferSourceTitleLabel = transferFundsTable.staticTexts["transferSourceTitleLabel"]

        transferSourceSubtitleLabel = transferFundsTable.staticTexts["transferSourceSubtitleLabel"]
        navigationTransferFrom = app.navigationBars["Transfer From"].staticTexts["Transfer From"]

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
        transferAmount.clearAmountFieldAndEnterText(text: amount)
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

    func verifyPrepaidCardDestination(brandType: String, endingDigit: String) {
        app.scroll(to: addSelectDestinationSectionLabel)
        XCTAssertTrue(addSelectDestinationSectionLabel.exists)
        XCTAssertEqual(addSelectDestinationLabel.label, prepaidCard)
        let destinationDetail = addSelectDestinationDetailLabel.label
        XCTAssertTrue(destinationDetail == "United States\n\(brandType)\(numberMask)\(endingDigit)"
            || destinationDetail == "United States \(brandType)\(numberMask)\(endingDigit)")
    }

    func getDestinationLabel(country: String, type: String, endingDigit: String) -> String {
        return "\(country)\n\(endingIn)\(endingDigit)"
    }

    func verifyNotes() {
        if #available(iOS 11.0, *) {
            enterNotes(description: "testing")
            XCTAssertEqual(notesDescriptionTextField.value as? String, "testing")
        }
    }

    // Verify Transfer From Source Title label
    func verifyTransferFrom(isAvailableFunds: Bool) {
        // Transfer From
        XCTAssertTrue(transferSourceTitleLabel.exists)
        if isAvailableFunds == true {
            XCTAssertEqual(transferSourceTitleLabel.label, "\(availableFunds)")
        } else {
            XCTAssertEqual(transferSourceTitleLabel.label, "\(prepaidCard)")
        }

        XCTAssertTrue(transferFromSectionLabel.exists)
        XCTAssertEqual(transferFromSectionLabel.label, transferFrom)
    }

    // Verify Transfer From Source Sub-title label
    func verifyPPCInfo(brandType: String, endingDigit: String) {
        let info = "\(brandType)\(numberMask)\(endingDigit)"
        XCTAssertEqual(transferSourceSubtitleLabel.label, info)
    }

    // Transfer from row title
    func getSelectSourceRowTitle(index: Int) -> String {
        let row = app.tables.element.children(matching: .cell).element(boundBy: index)
        return row.staticTexts["transferSourceTitleLabel"].label
    }

    // Transfer from row detail
    func getSelectSourceRowDetail(index: Int) -> String {
        let row = app.tables.element.children(matching: .cell).element(boundBy: index)
        return row.staticTexts["transferSourceSubtitleLabel"].label
    }

    func getPPCInfo(brandType: String, endingDigit: String) -> String {
        return "\(brandType)\(numberMask)\(endingDigit)"
    }

    func getTransferFromTitle() -> XCUIElement {
        if #available(iOS 13.0, *) {
            navigationTransferFrom = app.navigationBars["Transfer From"].staticTexts["Transfer From"]
        } else {
            navigationTransferFrom = app.navigationBars["Transfer From"].otherElements["Transfer From"]
        }
        return navigationTransferFrom
    }
}
