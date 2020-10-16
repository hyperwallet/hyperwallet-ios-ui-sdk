import Common
import XCTest

class TransferFundsConfirmation {
    var app: XCUIApplication

    // Sourcee Section
    var tranferFromSectionLabel: XCUIElement

    var transferSourceTitleLabel: XCUIElement

    var transferSourceSubtitleLabel: XCUIElement

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
    var successAlert: XCUIElement

    var confirmButton: XCUIElement

    var scheduleTable: XCUIElement

    let successMessageTitle = "mobileTransferSuccessMsg".localized()

    let messagePlaceholder = "mobileTransferSuccessDetails".localized()

    let message: String

    let confirmButtonAccessbility = "scheduleTransferLabel"
    let tableAccessibility = "scheduleTransferTableView"

    // Transfer From
    let transferFrom = "mobileTransferFromLabel".localized()

    let availableFunds = "mobileAvailableFunds".localized()

    let prepaidCard = "prepaid_card".localized()

    let numberMask = " \u{2022}\u{2022}\u{2022}\u{2022} "

    init(app: XCUIApplication) {
        self.app = app
        scheduleTable = app.tables[tableAccessibility]

        // Source
        tranferFromSectionLabel = scheduleTable.staticTexts[transferFrom]
        transferSourceTitleLabel = scheduleTable.staticTexts["transferSourceTitleLabel"]
        transferSourceSubtitleLabel = scheduleTable.staticTexts["transferSourceSubtitleLabel"]

        // Destination
        tranferToSectionLabel = scheduleTable.staticTexts["mobileTransferToLabel".localized()]
        transferDestinationLabel = scheduleTable.staticTexts["transferDestinationTitleLabel"]
        transferDestinationDetailLabel = scheduleTable.staticTexts["transferDestinationSubtitleLabel"]

        // Summary
        summaryTitle = scheduleTable.staticTexts["mobileSummaryLabel".localized()]
        summaryAmount = scheduleTable.staticTexts["mobileConfirmDetailsAmount".localized()]
        summaryFee = scheduleTable.staticTexts["mobileConfirmDetailsFee".localized()]
        summaryReceive = scheduleTable.staticTexts["mobileConfirmDetailsTotal".localized()]
        summaryAmountLabel = "mobileConfirmDetailsAmount".localized()
        summaryFeeLabel = "mobileConfirmDetailsFee".localized()
        summaryReceiveLabel = "mobileConfirmDetailsTotal".localized()

        // Note
        noteLabel = scheduleTable.staticTexts["mobileNoteLabel".localized()]
        noteDescription = scheduleTable.textFields["transferNotesTextField"]

        // FX
        foreignExchangeSectionLabel = scheduleTable.staticTexts["mobileFXlabel".localized()]
        foreignExchangeSell = scheduleTable.staticTexts["mobileFXsell".localized()]
        foreignExchangeBuy = scheduleTable.staticTexts["mobileFXbuy".localized()]
        foreignExchangeRate = scheduleTable.staticTexts["mobileFXRateLabel".localized()]
        foreignExchangeSellLabel = "mobileFXsell".localized()
        foreignExchangeBuyLabel = "mobileFXbuy".localized()
        foreignExchangeRateLabel = "mobileFXRateLabel".localized()

        // Confirmation Button
        if #available(iOS 13.0, *) {
            confirmButton = scheduleTable.buttons[confirmButtonAccessbility]
        } else {
            confirmButton = scheduleTable.staticTexts[confirmButtonAccessbility]
        }

        successAlert = app.alerts[successMessageTitle]
        message = String(format: messagePlaceholder, "Bank Account")
    }

    // MARK: helper method for verifications
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

    func verifySummary() {
        XCTAssertEqual(summaryTitle.label, "mobileSummaryLabel".localized())
        XCTAssertEqual(summaryAmount.label, summaryAmountLabel)
        XCTAssertEqual(summaryFee.label, summaryFeeLabel)
        XCTAssertEqual(summaryReceive.label, summaryReceiveLabel)
    }

    func verifyConfirmationSuccess() {
        let predicate = NSPredicate(format:
            "label CONTAINS[c] '\(message)'")
        XCTAssert(successAlert.staticTexts.element(matching: predicate).exists)
        successAlert.buttons["doneButtonLabel".localized()].tap()
    }

    func verifyTransferFrom(isAvailableFunds: Bool) {
        // Transfer From
        XCTAssertTrue(transferSourceTitleLabel.exists)
        if isAvailableFunds == true {
            XCTAssertEqual(transferSourceTitleLabel.label, "\(availableFunds)")
        } else {
            XCTAssertEqual(transferSourceTitleLabel.label, "\(prepaidCard)")
        }
        XCTAssertTrue(tranferFromSectionLabel.exists)
        XCTAssertEqual(tranferFromSectionLabel.label, transferFrom)
    }

    func verifyPPCInfo(brandType: String, endingDigit: String) {
        let info = "\(brandType)\(numberMask)\(endingDigit)"
        XCTAssertEqual(transferSourceSubtitleLabel.label, info)
    }
}
