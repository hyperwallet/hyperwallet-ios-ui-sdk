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

enum AddTransferSectionHeader: String {
    case destination, amount, button
}

protocol AddTransferSectionData {
    var addTransferSectionHeader: AddTransferSectionHeader { get }
    var rowCount: Int { get }
    var title: String? { get }
    var cellIdentifier: String { get }
}

extension AddTransferSectionData {
    var rowCount: Int { return 1 }
    var title: String? { return addTransferSectionHeader != AddTransferSectionHeader.button ? "add_transfer_section_header_\(addTransferSectionHeader.rawValue)".localized() : nil }
}

struct AddTransferDestinationData: AddTransferSectionData {
    var addTransferSectionHeader: AddTransferSectionHeader { return .destination }
    var cellIdentifier: String { return ListTransferMethodTableViewCell.reuseIdentifier }
    var configuration: ListTransferMethodCellConfiguration?

    init(transferMethod: HyperwalletTransferMethod) {
        setUpCellConfiguration(transferMethod: transferMethod)
    }

    mutating func setUpCellConfiguration(transferMethod: HyperwalletTransferMethod) {
           if let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
           let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
             configuration = ListTransferMethodCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                additionalInfo: getAdditionalInfo(transferMethod),
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue)
        }
    }

    private func getAdditionalInfo(_ transferMethod: HyperwalletTransferMethod) -> String? {
        var additionlInfo: String?
        switch transferMethod.getField(fieldName: .type) as? String {
        case "BANK_ACCOUNT", "WIRE_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .bankAccountId) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "BANK_CARD":
            additionlInfo = transferMethod.getField(fieldName: .cardNumber) as? String
            additionlInfo = String(format: "%@%@",
                                   "transfer_method_list_item_description".localized(),
                                   additionlInfo?.suffix(startAt: 4) ?? "")
        case "PAYPAL_ACCOUNT":
            additionlInfo = transferMethod.getField(fieldName: .email) as? String

        default:
            break
        }
        return additionlInfo
    }
}

struct AddTransferUserInputData: AddTransferSectionData {
    var rows = [(title: String, value: String)]()
    var addTransferSectionHeader: AddTransferSectionHeader { return .amount }
    var rowCount: Int { return 2 }
    var cellIdentifier: String { return AddTransferUserInputCell.reuseIdentifier }
    let trasferAllText = "transfer_all"
    let amountText = "transfer_amount"
    let description = "transfer_description"
    var configuration: AddTransferUserInputCellConfiguration!

    init(destinationCurrency: String) {
        rows.append((title: amountText.localized(), value: destinationCurrency))
        rows.append((title: description.localized(), value: ""))
    }
}

struct AddTransferButtonData: AddTransferSectionData {
    var addTransferSectionHeader: AddTransferSectionHeader { return .button }
    var cellIdentifier: String { return AddTransferNextCell.reuseIdentifier }
}
