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

enum CreateTransferSectionHeader: String {
    case destination, amount, button
}

protocol CreateTransferSectionData {
    var createTransferSectionHeader: CreateTransferSectionHeader { get }
    var rowCount: Int { get }
    var title: String? { get }
    var cellIdentifier: String { get }
}

extension CreateTransferSectionData {
    var rowCount: Int { return 1 }
    var title: String? { return createTransferSectionHeader !=
        CreateTransferSectionHeader.button ?
            "add_transfer_section_header_\(createTransferSectionHeader.rawValue)".localized() : nil }
}

struct CreateTransferDestinationData: CreateTransferSectionData {
    var createTransferSectionHeader: CreateTransferSectionHeader { return .destination }
    var cellIdentifier: String { return ListTransferMethodTableViewCell.reuseIdentifier }
    var configuration: ListTransferMethodCellConfiguration?

    init(transferMethod: HyperwalletTransferMethod) {
        configuration = setUpCellConfiguration(transferMethod: transferMethod)
    }

    private func setUpCellConfiguration(transferMethod: HyperwalletTransferMethod) -> ListTransferMethodCellConfiguration? {
           if let country = transferMethod.getField(fieldName: .transferMethodCountry) as? String,
           let transferMethodType = transferMethod.getField(fieldName: .type) as? String {
             return ListTransferMethodCellConfiguration(
                transferMethodType: transferMethodType.lowercased().localized(),
                transferMethodCountry: country.localized(),
                additionalInfo: getAdditionalInfo(transferMethod),
                transferMethodIconFont: HyperwalletIcon.of(transferMethodType).rawValue,
                transferMethodToken: transferMethod.getField(fieldName: .token) as? String ?? "")
        }
        return nil
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

struct CreateTransferUserInputData: CreateTransferSectionData {
    var rows = [(title: String?, value: String?)]()
    var createTransferSectionHeader: CreateTransferSectionHeader { return .amount }
    var rowCount: Int { return 2 }
    var cellIdentifier: String { return CreateTransferUserInputCell.reuseIdentifier }
    var configuration: CreateTransferUserInputCellConfiguration!

    init(destinationCurrency: String) {
        rows.append((title: nil, value: destinationCurrency))
        rows.append((title: nil, value: nil))
    }
}

struct CreateTransferButtonData: CreateTransferSectionData {
    var createTransferSectionHeader: CreateTransferSectionHeader { return .button }
    var cellIdentifier: String { return CreateTransferButtonCell.reuseIdentifier }
}
