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

        countrySelect = app.tables.cells["cellCountry/Region"].staticTexts["mobileCountryRegion".localized()]
        currencySelect = app.tables.cells["cellCurrency"].staticTexts["mobileCurrencyLabel".localized()]
        countryTable = app.otherElements.containing(.navigationBar,
                                                    identifier: "mobileCountryRegion".localized()).element
        currencyTable = app.otherElements.containing(.navigationBar,
                                                     identifier: "mobileCurrencyLabel".localized()).element
        searchBar = app.searchFields["search_placeholder_label".localized()]
        navigationBar = app.navigationBars["mobileAddTransferMethodHeader".localized()]
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

       // app.tables.staticTexts[currency].tap()
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
