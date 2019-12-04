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

        summaryTitle = scheduleTable.staticTexts["transfer_section_header_summary".localized()]
        summaryAmountLabel = scheduleTable.staticTexts["transfer_amount_confirmation".localized()]
        summaryFeeLabel = scheduleTable.staticTexts["transfer_fee_confirmation".localized()]
        summaryReceiveLabel = scheduleTable.staticTexts["transfer_net_amount_confirmation".localized()]

        noteLabel = scheduleTable.staticTexts["NOTES"]

        noteDescription = app.cells.textFields["transferNotesTextField"]

        foreignExchangeSectionLabel = scheduleTable.staticTexts["transfer_section_header_foreignExchange".localized()]
        foreignExchangeSell = scheduleTable.staticTexts["transfer_fx_sell_confirmation".localized()]
        foreignExchangeBuy = scheduleTable.staticTexts["transfer_fx_buy_confirmation".localized()]
        foreignExchangeRate = scheduleTable.staticTexts["transfer_fx_rate_confirmation".localized()]

        confirmButton = scheduleTable.cells.staticTexts["scheduleTransferLabel"]
    }

    func tapConfirmButton() {
        app.scroll(to: confirmButton)
        confirmButton.tap()
    }
}
