import HyperwalletSDK

/// Balance repository factory
public final class BalanceRepositoryFactory {
    private static var instance: BalanceRepositoryFactory?
    private var remoteUserBalanceRepository: UserBalanceRepository
    private var remotePrepaidCardBalanceRepository: PrepaidCardBalanceRepository

    /// Returns the previously initialized instance of the BalanceRepositoryFactory object
    public static var shared: BalanceRepositoryFactory {
        guard let instance = instance else {
            self.instance = BalanceRepositoryFactory()
            return self.instance!
        }
        return instance
    }

    private init() {
        remoteUserBalanceRepository = RemoteUserBalanceRepository()
        remotePrepaidCardBalanceRepository = RemotePrepaidCardBalanceRepository()
    }

    /// Clears the BalanceRepositoryFactory singleton instance.
    public static func clearInstance() {
        instance = nil
    }

    /// Gets the `UserBalanceRepository` implementation.
    ///
    /// - Returns: The implementation of the UserBalanceRepository protocol
    public func balanceRepository() -> UserBalanceRepository {
        return remoteUserBalanceRepository
    }

    /// Gets the `PrepaidCardBalanceRepository` implementation.
    ///
    /// - Returns: The implementation of the PrepaidCardBalanceRepository protocol
    public func prepaidCardBalanceRepository() -> PrepaidCardBalanceRepository {
        return remotePrepaidCardBalanceRepository
    }
}
