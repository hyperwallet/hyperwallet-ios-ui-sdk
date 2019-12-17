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

import HyperwalletSDK

/// User repository protocol
public protocol UserRepository {
    /// Gets the user
    ///
    /// - Parameter:
    /// - completion: the callback handler of responses from the Hyperwallet platform
    func getUser(completion: @escaping (Result<HyperwalletUser?, HyperwalletErrorType>) -> Void)

    /// Refreshes user
    func refreshUser()
}

/// RemoteUserRepository
public final class RemoteUserRepository: UserRepository {
    private var user: HyperwalletUser?

    public func getUser(completion: @escaping (Result<HyperwalletUser?, HyperwalletErrorType>) -> Void) {
        guard let user = user else {
            Hyperwallet.shared.getUser(completion: getUserHandler(completion))
            return
        }

        completion(.success(user))
    }

    public func refreshUser() {
        user = nil
    }

    private func getUserHandler( _ completion: @escaping (Result<HyperwalletUser?, HyperwalletErrorType>) -> Void)
        -> (HyperwalletUser?, HyperwalletErrorType?) -> Void {
        return {(result, error) in
            self.user = UserRepositoryCompletionHelper.performHandler(error, result, completion)
        }
    }
}
