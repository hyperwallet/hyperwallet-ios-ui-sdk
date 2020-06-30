import Common
import XCTest

class TransferFundsConfirmation {
    var app: XCUIApplication

    // Destination Section
    var transferDestinationLabel: XCUIElement

    var transferDestinationDetailLabel: XCUIElement

    // Summary Section
    var summaryTitle: XCUIElement

    var summaryAmountLabel: XCUIElement

    var summaryFeeLabel: XCUIElement

    var summaryReceiveLabel: XCUIElement

    // Note Section
    var noteLabel: XCUIElement

    var noteDescription: XCUIElement

    // Exchange Rate Section
    var foreignExchangeSectionLabel: XCUIElement

    var foreignExchangeSell: XCUIElement

    var foreignExchangeBuy: XCUIElement

    var foreignExchangeRate: XCUIElement

    // Confirm button
    var confirmButton: XCUIElement

    var scheduleTable: XCUIElement

    init(app: XCUIApplication) {
        self.app = app
        scheduleTable = app.tables["scheduleTransferTableView"]

        transferDestinationLabel = scheduleTable.staticTexts["transferDestinationTitleLabel"]
        transferDestinationDetailLabel = scheduleTable.staticTexts["transferDestinationSubtitleLabel"]

        summaryTitle = scheduleTable.staticTexts["mobileSummaryLabel".localized()]
        summaryAmountLabel = scheduleTable.staticTexts["mobileConfirmDetailsAmount".localized()]
        summaryFeeLabel = scheduleTable.staticTexts["mobileConfirmDetailsFee".localized()]
        summaryReceiveLabel = scheduleTable.staticTexts["mobileConfirmDetailsTotal".localized()]

        noteLabel = scheduleTable.staticTexts["NOTES"]

        noteDescription = app.cells.textFields["transferNotesTextField"]

        foreignExchangeSectionLabel = scheduleTable.staticTexts["mobileFXlabel".localized()]
        foreignExchangeSell = scheduleTable.staticTexts["mobileFXsell".localized()]
        foreignExchangeBuy = scheduleTable.staticTexts["mobileFXbuy".localized()]
        foreignExchangeRate = scheduleTable.staticTexts["mobileFXRateLabel".localized()]

        if #available(iOS 13.0, *) {
            confirmButton = scheduleTable.cells.buttons["scheduleTransferLabel"]
        } else {
            confirmButton = scheduleTable.cells.staticTexts["scheduleTransferLabel"]
        }
    }

    func tapConfirmButton() {
        app.scroll(to: confirmButton)
        confirmButton.tap()
    }
}
