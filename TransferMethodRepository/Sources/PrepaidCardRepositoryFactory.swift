import HyperwalletSDK

/// Prepaid card repository factory
public final class PrepaidCardRepositoryFactory {
    private static var instance: PrepaidCardRepositoryFactory?
    private var remotePrepaidCardRepository: PrepaidCardRepository

    /// Returns the previously initialized instance of the PrepaidCardRepositoryFactory object
    public static var shared: PrepaidCardRepositoryFactory {
        guard let instance = instance else {
            self.instance = PrepaidCardRepositoryFactory()
            return self.instance!
        }
        return instance
    }

    private init() {
        remotePrepaidCardRepository = RemotePrepaidCardRepository()
    }

    /// Clears the PrepaidCardRepositoryFactory singleton instance.
    public static func clearInstance() {
        instance = nil
    }

    /// Gets the `PrepaidCardRepository` implementation.
    ///
    /// - Returns: The implementation of the PrepaidCardRepository protocol
    public func prepaidCardRepository() -> PrepaidCardRepository {
        return remotePrepaidCardRepository
    }
}
