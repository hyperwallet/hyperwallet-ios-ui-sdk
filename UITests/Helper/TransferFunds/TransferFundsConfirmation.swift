import Common
import XCTest

class TransferFundsConfirmation {
    var app: XCUIApplication

    // Destination Section
    var tranferToSectionLabel: XCUIElement
    var transferDestinationLabel: XCUIElement

    var transferDestinationDetailLabel: XCUIElement

    // Summary Section
    var summaryTitle: XCUIElement

    var summaryAmount: XCUIElement

    var summaryFee: XCUIElement

    var summaryReceive: XCUIElement

    var summaryAmountLabel: String

    var summaryFeeLabel: String

    var summaryReceiveLabel: String

    // Note Section
    var noteLabel: XCUIElement

    var noteDescription: XCUIElement

    // Exchange Rate Section
    var foreignExchangeSectionLabel: XCUIElement

    var foreignExchangeSell: XCUIElement

    var foreignExchangeBuy: XCUIElement

    var foreignExchangeRate: XCUIElement

    var foreignExchangeSellLabel: String

    var foreignExchangeBuyLabel: String

    var foreignExchangeRateLabel: String

    // Confirm button
    var confirmButton: XCUIElement

    var scheduleTable: XCUIElement

    let confirmButtonAccessbility = "scheduleTransferLabel"
    let tableAccessibility = "scheduleTransferTableView"

    init(app: XCUIApplication) {
        self.app = app
        scheduleTable = app.tables[tableAccessibility]

        tranferToSectionLabel = scheduleTable.staticTexts["mobileTransferToLabel".localized()]
        transferDestinationLabel = scheduleTable.staticTexts["transferDestinationTitleLabel"]
        transferDestinationDetailLabel = scheduleTable.staticTexts["transferDestinationSubtitleLabel"]

        summaryTitle = scheduleTable.staticTexts["mobileSummaryLabel".localized()]
        summaryAmount = scheduleTable.staticTexts["mobileConfirmDetailsAmount".localized()]
        summaryFee = scheduleTable.staticTexts["mobileConfirmDetailsFee".localized()]
        summaryReceive = scheduleTable.staticTexts["mobileConfirmDetailsTotal".localized()]
        summaryAmountLabel = "mobileConfirmDetailsAmount".localized()
        summaryFeeLabel = "mobileConfirmDetailsFee".localized()
        summaryReceiveLabel = "mobileConfirmDetailsTotal".localized()

        noteLabel = scheduleTable.staticTexts["mobileNoteLabel".localized()]

        noteDescription = scheduleTable.textFields["transferNotesTextField"]

        foreignExchangeSectionLabel = scheduleTable.staticTexts["mobileFXlabel".localized()]
        foreignExchangeSell = scheduleTable.staticTexts["mobileFXsell".localized()]
        foreignExchangeBuy = scheduleTable.staticTexts["mobileFXbuy".localized()]
        foreignExchangeRate = scheduleTable.staticTexts["mobileFXRateLabel".localized()]
        foreignExchangeSellLabel = "mobileFXsell".localized()
        foreignExchangeBuyLabel = "mobileFXbuy".localized()
        foreignExchangeRateLabel = "mobileFXRateLabel".localized()

        if #available(iOS 13.0, *) {
            confirmButton = scheduleTable.buttons[confirmButtonAccessbility]
        } else {
            confirmButton = scheduleTable.staticTexts[confirmButtonAccessbility]
        }
    }

    func verifyDestination(country: String, endingDigit: String) {
        XCTAssertTrue(transferDestinationDetailLabel.exists)
        let destinationDetail = transferDestinationDetailLabel.label
        XCTAssertTrue(destinationDetail == "\(country)\nending in \(endingDigit)"
            || destinationDetail == "\(country) ending in \(endingDigit)")
    }

    func getCell(row: Int) -> XCUIElement {
        let cell = scheduleTable.children(matching: .cell).element(boundBy: row)
        XCTAssert(cell.exists)
        return cell
    }

    func tapConfirmButton() {
//        if #available(iOS 13.0, *) {
//            confirmButton = scheduleTable.buttons[confirmButtonAccessbility]
//        } else {
//            confirmButton = scheduleTable.staticTexts[confirmButtonAccessbility]
//        }

        app.scroll(to: confirmButton)
        XCTAssertTrue(confirmButton.exists)
        if confirmButton.isHittable {
            confirmButton.tap()
        }
    }
}
