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

import Foundation

/// The RepositoryFactory is singleton object to access the common repositories
public final class RepositoryFactory {
    private static var instance: RepositoryFactory?
    private var objectPool = [String: Any]()

    /// Returns the previously initialized instance of the RepositoryFactory object
    public static var shared: RepositoryFactory {
        guard let instance = instance else {
            self.instance = RepositoryFactory()
            return self.instance!
        }
        return instance
    }

    /// Clears the RepositoryFactory singleton instance.
    public static func clearInstance() {
        instance = nil
    }

    private init() { }

    /// Registers the repository instance in cache
    ///
    /// - Parameter object: The object will be cached
    public func registerObject<T>(_ object: T) -> T {
        objectPool[String(describing: T.self)] = object
        return object
    }

    /// Loads the repository from cache
    ///
    /// - Parameter object:
    /// - Returns: the object
    public func loadObject<T>(_ classType: T.Type) -> T? {
        let className = String(describing: T.self)
        return objectPool[className] as? T
    }
}
