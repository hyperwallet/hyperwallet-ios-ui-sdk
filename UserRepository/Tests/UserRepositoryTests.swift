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
        let expectation = self.expectation(description: "Get HyperwalletUser completed")
        let error = NSError(domain: NSURLErrorDomain, code: 501, userInfo: nil)
        HyperwalletTestHelper.setUpMockServer(request: UserRequestHelper.setUpRequest(individualUserResponse,
                                                                                      error))
        // When
        userRepository.getUser { result in
            switch result {
            case .success:
                XCTFail("The request should return error!")

            case .failure:
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }
}

private extension UserRepositoryTests {
    func verifyIndividualResponse(_ user: HyperwalletUser?) {
        XCTAssertNotNil(user)

        XCTAssertEqual(user!.clientUserId, "myAppUserId01")
        XCTAssertEqual(user!.token, "YourUserToken")
        XCTAssertEqual(user!.status, HyperwalletUser.Status.activated)
        XCTAssertEqual(user!.verificationStatus, HyperwalletUser.VerificationStatus.notRequired)
        XCTAssertEqual(user!.profileType, HyperwalletUser.ProfileType.individual)
        XCTAssertEqual(user!.gender, HyperwalletUser.Gender.male)
        XCTAssertEqual(user!.employerId, "001")
        XCTAssertNil(user!.countryOfNationality)

        XCTAssertEqual(user!.firstName, "Stan")
        XCTAssertEqual(user!.middleName, "Albert")
        XCTAssertEqual(user!.lastName, "Fung")
        XCTAssertEqual(user!.dateOfBirth, "1980-01-01")
        XCTAssertEqual(user!.countryOfBirth, "US")
        XCTAssertEqual(user!.driversLicenseId, "000123")
        XCTAssertEqual(user!.governmentIdType, "PASSPORT")
        XCTAssertEqual(user!.passportId, "00000")

        XCTAssertEqual(user!.createdOn, "2019-04-30T00:01:53")
        XCTAssertEqual(user!.phoneNumber, "000-000000")
        XCTAssertEqual(user!.mobileNumber, "000-000-0000")
        XCTAssertEqual(user!.email, "user01@myApp.com")
        XCTAssertEqual(user!.governmentId, "0000000000")

        XCTAssertEqual(user!.addressLine1, "abc")
        XCTAssertEqual(user!.addressLine2, "def")
        XCTAssertEqual(user!.city, "Phoenix")
        XCTAssertEqual(user!.stateProvince, "AZ")

        XCTAssertEqual(user!.country, "US")
        XCTAssertEqual(user!.postalCode, "12345")
        XCTAssertEqual(user!.language, "en")
        XCTAssertEqual(user!.timeZone, "PST")
        XCTAssertEqual(user!.programToken, "prg-00000000-0000-0000-0000-000000000000")
    }

    func verifyBusinessResponse(_ user: HyperwalletUser?) {
        XCTAssertNotNil(user)

        XCTAssertEqual(user!.clientUserId, "myBusinessIdd01")
        XCTAssertEqual(user!.token, "YourUserToken")
        XCTAssertEqual(user!.status, HyperwalletUser.Status.preActivated)
        XCTAssertEqual(user!.verificationStatus, HyperwalletUser.VerificationStatus.notRequired)
        XCTAssertEqual(user!.profileType, HyperwalletUser.ProfileType.business)
        XCTAssertEqual(user!.gender, HyperwalletUser.Gender.male)

        XCTAssertEqual(user!.businessType, HyperwalletUser.BusinessType.corporation)

        XCTAssertEqual(user!.businessRegistrationId, "ABC0000")
        XCTAssertEqual(user!.businessName, "Your Business LTD")
        XCTAssertEqual(user!.businessOperatingName, "My Business LTD")
        XCTAssertEqual(user!.businessRegistrationStateProvince, "BCA")
        XCTAssertEqual(user!.businessRegistrationCountry, "US")
        XCTAssertEqual(user!.businessContactRole, HyperwalletUser.BusinessContactRole.director)
        XCTAssertEqual(user!.businessContactCountry, "US")
        XCTAssertEqual(user!.email, "director@mybusiness.net")
        XCTAssertEqual(user!.governmentId, "000000000")

        XCTAssertEqual(user!.businessContactAddressLine1, "Business-Address")
        XCTAssertEqual(user!.businessContactAddressLine2, "Business-Address 2")
        XCTAssertEqual(user!.businessContactCity, "Flagstaff")
        XCTAssertEqual(user!.businessContactPostalCode, "0000")
        XCTAssertEqual(user!.businessContactStateProvince, "AZ")
        XCTAssertEqual(user!.countryOfNationality, "US")
    }
}
