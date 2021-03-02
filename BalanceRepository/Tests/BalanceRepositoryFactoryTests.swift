import BalanceRepository
import XCTest

class BalanceRepositoryFactoryTests: XCTestCase {
    func testBalanceRepository() {
        let factory = BalanceRepositoryFactory.shared

        XCTAssertNotNil(factory, "BalanceRepositoryFactory instance should not be nil")
        XCTAssertNoThrow(factory.balanceRepository(), "BalanceRepository should exist")
        XCTAssertNoThrow(factory.prepaidCardBalanceRepository(), "PrepaidCardBalanceRepository should exist")
    }

    func testClearInstance() {
        let factory = BalanceRepositoryFactory.shared
        BalanceRepositoryFactory.clearInstance()
        let recreatedFactory = BalanceRepositoryFactory.shared

        XCTAssertNotNil(factory, "Previously created BalanceRepositoryFactory instance should not be nil")
        XCTAssertNotNil(recreatedFactory, "Recreated BalanceRepositoryFactory instance should not be nil")
        XCTAssertFalse(factory === recreatedFactory, "Factory instances should not be the same")
    }
}
