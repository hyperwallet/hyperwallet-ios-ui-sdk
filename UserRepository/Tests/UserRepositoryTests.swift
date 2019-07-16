//
// Copyright 2018 - Present Hyperwallet
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Hippolyte
import HyperwalletSDK
@testable import UserRepository
import XCTest

class UserRepositoryTests: XCTestCase {
    private lazy var individualUserResponse = HyperwalletTestHelper.getDataFromJson("UserIndividualResponse")
    private lazy var businessUserResponse = HyperwalletTestHelper.getDataFromJson("UserBusinessResponse")
    private var factory: UserRepositoryFactory!
    private var userRepository: UserRepository!

    override func setUp() {
        Hyperwallet.setup(HyperwalletTestHelper.authenticationProvider)
        factory = UserRepositoryFactory.shared
        userRepository = factory.userRepository()
    }

    override func tearDown() {
        UserRepositoryFactory.clearInstance()
        if Hippolyte.shared.isStarted {
            Hippolyte.shared.stop()
        }
    }

    func testGetUser_individualSuccess() {
        // Given
        let expectation = self.expectation(description: "Get HyperwalletUser completed")
        HyperwalletTestHelper.setUpMockServer(request: UserRequestHelper.setUpRequest(individualUserResponse))

        var user: HyperwalletUser?

        // When
        userRepository.getUser { result in
            switch result {
            case .success(let userResponse):
                guard let userResponse = userResponse else {
                    XCTFail("The userResponse should not be empty!")
                    return
                }

                expectation.fulfill()
                user = userResponse

            case .failure:
                XCTFail("Unexpected error")
            }
        }
        wait(for: [expectation], timeout: 1)
        // Then
        verifyIndividualResponse(user)
    }

    func testGetUser_businessSuccess() {
        // Given
        let expectation = self.expectation(description: "Get HyperwalletUser completed")
        HyperwalletTestHelper.setUpMockServer(request: UserRequestHelper.setUpRequest(businessUserResponse))

        var user: HyperwalletUser?

        // When
        userRepository.getUser { result in
            switch result {
            case .success(let userResponse):
                guard let userResponse = userResponse else {
                    XCTFail("The userResponse should not be empty!")
                    return
                }

                expectation.fulfill()
                user = userResponse

            case .failure:
                XCTFail("Unexpected error")
            }
        }
        wait(for: [expectation], timeout: 1)
        // Then
        verifyBusinessResponse(user)
    }

    func testGetUser_failure() {
        // Given
        let expectation = self.expectation(description: "Get HyperwalletUser failed")
        let error = NSError(domain: NSURLErrorDomain, code: 501, userInfo: nil)
        HyperwalletTestHelper.setUpMockServer(request: UserRequestHelper.setUpRequest(individualUserResponse,
                                                                                      error))
        // When
        userRepository.getUser { result in
            switch result {
            case .success:
                XCTFail("The request should return error!")

            case .failure(let error):
                XCTAssertNotNil(error, "The error should not be nil!")
                XCTAssertEqual(error.getHyperwalletErrors()?.originalError?._domain,
                               NSURLErrorDomain,
                               "The error.domain should be NSURLErrorDomain!")
                XCTAssertEqual(error.getHyperwalletErrors()?.originalError?._code,
                               501,
                               "The code should be 501!")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }
}

private extension UserRepositoryTests {
    func verifyIndividualResponse(_ user: HyperwalletUser?) {
        XCTAssertNotNil(user)

        XCTAssertEqual(user!.clientUserId, "myAppUserId01", "The clientUserId should be myAppUserId01!")
        XCTAssertEqual(user!.token, "YourUserToken", "The token should be YourUserToken!")
        XCTAssertEqual(user!.status, HyperwalletUser.Status.activated, "The status should be `activated`!")
        XCTAssertEqual(user!.verificationStatus,
                       HyperwalletUser.VerificationStatus.notRequired,
                       "The verificationStatus should be `notRequired`!")
        XCTAssertEqual(user!.profileType,
                       HyperwalletUser.ProfileType.individual,
                       "The profileType should be `individual`!")
        XCTAssertEqual(user!.gender, HyperwalletUser.Gender.male, "The gender should be `male`!")
        XCTAssertEqual(user!.employerId, "001", "The employerId should be 001!")
        XCTAssertNil(user!.countryOfNationality, "The countryOfNationality should be nil!")

        XCTAssertEqual(user!.firstName, "Stan", "The firstName should be Stan!")
        XCTAssertEqual(user!.middleName, "Albert", "The middleName should be Albert!")
        XCTAssertEqual(user!.lastName, "Fung", "The lastName should be Fung!")
        XCTAssertEqual(user!.dateOfBirth, "1980-01-01", "The dateOfBirth should be 1980-01-01!")
        XCTAssertEqual(user!.countryOfBirth, "US", "The countryOfBirth should be US!")
        XCTAssertEqual(user!.driversLicenseId, "000123", "The driversLicenseId should be 000123!")
        XCTAssertEqual(user!.governmentIdType, "PASSPORT", "The governmentIdType should be PASSPORT!")
        XCTAssertEqual(user!.passportId, "00000", "The passportId should be 00000!")

        XCTAssertEqual(user!.createdOn, "2019-04-30T00:01:53", "The createdOn should be 2019-04-30T00:01:53!")
        XCTAssertEqual(user!.phoneNumber, "000-000000", "The phoneNumber should be 000-000000!")
        XCTAssertEqual(user!.mobileNumber, "000-000-0000", "The mobileNumber should be 000-000-0000!")
        XCTAssertEqual(user!.email, "user01@myApp.com", "The email should be user01@myApp.com!")
        XCTAssertEqual(user!.governmentId, "0000000000", "The governmentId should be 0000000000!")

        XCTAssertEqual(user!.addressLine1, "abc", "The addressLine1 should be abc!")
        XCTAssertEqual(user!.addressLine2, "def", "The addressLine2 should be def!")
        XCTAssertEqual(user!.city, "Phoenix", "The city should be Phoenix!")
        XCTAssertEqual(user!.stateProvince, "AZ", "The stateProvince should be AZ!")

        XCTAssertEqual(user!.country, "US", "The country should be US!")
        XCTAssertEqual(user!.postalCode, "12345", "The postalCode should be 12345!")
        XCTAssertEqual(user!.language, "en", "The language should be en!")
        XCTAssertEqual(user!.timeZone, "PST", "The timeZone should be PST!")
        XCTAssertEqual(user!.programToken,
                       "prg-00000000-0000-0000-0000-000000000000",
                       "The programToken should be prg-00000000-0000-0000-0000-000000000000!")
    }

    func verifyBusinessResponse(_ user: HyperwalletUser?) {
        XCTAssertNotNil(user)

        XCTAssertEqual(user!.clientUserId, "myBusinessIdd01", "The clientUserId should be myBusinessIdd01!")
        XCTAssertEqual(user!.token, "YourUserToken", "The token should be YourUserToken!")
        XCTAssertEqual(user!.status, HyperwalletUser.Status.preActivated, "The status should be `preActivated`!")
        XCTAssertEqual(user!.verificationStatus,
                       HyperwalletUser.VerificationStatus.notRequired,
                       "The verificationStatus should be `notRequired`!")
        XCTAssertEqual(user!.profileType, HyperwalletUser.ProfileType.business, "The profileType should be `business`!")
        XCTAssertEqual(user!.gender, HyperwalletUser.Gender.male, "The gender should be `male`!")

        XCTAssertEqual(user!.businessType,
                       HyperwalletUser.BusinessType.corporation,
                       "The businessType should be `corporation`!")

        XCTAssertEqual(user!.businessRegistrationId, "ABC0000", "The businessRegistrationId should be ABC0000!")
        XCTAssertEqual(user!.businessName, "Your Business LTD", "The businessName should be Your Business LTD!")
        XCTAssertEqual(user!.businessOperatingName,
                       "My Business LTD",
                       "The businessOperatingName should be My Business LTD!")
        XCTAssertEqual(user!.businessRegistrationStateProvince,
                       "BCA",
                       "The businessRegistrationStateProvince should be BCA!")
        XCTAssertEqual(user!.businessRegistrationCountry, "US", "The businessRegistrationCountry should be US!")
        XCTAssertEqual(user!.businessContactRole,
                       HyperwalletUser.BusinessContactRole.director,
                       "The businessContactRole should be `director`!")
        XCTAssertEqual(user!.businessContactCountry, "US", "The businessContactCountry should be US!")
        XCTAssertEqual(user!.email, "director@mybusiness.net", "The email should be director@mybusiness.net!")
        XCTAssertEqual(user!.governmentId, "000000000", "The governmentId should be 000000000!")

        XCTAssertEqual(user!.businessContactAddressLine1,
                       "Business-Address",
                       "The businessContactAddressLine1 should be Business-Address!")
        XCTAssertEqual(user!.businessContactAddressLine2,
                       "Business-Address 2",
                       "The businessContactAddressLine2 should be Business-Address 2!")
        XCTAssertEqual(user!.businessContactCity, "Flagstaff", "The businessContactCity should be Flagstaff!")
        XCTAssertEqual(user!.businessContactPostalCode, "0000", "The businessContactPostalCode should be 0000!")
        XCTAssertEqual(user!.businessContactStateProvince, "AZ", "The businessContactStateProvince should be AZ!")
        XCTAssertEqual(user!.countryOfNationality, "US", "The countryOfNationality should be US!")
    }
}
