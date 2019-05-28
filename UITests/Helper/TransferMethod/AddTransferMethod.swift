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

    var selectRelationshipType: XCUIElement
    var inputNameFirst: XCUIElement
    var inputNameLast: XCUIElement
    var inputNameMiddle: XCUIElement
    var inputPhoneNumber: XCUIElement
    var inputMobileNumber: XCUIElement
    var inputDateOfBirth: XCUIElement
    var selectCountry: XCUIElement
    var inputStateProvince: XCUIElement
    var inputStreet: XCUIElement
    var inputCity: XCUIElement
    var inputZip: XCUIElement
    var inputNameBusiness: XCUIElement

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
        selectRelationshipType = addTMTableView.cells.staticTexts["Relationship"]
        inputNameFirst = addTMTableView.textFields["firstName"]
        inputNameLast = addTMTableView.textFields["lastName"]
        inputNameMiddle = addTMTableView.textFields["middleName"]
        inputPhoneNumber = addTMTableView.textFields["phoneNumber"]
        inputMobileNumber = addTMTableView.textFields["mobileNumber"]
        inputDateOfBirth = addTMTableView.textFields["dateOfBirth"]
        selectCountry = addTMTableView.cells.staticTexts["Country"]
        inputStateProvince = addTMTableView.textFields["stateProvince"]
        inputStreet = addTMTableView.textFields["addressLine1"]
        inputCity = addTMTableView.textFields["city"]
        inputZip = addTMTableView.textFields["postalCode"]
        inputNameBusiness = addTMTableView.textFields["businessName"]
    }

    func setBranchId(_ branchId: String) {
        branchIdInput.tap()
        app.typeText(branchId)

        title.tap()
    }

    func setAccountNumber(_ accountNumber: String) {
        accountNumberInput.tap()
        app.typeText(accountNumber)
        title.tap()
    }

    func selectAccountType(_ accountType: String) {
        accountTypeSelect.tap()
        app.tables.staticTexts[accountType].tap()
    }

    func clickCreateTransferMethodButton() {
        if !createTransferMethodButton.exists {
            addTMTableView.scroll(to: createTransferMethodButton)
        }

        createTransferMethodButton.tap()
    }

    func setCardNumber(_ cardNumber: String) {
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

    func selectRelationship(_ relationship: String) {
        selectRelationshipType.tap()
        app.tables.staticTexts[relationship].tap()
    }

    func clickBackButton() {
        navigationBar.children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
    }

    func clickGenericBackButton() {
        app.navigationBars.firstMatch.children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
    }

    func setCvv(_ cvvNumber: String) {
        cvvInput.tap()
        app.typeText(cvvNumber)
        title.tap()
    }

    func setEmail(_ email: String) {
        emailInput.tap()
        app.typeText(email)
        title.tap()
    }

    func setNameFirst(_ nameFirst: String) {
        inputNameFirst.clearAndEnterText(text: nameFirst)
        title.tap()
    }

    func setNameLast(_ nameLast: String) {
        inputNameLast.clearAndEnterText(text: nameLast)
        title.tap()
    }

    func setNameMiddle(_ nameMiddle: String) {
        inputNameMiddle.clearAndEnterText(text: nameMiddle)
        title.tap()
    }

    func setPhoneNumber(_ phoneNumber: String) {
        inputPhoneNumber.clearAndEnterText(text: phoneNumber)
        title.tap()
    }

    func setMobileNumber(_ mobileNumber: String) {
        inputMobileNumber.clearAndEnterText(text: mobileNumber)
        title.tap()
    }

    func setDateOfBirth(yearOfBirth: String, monthOfBirth: String, dayOfBirth: String) {
        inputDateOfBirth.tap()

        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: monthOfBirth)
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: dayOfBirth)
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: yearOfBirth)

        app.toolbars.buttons["Done"].tap()
    }

    func selectCountry(_ country: String) {
        selectCountry.tap()
        app.tables.staticTexts[country].tap()
    }

    func setStateProvince(_ stateProvince: String) {
        inputStateProvince.clearAndEnterText(text: stateProvince)
        title.tap()
    }

    func setStreet(_ street: String) {
        inputStreet.clearAndEnterText(text: street)
        title.tap()
    }

    func setCity(_ city: String) {
        inputCity.clearAndEnterText(text: city)
        title.tap()
    }

    func setPostalCode(_ postalCode: String) {
        inputZip.clearAndEnterText(text: postalCode)
        title.tap()
    }

    func setNameBusiness(_ nameBusiness: String) {
        inputNameBusiness.clearAndEnterText(text: nameBusiness)
        title.tap()
    }
}
