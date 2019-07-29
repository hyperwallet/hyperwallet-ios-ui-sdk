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

@testable import TransferRepository
import XCTest

class TransferRepositoryFactoryTests: XCTestCase {
    func testTransferRepositoriesCreated() {
        let factory = TransferRepositoryFactory.shared

        XCTAssertNotNil(factory, "TransferRepositoryFactory instance should not be nil")
        XCTAssertNoThrow(factory.transferRepository(), "TransferRepository should exists")
    }

    func testTransferRepositoryCleanedAndRecreated() {
        let factory = TransferRepositoryFactory.shared

        TransferRepositoryFactory.clearInstance()

        let recreatedFactory = TransferRepositoryFactory.shared

        XCTAssertNotNil(factory, "Previously created TransferRepositoryFactory instance should not be nil")
        XCTAssertNotNil(recreatedFactory, "Recreated TransferRepositoryFactory instance should not be nil")
        XCTAssertFalse(factory === recreatedFactory, "Factory instances should not be the same")
   }
}
