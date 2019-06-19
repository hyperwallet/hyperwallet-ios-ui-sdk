import XCTest

enum ProfileType {
    case business
    case individual

    var configurationKeyResponse: String {
        switch self {
        case .business:
            return "TransferMethodConfigurationKeysBusinessResponse"
        case .individual:
            return "TransferMethodConfigurationKeysResponse"
        }
    }

    var configurationBankAccountResponse: String {
        switch self {
        case .business:
            return "TransferMethodConfigurationBankAccountBusinessResponse"
        case .individual:
            return "TransferMethodConfigurationBankAccountResponse"
        }
    }

    var configurationBankCardResponse: String {
        switch self {
        case .business:
            return "TransferMethodConfigurationBankCardBusinessResponse"
        case .individual:
            return "TransferMethodConfigurationBankCardResponse"
        }
    }

    var configurationPayPalResponse: String {
        switch self {
        case .business:
            return "TransferMethodConfigurationPayPalAccountResponse"
        case .individual:
            return "TransferMethodConfigurationPayPalAccountResponse"
        }
    }

    var configurationWireAccountResponse: String {
        switch self {
        case .business:
            return "TransferMethodConfigurationWireAccountBusinessResponse"
        case .individual:
            return "TransferMethodConfigurationWireAccountResponse"
        }
    }
}

class BaseTests: XCTestCase {
    var app: XCUIApplication!
    var mockServer: HyperwalletMockWebServer!
    var spinner: XCUIElement!
    var profileType: ProfileType!

    override func setUp() {
        continueAfterFailure = false

        mockServer = HyperwalletMockWebServer()
        mockServer.setUp()

        mockServer.setupStub(url: "/rest/v3/users/usr-token/authentication-token",
                             filename: "AuthenticationTokenResponse",
                             method: HTTPMethod.post)

        mockServer.setupStub(url: "/rest/v3/users/usr-token",
                             filename: userResponseFileName,
                             method: HTTPMethod.get)

        mockServer.setupGraphQLStubs(for: profileType)

        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        mockServer.tearDown()
    }

    var userResponseFileName: String {
        switch profileType {
        case .business?:
            return "UserBusinessResponse"
        case .individual?:
            return "UserIndividualResponse"
        case .none:
            return "UserIndividualResponse"
        }
    }
}
