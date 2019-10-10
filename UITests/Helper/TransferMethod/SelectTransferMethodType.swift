import XCTest

class SelectTransferMethodType {
    let defaultTimeout = 5.0

    var app: XCUIApplication

    var countrySelect: XCUIElement
    var currencySelect: XCUIElement
    var countryTable: XCUIElement
    var currencyTable: XCUIElement
    var searchBar: XCUIElement
    var navigationBar: XCUIElement

    init(app: XCUIApplication) {
        self.app = app

        countrySelect = app.tables.cells["cellCountry"].staticTexts["Country"]
        currencySelect = app.tables.cells["cellCurrency"].staticTexts["Currency"]
        countryTable = app.otherElements.containing(.navigationBar, identifier: "Select Country").element
        currencyTable = app.otherElements.containing(.navigationBar, identifier: "Select Currency").element
        searchBar = app.searchFields["search"]
        navigationBar = app.navigationBars["Add Account"]
    }

    func tapCountry() {
        countrySelect.tap()
        _ = countryTable.waitForExistence(timeout: defaultTimeout)
    }

    func tapCurrency() {
        currencySelect.tap()
        _ = currencyTable.waitForExistence(timeout: defaultTimeout)
    }

    func selectCountry(country: String) {
        tapCountry()
        app.tables.staticTexts[country].tap()
    }

    func selectCurrency(currency: String) {
        tapCurrency()

       //app.tables.staticTexts[currency].tap()
        app.tables.cells.containing(.staticText, identifier: currency).element.tap()
    }

    func typeSearch(input: String) {
        searchBar.tap()
        app.typeText(input)
    }

    func clickBackButton() {
        navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
    }
}
