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

final class CompletionHelper {
    static func performHandler<T>(
        _ completion: @escaping (Result<T?, HyperwalletErrorType>) -> Void) -> (T?, HyperwalletErrorType?) -> Void {
        return {(result, error) in
            CompletionHelper.performHandler(error, result, completion)
        }
    }

    @discardableResult
    static func performHandler<T>(
        _ error: HyperwalletErrorType?,
        _ result: T?,
        _ completionHandler: @escaping (Result<T?, HyperwalletErrorType>) -> Void) -> T? {
        if let error = error {
            DispatchQueue.main.async {
                completionHandler(.failure(error))
            }
        } else {
            DispatchQueue.main.async {
                completionHandler(.success(result))
            }
            return result
        }
        return nil
    }
}
