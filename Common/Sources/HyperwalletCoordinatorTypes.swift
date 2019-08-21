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
/// Hyperwallet'se num for the types of coordinators
public enum HyperwalletCoordinatorTypes {
    /// - selectTransferMethodType: Coordinator for select transfer method type.
    case selectTransferMethodType
}

/// Class responsible for deciding the coordinator required
public class HyperwalletCoordinatorFactory {
    private static var instance: HyperwalletCoordinatorFactory!

    /// Returns the previously initialized instance of the Hyperwallet UI SDK interface object
    public static var shared: HyperwalletCoordinatorFactory {
        if instance == nil {
            self.instance = HyperwalletCoordinatorFactory()
        }
        return instance
    }

    /// Based on the HyperwalletCoordinatorTypes, determines the coordinator to be returned,
    /// returns nil if teh module has not been imported in the project
    ///
    /// - Parameter hyperwalletCoordinatorType:HyperwalletCoordinatorTypes
    /// - Returns: The initialized co-ordinator class
    public func getHyperwalletCoordinator(hyperwalletCoordinatorType: HyperwalletCoordinatorTypes)
        -> HyperwalletCoordinator? {
            switch hyperwalletCoordinatorType {
            case .selectTransferMethodType:
                if let className = NSClassFromString("HyperwalletUISDK.SelectTransferMethodTypeCoordinator")
                    as? NSObject.Type ?? NSClassFromString("TransferMethod.SelectTransferMethodTypeCoordinator")
                    as? NSObject.Type {
                    return className.init() as? HyperwalletCoordinator
                }
            }
            return nil
    }
}