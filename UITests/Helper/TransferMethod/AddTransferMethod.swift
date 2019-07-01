import XCTest

enum AccountType: String {
    case bankAccount = "Bank Account"
    case debitCard = "Debit Card"
    case payPalAccount = "PayPal"
    case wireAccount = "Wire Account"
}

class AddTransferMethod {
    let defaultTimeout = 5.0

    var app: XCUIApplication

    var addTransferMethodTableView: XCUIElement
    var bankIdInput: XCUIElement
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

    var wireInstructionsInput: XCUIElement
    var selectRelationshipType: XCUIElement
    var intermediaryBankIdInput: XCUIElement
    var intermediaryBankAccountIdInput: XCUIElement
    var firstNameInput: XCUIElement
    var lastNameInput: XCUIElement
    var middleNameInput: XCUIElement
    var phoneNumberInput: XCUIElement
    var mobileNumberInput: XCUIElement
    var dateOfBirthInput: XCUIElement
    var selectCountry: XCUIElement
    var stateProvinceInput: XCUIElement
    var streetInput: XCUIElement
    var cityInput: XCUIElement
    var zipInput: XCUIElement
    var businessNameInput: XCUIElement
    var businessRegistrationIdInput: XCUIElement

    init(app: XCUIApplication, for accountType: AccountType) {
        self.app = app

        addTransferMethodTableView = app.tables["addTransferMethodTable"]
        bankIdInput = addTransferMethodTableView.textFields["BIC/SWIFT_value"]
        branchIdInput = addTransferMethodTableView.textFields["Routing Number_value"]
        accountNumberInput = addTransferMethodTableView.textFields[
            accountType == .wireAccount
                ? "Account Number OR IBAN_value"
                : "Account Number_value"
        ]
        accountTypeSelect = addTransferMethodTableView.cells.staticTexts["Account Type"]
        createTransferMethodButton = addTransferMethodTableView
            .cells
            .containing(.button, identifier: "createAccountButton")
            .buttons["createAccountButton"]
        cardNumberInput = addTransferMethodTableView.textFields["Card Number_value"]
        dateOfExpiryInput = addTransferMethodTableView.textFields["Expiry Date_value"]
        cvvInput = addTransferMethodTableView.textFields["CVV (Card Security Code)_value"]
        emailInput = addTransferMethodTableView.textFields["Email_value"]
        title = addTransferMethodTableView.staticTexts["Account Information - United States (USD)"]
        navigationBar = app.navigationBars[accountType.rawValue]
        wireInstructionsInput = addTransferMethodTableView.textFields["Additional Wire Instructions_value"]
        selectRelationshipType = addTransferMethodTableView.cells.staticTexts["Relationship"]
        intermediaryBankIdInput = addTransferMethodTableView.textFields["Intermediary BIC / SWIFT Code_value"]
        intermediaryBankAccountIdInput = addTransferMethodTableView.textFields["Intermediary Account Number_value"]
        firstNameInput = addTransferMethodTableView.textFields["First Name_value"]
        lastNameInput = addTransferMethodTableView.textFields["Last Name_value"]
        middleNameInput = addTransferMethodTableView.textFields["Middle Name_value"]
        phoneNumberInput = addTransferMethodTableView.textFields["Phone Number_value"]
        mobileNumberInput = addTransferMethodTableView.textFields["Mobile Number_value"]
        dateOfBirthInput = addTransferMethodTableView.textFields["Date of Birth_value"]
        selectCountry = addTransferMethodTableView.cells.staticTexts["Country"]
        stateProvinceInput = addTransferMethodTableView.textFields["State/Province_value"]
        streetInput = addTransferMethodTableView.textFields["Street_value"]
        cityInput = addTransferMethodTableView.textFields["City_value"]
        zipInput = addTransferMethodTableView.textFields["Zip/Postal Code_value"]
        businessNameInput = addTransferMethodTableView.textFields["Business Name_value"]
        businessRegistrationIdInput = addTransferMethodTableView.textFields["Business Reg Number_value"]
    }

    func setBankId(_ bankId: String) {
        bankIdInput.clearAndEnterText(text: bankId)
        title.tap()
    }

    func setBranchId(_ branchId: String) {
        branchIdInput.clearAndEnterText(text: branchId)
        title.tap()
    }

    func setAccountNumber(_ accountNumber: String) {
        accountNumberInput.clearAndEnterText(text: accountNumber)
        title.tap()
    }

    func selectAccountType(_ accountType: String) {
        accountTypeSelect.tap()
        app.tables.staticTexts[accountType].tap()
    }

    func clickCreateTransferMethodButton() {
        if !createTransferMethodButton.exists {
            addTransferMethodTableView.scroll(to: createTransferMethodButton)
        }

        createTransferMethodButton.tap()
    }

    func setCardNumber(_ cardNumber: String) {
        cardNumberInput.clearAndEnterText(text: cardNumber)
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
        cvvInput.clearAndEnterText(text: cvvNumber)
        title.tap()
    }

    func setEmail(_ email: String) {
        emailInput.clearAndEnterText(text: email)
        title.tap()
    }

    func setNameFirst(_ nameFirst: String) {
        firstNameInput.clearAndEnterText(text: nameFirst)
        title.tap()
    }

    func setNameLast(_ nameLast: String) {
        lastNameInput.clearAndEnterText(text: nameLast)
        title.tap()
    }

    func setNameMiddle(_ nameMiddle: String) {
        middleNameInput.clearAndEnterText(text: nameMiddle)
        title.tap()
    }

    func setPhoneNumber(_ phoneNumber: String) {
        phoneNumberInput.clearAndEnterText(text: phoneNumber)
        title.tap()
    }

    func setMobileNumber(_ mobileNumber: String) {
        mobileNumberInput.clearAndEnterText(text: mobileNumber)
        title.tap()
    }

    func setDateOfBirth(yearOfBirth: String, monthOfBirth: String, dayOfBirth: String) {
        dateOfBirthInput.tap()

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
        stateProvinceInput.clearAndEnterText(text: stateProvince)
        title.tap()
    }

    func setStreet(_ street: String) {
        streetInput.clearAndEnterText(text: street)
        title.tap()
    }

    func setCity(_ city: String) {
        cityInput.clearAndEnterText(text: city)
        title.tap()
    }

    func setPostalCode(_ postalCode: String) {
        zipInput.clearAndEnterText(text: postalCode)
        title.tap()
    }

    func setNameBusiness(_ nameBusiness: String) {
        businessNameInput.clearAndEnterText(text: nameBusiness)
        title.tap()
    }

    func setAdditionalWireInstructions(_ additionalWireInstructions: String) {
        wireInstructionsInput.clearAndEnterText(text: additionalWireInstructions)
        title.tap()
    }

    func setIntermediaryBankId(_ bankId: String) {
        intermediaryBankIdInput.clearAndEnterText(text: bankId)
        title.tap()
    }

    func setIntermediaryBankAccountId(_ accountId: String) {
        intermediaryBankAccountIdInput.clearAndEnterText(text: accountId)
        title.tap()
    }

    func setBusinessRegistrationId(_ registrationId: String) {
        businessRegistrationIdInput.clearAndEnterText(text: registrationId)
        title.tap()
    }
}
