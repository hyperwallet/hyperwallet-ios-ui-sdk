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

/// The Notification extension
public extension Notification.Name {
    /// Posted when a new transfer method (bank account, bank card, PayPal account, prepaid card, paper check, venmo)
    /// has been created.
    static var transferMethodAdded: Notification.Name {
        return .init(rawValue: "transferMethodAdded")
    }

    /// Posted when a  transfer method (bank account, bank card, PayPal account, prepaid card, paper check, venmo)
    /// has been updated.
    static var transferMethodUpdated: Notification.Name {
        return .init(rawValue: "transferMethodUpdated")
    }

    /// Posted when a transfer method (bank account, bank card, PayPal account, prepaid card, paper check)
    /// has been deactivated.
    static var transferMethodDeactivated: Notification.Name {
        return .init(rawValue: "transferMethodDeactivated")
    }

    /// Posted when a transfer of funds has been created.
    static var transferCreated: Notification.Name {
        return .init(rawValue: "transferCreated")
    }

    /// Posted when a transfer has been scheduled
    static var transferScheduled: Notification.Name {
        return .init(rawValue: "transferScheduled")
    }

    /// Posted when authentication error occurs
    static var authenticationError: Notification.Name {
        return .init(rawValue: "authenticationError")
    }
}

/// The Hyperwallet's `NotificationCenter` key to access the information.
public enum UserInfo: String {
    /// A new transfer method has been added.
    case transferMethodAdded
    /// A  transfer method has been updated.
    case transferMethodUpdated
    /// A transfer method has been deactivated.
    case transferMethodDeactivated
    /// A transfer of funds has been created.
    case transferCreated
    /// A transfer has been scheduled.
    case transferScheduled
    /// Authentication error has been occured
    case authenticationError
}
