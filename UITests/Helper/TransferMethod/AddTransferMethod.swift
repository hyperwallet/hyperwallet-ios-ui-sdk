import XCTest

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

    var intermediaryAccountHeader: XCUIElement
    var accountHolderHeader: XCUIElement
    var contactInformationHeader: XCUIElement
    var addressHeader: XCUIElement
    var transferMethodInformationHeader: XCUIElement
    var addTransferMethodtable: XCUIElement
    var navBar: XCUIElement
    var navBarBankAccount: XCUIElement
    var navBarDebitCard: XCUIElement
    var navBarWireAccount: XCUIElement
    var navBarPaypal: XCUIElement
    var cardNumberError: XCUIElement!
    var cvvNumberError: XCUIElement!
    var dateOfExpiryError: XCUIElement
    let title = "Account Settings"
    let cardNumber = "Card Number"
    let expiryDate = "Expiry Date"
    let cvvSecurityCode = "CVV (Card Security Code)"
    let emptyError = "You must provide a value for this field"
    let lengthConstraintError = "The minimum length of this field is %d and maximum length is %d."
    let patternValidationError = "is invalid length or format."
    let expireDatePlaceholder = "MM/YY"

    // swiftlint:disable function_body_length
    init(app: XCUIApplication) {
        self.app = app

        navBar = app.navigationBars[title]
        navBarBankAccount = app.navigationBars["bank_account".localized()]
        navBarDebitCard = app.navigationBars["bank_card".localized()]
        navBarWireAccount = app.navigationBars["wire_account".localized()]
        navBarPaypal = app.navigationBars["paypal_account".localized()]
        addTransferMethodtable = app.tables.cells.staticTexts["Add Transfer Method"]
        addTransferMethodTableView = app.tables["addTransferMethodTable"]
        createTransferMethodButton = addTransferMethodTableView.buttons["createAccountButton"]

        var elementQuery: XCUIElementQuery
        if #available(iOS 13.0, *) {
            elementQuery = addTransferMethodTableView.buttons
        } else {
            elementQuery = addTransferMethodTableView.staticTexts
        }

        // Section Headers
        intermediaryAccountHeader = addTransferMethodTableView.staticTexts["Intermediary Account"]
        accountHolderHeader = addTransferMethodTableView.staticTexts["mobileAccountHolderLabel".localized()]
        contactInformationHeader = addTransferMethodTableView.staticTexts["Contact Information"]
        addressHeader = addTransferMethodTableView.staticTexts["Address"]
        transferMethodInformationHeader = addTransferMethodTableView
            .staticTexts["mobileFeesAndProcessingTime".localized()]

        // Inputs
        bankIdInput = addTransferMethodTableView.textFields["bankId"]
        branchIdInput = addTransferMethodTableView.textFields["branchId"]
        bankAccountIdInput = addTransferMethodTableView.textFields["bankAccountId"]
        accountTypeSelect = addTransferMethodTableView.cells.staticTexts["bankAccountPurposeValue"]
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
        countrySelect = elementQuery["countryValue"]
        stateProvinceInput = addTransferMethodTableView.textFields["stateProvince"]
        addressLineInput = addTransferMethodTableView.textFields["addressLine1"]
        cityInput = addTransferMethodTableView.textFields["city"]
        postalCodeInput = addTransferMethodTableView.textFields["postalCode"]
        businessNameInput = addTransferMethodTableView.textFields["businessName"]
        businessRegistrationIdInput = addTransferMethodTableView.textFields["businessRegistrationId"]

        // Labels
        bankIdLabel = elementQuery["bankId"]
        bankAccountIdLabel = elementQuery["bankAccountId"]
        buildingSocietyAccountLabel = elementQuery["buildingSocietyAccount"]
        branchIdLabel = elementQuery["branchId"]
        accountTypeLabel = elementQuery["bankAccountPurpose"]
        cardNumberLabel = elementQuery["cardNumber"]
        dateOfExpiryLabel = elementQuery["dateOfExpiry"]
        cvvLabel = elementQuery["cvv"]
        emailLabel = elementQuery["email"]
        wireInstructionsLabel = elementQuery["wireInstructions"]
        intermediaryBankIdLabel = elementQuery["intermediaryBankId"]
        intermediaryBankAccountIdLabel = elementQuery["intermediaryBankAccountId"]
        firstNameLabel = addTransferMethodTableView.staticTexts["firstName"]
        middleNameLabel = elementQuery["middleName"]
        lastNameLabel = addTransferMethodTableView.staticTexts["lastName"]
        businessNameLabel = elementQuery["businessName"]
        businessRegistrationIdLabel = elementQuery["businessRegistrationId"]
        phoneNumberLabel = elementQuery["phoneNumber"]
        mobileNumberLabel = elementQuery["mobileNumber"]
        dateOfBirthLabel = elementQuery["dateOfBirth"]
        countryLabel = elementQuery["country"]
        stateProvinceLabel = elementQuery["stateProvince"]
        addressLineLabel = elementQuery["addressLine1"]
        cityLabel = elementQuery["city"]
        postalCodeLabel = elementQuery["postalCode"]

        // Debit Errors
        cardNumberError = elementQuery["cardNumber_error"]
        cvvNumberError = elementQuery["cvv_error"]
        dateOfExpiryError = elementQuery["dateOfExpiry_error"]
    }

    func setBankId(_ bankId: String) {
        bankIdInput.clearAndEnterText(text: bankId)
    }

    func setBranchId(_ branchId: String) {
        branchIdInput.clearAndEnterText(text: branchId)
    }

    func setBankAccountId(_ bankAccountId: String) {
        bankAccountIdInput.clearAndEnterText(text: bankAccountId)
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

    func setDateOfExpiryByDatePicker(expiryMonth: String, expiryYear: String) {
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

    func setDateOfExpiryByMMYY(expiryMonth: String, expiryYear: String) {
        dateOfExpiryInput.tap()
        // Supporting multiple localizations for month and year
        dateOfExpiryInput.clearAndEnterText(text: expiryMonth + expiryYear)
    }

    func setDateOfExpiryByMMPYYWithSlash(expiryMonth: String, expiryYear: String) {
        dateOfExpiryInput.tap()
        // Supporting multiple localizations for month and year
        dateOfExpiryInput.clearAndEnterText(text: expiryMonth + "/" + expiryYear)
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

    func setFirstName(_ nameFirst: String) {
        firstNameInput.clearAndEnterText(text: nameFirst)
    }

    func setLastName(_ nameLast: String) {
        lastNameInput.clearAndEnterText(text: nameLast)
    }

    func setMiddleName(_ nameMiddle: String) {
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

    func setBusinessName(_ nameBusiness: String) {
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

    func getLengthConstraintError(label: String, min: Int, max: Int) -> String {
        return label + ": " + String(format: lengthConstraintError, min, max)
    }

    func getEmptyError(label: String) -> String {
        return label + ": " + emptyError
    }

    func getPatternError(label: String) -> String {
        return label + ": " + patternValidationError
    }
}
