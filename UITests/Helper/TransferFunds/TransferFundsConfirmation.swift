import Common
import XCTest

class TransferFundsConfirmation {
    var app: XCUIApplication

    // Destination Section
    var addSelectDestinationLabel: XCUIElement

    var addSelectDestinationDetailLabel: XCUIElement

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

    init(app: XCUIApplication) {
        self.app = app

        addSelectDestinationLabel = app.tables["scheduleTransferTableView"]
            .staticTexts["transferDestinationTitleLabel"]
        addSelectDestinationDetailLabel = app.tables["scheduleTransferTableView"]
            .staticTexts["transferDestinationSubtitleLabel"]

        summaryTitle = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_section_header_summary".localized()]
        summaryAmountLabel = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_amount_confirmation".localized()]
        summaryFeeLabel = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_fee_confirmation".localized()]
        summaryReceiveLabel = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_net_amount_confirmation".localized()]

        noteLabel = app.tables["scheduleTransferTableView"].staticTexts["NOTES"]

        noteDescription = app.cells.textFields["transferNotesTextField"]

        foreignExchangeSectionLabel = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_section_header_foreignExchange".localized()]
        foreignExchangeSell = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_fx_sell_confirmation".localized()]
        foreignExchangeBuy = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_fx_buy_confirmation".localized()]
        foreignExchangeRate = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_fx_rate_confirmation".localized()]

        confirmButton = app.tables["scheduleTransferTableView"]
            .staticTexts["transfer_button_confirm".localized()]
    }
}
