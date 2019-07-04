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
    var bankAccountIdInput: XCUIElement
    var accountTypeSelect: XCUIElement
    var createTransferMethodButton: XCUIElement
    var cardNumberInput: XCUIElement
    var cvvInput: XCUIElement
    var dateOfExpiryInput: XCUIElement
    var emailInput: XCUIElement
    var navigationBar: XCUIElement

    var wireInstructionsInput: XCUIElement
    var intermediaryBankIdInput: XCUIElement
    var intermediaryBankAccountIdInput: XCUIElement
    var firstNameInput: XCUIElement
    var lastNameInput: XCUIElement
    var middleNameInput: XCUIElement
    var phoneNumberInput: XCUIElement
    var mobileNumberInput: XCUIElement
    var dateOfBirthInput: XCUIElement
    var countrySelect: XCUIElement
    var stateProvinceInput: XCUIElement
    var addressLineInput: XCUIElement
    var cityInput: XCUIElement
    var postalCodeInput: XCUIElement
    var businessNameInput: XCUIElement
    var businessRegistrationIdInput: XCUIElement

    var bankIdLabel: XCUIElement
    var branchIdLabel: XCUIElement
    var bankAccountIdLabel: XCUIElement
    var buildingSocietyAccountLabel: XCUIElement
    var accountTypeLabel: XCUIElement
    var cardNumberLabel: XCUIElement
    var cvvLabel: XCUIElement
    var dateOfExpiryLabel: XCUIElement
    var emailLabel: XCUIElement

    var wireInstructionsLabel: XCUIElement
    var intermediaryBankIdLabel: XCUIElement
    var intermediaryBankAccountIdLabel: XCUIElement
    var firstNameLabel: XCUIElement
    var lastNameLabel: XCUIElement
    var middleNameLabel: XCUIElement
    var phoneNumberLabel: XCUIElement
    var mobileNumberLabel: XCUIElement
    var dateOfBirthLabel: XCUIElement
    var countryLabel: XCUIElement
    var stateProvinceLabel: XCUIElement
    var addressLineLabel: XCUIElement
    var cityLabel: XCUIElement
    var postalCodeLabel: XCUIElement
    var businessNameLabel: XCUIElement
    var businessRegistrationIdLabel: XCUIElement

    var accountHolderHeader: XCUIElement
    var contactInformationHeader: XCUIElement
    var addressHeader: XCUIElement
    var transferMethodInformationHeader: XCUIElement

    // swiftlint:disable function_body_length
    init(app: XCUIApplication, for accountType: AccountType) {
        self.app = app

        addTransferMethodTableView = app.tables["addTransferMethodTable"]
        navigationBar = app.navigationBars[accountType.rawValue]
        createTransferMethodButton = addTransferMethodTableView.buttons["createAccountButton"]

        // Section Headers
        accountHolderHeader = addTransferMethodTableView.otherElements["ACCOUNT HOLDER"]
        contactInformationHeader = addTransferMethodTableView.otherElements["CONTACT INFORMATION"]
        addressHeader = addTransferMethodTableView.otherElements["ADDRESS"]
        transferMethodInformationHeader = addTransferMethodTableView.otherElements["TRANSFER METHOD INFORMATION"]

        // Inputs
        bankIdInput = addTransferMethodTableView.textFields["bankId"]
        branchIdInput = addTransferMethodTableView.textFields["branchId"]
        bankAccountIdInput = addTransferMethodTableView.textFields["bankAccountId"]
        accountTypeSelect = addTransferMethodTableView.staticTexts
            .containing(.staticText, identifier: "bankAccountPurpose")
            .element(matching: NSPredicate(format: "NOT (label CONTAINS[c] 'Account Type')"))
        cardNumberInput = addTransferMethodTableView.textFields["cardNumber"]
        dateOfExpiryInput = addTransferMethodTableView.textFields["dateOfExpiry"]
        cvvInput = addTransferMethodTableView.textFields["cvv"]
        emailInput = addTransferMethodTableView.textFields["email"]
        wireInstructionsInput = addTransferMethodTableView.textFields["wireInstructions"]
        intermediaryBankIdInput = addTransferMethodTableView.textFields["intermediaryBankId"]
        intermediaryBankAccountIdInput = addTransferMethodTableView.textFields["intermediaryBankAccountId"]
        firstNameInput = addTransferMethodTableView.textFields["firstName"]
        lastNameInput = addTransferMethodTableView.textFields["lastName"]
        middleNameInput = addTransferMethodTableView.textFields["middleName"]
        phoneNumberInput = addTransferMethodTableView.textFields["phoneNumber"]
        mobileNumberInput = addTransferMethodTableView.textFields["mobileNumber"]
        dateOfBirthInput = addTransferMethodTableView.textFields["dateOfBirth"]
        countrySelect = addTransferMethodTableView.staticTexts
            .containing(.staticText, identifier: "country")
            .element(matching: NSPredicate(format: "NOT (label CONTAINS[c] 'Country')"))
        stateProvinceInput = addTransferMethodTableView.textFields["stateProvince"]
        addressLineInput = addTransferMethodTableView.textFields["addressLine1"]
        cityInput = addTransferMethodTableView.textFields["city"]
        postalCodeInput = addTransferMethodTableView.textFields["postalCode"]
        businessNameInput = addTransferMethodTableView.textFields["businessName"]
        businessRegistrationIdInput = addTransferMethodTableView.textFields["businessRegistrationId"]

        // Labels
        bankIdLabel = addTransferMethodTableView.staticTexts["bankId"]
        bankAccountIdLabel = addTransferMethodTableView.staticTexts["bankAccountId"]
        buildingSocietyAccountLabel = addTransferMethodTableView.staticTexts["buildingSocietyAccount"]
        branchIdLabel = addTransferMethodTableView.staticTexts["branchId"]
        accountTypeLabel = addTransferMethodTableView.staticTexts
            .containing(.staticText, identifier: "bankAccountPurpose")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'Account Type'"))
        cardNumberLabel = addTransferMethodTableView.staticTexts["cardNumber"]
        dateOfExpiryLabel = addTransferMethodTableView.staticTexts["dateOfExpiry"]
        cvvLabel = addTransferMethodTableView.staticTexts["cvv"]
        emailLabel = addTransferMethodTableView.staticTexts["email"]
        wireInstructionsLabel = addTransferMethodTableView.staticTexts["wireInstructions"]
        intermediaryBankIdLabel = addTransferMethodTableView.staticTexts["intermediaryBankId"]
        intermediaryBankAccountIdLabel = addTransferMethodTableView.staticTexts["intermediaryBankAccountId"]
        firstNameLabel = addTransferMethodTableView.staticTexts["firstName"]
        middleNameLabel = addTransferMethodTableView.staticTexts["middleName"]
        lastNameLabel = addTransferMethodTableView.staticTexts["lastName"]
        businessNameLabel = addTransferMethodTableView.staticTexts["businessName"]
        businessRegistrationIdLabel = addTransferMethodTableView.staticTexts["businessRegistrationId"]
        phoneNumberLabel = addTransferMethodTableView.staticTexts["phoneNumber"]
        mobileNumberLabel = addTransferMethodTableView.staticTexts["mobileNumber"]
        dateOfBirthLabel = addTransferMethodTableView.staticTexts["dateOfBirth"]
        countryLabel = addTransferMethodTableView.staticTexts
            .containing(.staticText, identifier: "country")
            .element(matching: NSPredicate(format: "label CONTAINS[c] 'Country'"))
        stateProvinceLabel = addTransferMethodTableView.staticTexts["stateProvince"]
        addressLineLabel = addTransferMethodTableView.staticTexts["addressLine1"]
        cityLabel = addTransferMethodTableView.staticTexts["city"]
        postalCodeLabel = addTransferMethodTableView.staticTexts["postalCode"]
    }

    func setBankId(_ bankId: String) {
        bankIdInput.clearAndEnterText(text: bankId)
    }

    func setBranchId(_ branchId: String) {
        branchIdInput.clearAndEnterText(text: branchId)
    }

    func setAccountNumber(_ accountNumber: String) {
        bankAccountIdInput.clearAndEnterText(text: accountNumber)
    }

    func selectAccountType(_ accountType: String) {
        accountTypeLabel.tap()
        app.tables.staticTexts[accountType].tap()
    }

    func clickCreateTransferMethodButton() {
        app.scroll(to: createTransferMethodButton)
        createTransferMethodButton.tap()
    }

    func setCardNumber(_ cardNumber: String) {
        cardNumberInput.clearAndEnterText(text: cardNumber)
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
        app.navigationBars.buttons["Back"].tap()
    }

    func setCvv(_ cvvNumber: String) {
        cvvInput.clearAndEnterText(text: cvvNumber)
    }

    func setEmail(_ email: String) {
        emailInput.clearAndEnterText(text: email)
    }

    func setNameFirst(_ nameFirst: String) {
        firstNameInput.clearAndEnterText(text: nameFirst)
    }

    func setNameLast(_ nameLast: String) {
        lastNameInput.clearAndEnterText(text: nameLast)
    }

    func setNameMiddle(_ nameMiddle: String) {
        middleNameInput.clearAndEnterText(text: nameMiddle)
    }

    func setPhoneNumber(_ phoneNumber: String) {
        phoneNumberInput.clearAndEnterText(text: phoneNumber)
    }

    func setMobileNumber(_ mobileNumber: String) {
        mobileNumberInput.clearAndEnterText(text: mobileNumber)
    }

    func setDateOfBirth(yearOfBirth: String, monthOfBirth: String, dayOfBirth: String) {
        dateOfBirthInput.tap()

        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: monthOfBirth)
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: dayOfBirth)
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: yearOfBirth)

        app.toolbars.buttons["Done"].tap()
    }

    func selectCountry(_ country: String) {
        countryLabel.tap()
        app.tables.staticTexts[country].tap()
    }

    func setStateProvince(_ stateProvince: String) {
        stateProvinceInput.clearAndEnterText(text: stateProvince)
    }

    func setStreet(_ street: String) {
        addressLineInput.clearAndEnterText(text: street)
    }

    func setCity(_ city: String) {
        cityInput.clearAndEnterText(text: city)
    }

    func setPostalCode(_ postalCode: String) {
        postalCodeInput.clearAndEnterText(text: postalCode)
    }

    func setNameBusiness(_ nameBusiness: String) {
        businessNameInput.clearAndEnterText(text: nameBusiness)
    }

    func setAdditionalWireInstructions(_ additionalWireInstructions: String) {
        wireInstructionsInput.clearAndEnterText(text: additionalWireInstructions)
    }

    func setIntermediaryBankId(_ bankId: String) {
        intermediaryBankIdInput.clearAndEnterText(text: bankId)
    }

    func setIntermediaryBankAccountId(_ accountId: String) {
        intermediaryBankAccountIdInput.clearAndEnterText(text: accountId)
    }

    func setBusinessRegistrationId(_ registrationId: String) {
        businessRegistrationIdInput.clearAndEnterText(text: registrationId)
    }
}
