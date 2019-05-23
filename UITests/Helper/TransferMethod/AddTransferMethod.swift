import XCTest

enum AccountType: String {
    case bankAccount = "Bank Account"
    case debitCard = "Debit Card"
    case payPalAccount = "PayPal"
}

class AddTransferMethod {
    let defaultTimeout = 5.0

    var app: XCUIApplication

    var addTMTableView: XCUIElement
    var branchIdInput: XCUIElement
    var accountNumberInput: XCUIElement
    var accountTypeSelect: XCUIElement
    var createTransferMethodButton: XCUIElement
    var cardNumberInput: XCUIElement
    var cvvInput: XCUIElement
    var dateOfExpiryInput: XCUIElement
    var emailInput: XCUIElement
    var title: XCUIElement
    var navigationBar: XCUIElement
    var relationshipSelect: XCUIElement

    init(app: XCUIApplication, for accountType: AccountType) {
        self.app = app

        addTMTableView = app.tables["addTransferMethodTable"]
        branchIdInput = addTMTableView.textFields["branchId"]
        accountNumberInput = addTMTableView.textFields["bankAccountId"]
        accountTypeSelect = addTMTableView.cells.staticTexts["Account Type"]
        createTransferMethodButton = addTMTableView.cells.containing(.button,
                                                                     identifier: "createAccountBtn")
            .buttons["createAccountBtn"]
        cardNumberInput = addTMTableView.textFields["cardNumber"]
        dateOfExpiryInput = addTMTableView.textFields["dateOfExpiry"]
        cvvInput = addTMTableView.textFields["cvv"]
        emailInput = addTMTableView.textFields["email"]
        title = addTMTableView.staticTexts["Account Information - United States (USD)"]
        navigationBar = app.navigationBars[accountType.rawValue]
        relationshipSelect = addTMTableView.cells.staticTexts["Relationship"]
    }

    func setBranchId(branchId: String) {
        branchIdInput.tap()
        app.typeText(branchId)

        title.tap()
    }

    func setAccountNumber(accountNumber: String) {
        accountNumberInput.tap()
        app.typeText(accountNumber)
        title.tap()
    }

    func selectAccountType(accountType: String) {
        accountTypeSelect.tap()
        app.tables.staticTexts[accountType].tap()
    }

    func selectRelationship(type: String) {
        relationshipSelect.tap()
        app.tables.staticTexts[type].tap()
    }

    func clickCreateTransferMethodButton() {
        if !createTransferMethodButton.exists {
            addTMTableView.scrollToElement(element: createTransferMethodButton)
        }

        createTransferMethodButton.tap()
    }

    func setCardNumber(cardNumber: String) {
        cardNumberInput.tap()
        app.typeText(cardNumber)
        title.tap()
    }

    func setDateOfExpiry(expiryMonth: String, expiryYear: String) {
        dateOfExpiryInput.tap()

        // Supporting multiple localizations for month and year
        let dateComponent = Calendar.current.dateComponents([.month, .year], from: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let monthText = formatter.string(from: Date())

        // Selecting year and month from PickerWheel
        app.pickerWheels[String(dateComponent.year!)].adjust(toPickerWheelValue: expiryYear)
        app.pickerWheels[monthText].adjust(toPickerWheelValue: expiryMonth)
        app.toolbars.buttons["Done"].tap()
    }

    func clickBackButton() {
        navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
    }

    func setCvv(cvvNumber: String) {
        cvvInput.tap()
        app.typeText(cvvNumber)
        title.tap()
    }

    func setEmail(email: String) {
        emailInput.tap()
        app.typeText(email)
        title.tap()
    }
}
