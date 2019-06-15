////
//// Copyright 2018 - Present Hyperwallet
////
//// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//// and associated documentation files (the "Software"), to deal in the Software without restriction,
//// including without limitation the rights to use, copy, modify, merge, publish, distribute,
//// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//// furnished to do so, subject to the following conditions:
////
//// The above copyright notice and this permission notice shall be included in all copies or
//// substantial portions of the Software.
////
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
//// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//import HyperwalletSDK
//
//enum ConfirmTransferSectionHeader: String {
//    case destination, foreignExchage, summary, notes, button
//}
//
//protocol ConfirmTransferSectionData {
//    var confirmTransferSectionHeader: ConfirmTransferSectionHeader { get }
//    var rowCount: Int { get }
//    var title: String? { get }
//    var cellIdentifier: String { get }
//}
//
//extension ConfirmTransferSectionData {
//    var rowCount: Int { return 1 }
//    var title: String? { return addTransferSectionHeader != AddTransferSectionHeader.button ? "confirm_transfer_section_header_\(addTransferSectionHeader.rawValue)".localized() : nil }
//}
//
//struct ConfirmTransferForeignExchangeData: AddTransferSectionData {
//    var rows = [(title: String, value: String)]()
//    var addTransferSectionHeader: AddTransferSectionHeader { return .amount }
//    var rowCount: Int { return rows.count }
//    var cellIdentifier: String { return AddTransferUserInputCell.reuseIdentifier }
//    var configuration: AddTransferUserInputCellConfiguration!
//    
//    init(destinationCurrency: String) {
//        rows.append((title: amountText.localized(), value: destinationCurrency))
//        rows.append((title: description.localized(), value: ""))
//    }
//}
//
//struct AddTransferButtonData: AddTransferSectionData {
//    var addTransferSectionHeader: AddTransferSectionHeader { return .button }
//    var cellIdentifier: String { return AddTransferNextCell.reuseIdentifier }
//}
