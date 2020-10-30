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
#if !COCOAPODS
import Common
import ReceiptRepository
import TransferMethodRepository
#endif

protocol ListReceiptView: class {
    func hideLoading()
    func reloadData()
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func showLoading()
    func reloadTableViewHeader()
}

final class ListReceiptPresenter {
    private weak var view: ListReceiptView?
    private let userReceiptLimit = 20

    private let pageGroup = "receipts"
    private lazy var pageName = {
        prepaidCardToken == nil
            ? "receipts:user:list-receipts"
            : "receipts:prepaidCard:list-receipts"
    }()
    private var offset = 0
    private var prepaidCardToken: String?
    private lazy var userReceiptRepository = {
        ReceiptRepositoryFactory.shared.userReceiptRepository()
    }()
    private lazy var prepaidCardReceiptRepository = {
        ReceiptRepositoryFactory.shared.prepaidCardReceiptRepository()
    }()
    private lazy var prepaidCardRepository = {
        TransferMethodRepositoryFactory.shared.prepaidCardRepository()
    }()

    private var isLoadInProgress = false
    private(set) var areAllReceiptsLoaded = true
    private(set) var sectionData = [(key: Date, value: [HyperwalletReceipt])]()
    private(set) var segmentedControlItems = [SegmentedControlItem]()
    var showAllAvailableSources = false

    /// Initialize ListReceiptPresenter
    init(view: ListReceiptView, prepaidCardToken: String? = nil, showAllAvailableSources: Bool?) {
        self.view = view
        self.prepaidCardToken = prepaidCardToken
        self.showAllAvailableSources = showAllAvailableSources ?? false
    }

    func loadReceiptsForSelectedToken() {
        sectionData.removeAll()
        if let selectedItem = getSelectedSegmentControlItem() {
            if selectedItem.receiptSourceType == .user {
                offset = 0
                listUserReceipts()
            } else {
                listPrepaidCardReceipts(selectedItem.token)
            }
        }
    }

    func getSelectedSegmentControlItem() -> SegmentedControlItem? {
        return segmentedControlItems.first(where: { $0.isSelected == true })
    }

    func listReceipts() {
        segmentedControlItems.removeAll()
        if showAllAvailableSources {
            listAllAvailableReceipts()
        } else {
            if let prepaidCardToken = prepaidCardToken {
                listPrepaidCardReceipts(prepaidCardToken)
            } else {
                listUserReceipts()
            }
        }
    }

    func listUserReceipts() {
        guard !isLoadInProgress else {
            return
        }

        isLoadInProgress = true
        view?.showLoading()
        userReceiptRepository.listUserReceipts(offset: offset,
                                               limit: userReceiptLimit,
                                               completion: listUserReceiptHandler())
    }

    private func listAllAvailableReceipts() {
        view?.showLoading()
        Hyperwallet.shared.getConfiguration {[weak self] configuration, error in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            strongSelf.view?.hideLoading()
            if let error = error {
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.listAllAvailableReceipts()
                }
                return
            }
            if let configuration = configuration,
              let programModel = configuration.programModel,
              let programModelEnum = HyperwalletProgramModel(rawValue: programModel),
              !programModelEnum.isPay2CardOrCardOnlyModel() {
               let segmentedControlItem =
                   SegmentedControlItem(token: configuration.userToken,
                                        segmentedControlHeader: "mobileAvailableFunds".localized(),
                                        receiptSourceType: .user,
                                        isSelected: true)
               strongSelf.segmentedControlItems.append(segmentedControlItem)
            }
            strongSelf.populatePrepaidCardSegments()
        }
    }

    private func populatePrepaidCardSegments() {
        view?.showLoading()
        self.prepaidCardRepository
                .listPrepaidCards(queryParam: self.setUpPrepaidCardQueryParam()) { [weak self] (result) in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            strongSelf.view?.hideLoading()
            switch result {
            case .success(let pageList):
                if let prepaidCards = pageList?.data {
                    prepaidCards.filter { $0.primaryCardToken == nil }.forEach {
                        strongSelf.segmentedControlItems.append(
                            SegmentedControlItem(
                                token: $0.token ?? "",
                                segmentedControlHeader: $0.formattedCardBrandCardNumber ?? "",
                                receiptSourceType: .prepaidCard,
                                isSelected: strongSelf.getSelectedSegmentControlItem() == nil))
                    }
                    prepaidCards.filter { $0.primaryCardToken != nil }.forEach {
                        strongSelf.segmentedControlItems.append(
                            SegmentedControlItem(
                                token: $0.token ?? "",
                                segmentedControlHeader: $0.formattedCardBrandCardNumber ?? "",
                                receiptSourceType: .prepaidCard,
                                isSelected: strongSelf.getSelectedSegmentControlItem() == nil))
                    }
                    view.reloadTableViewHeader()
                }

            case .failure(let error):
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.populatePrepaidCardSegments()
                }
                return
            }
                    strongSelf.loadReceiptsForSelectedToken()
                }
    }

    private func listPrepaidCardReceipts(_ prepaidCardToken: String) {
        guard !isLoadInProgress else {
            return
        }

        isLoadInProgress = true
        view?.showLoading()
        prepaidCardReceiptRepository.listPrepaidCardReceipts(
            prepaidCardToken: prepaidCardToken,
            completion: listPrepaidCardReceiptHandler())
    }

    private func listUserReceiptHandler()
        -> (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>) -> Void {
            return { [weak self] (result) in
                guard let strongSelf = self, let view = strongSelf.view else {
                    return
                }
                strongSelf.isLoadInProgress = false
                view.hideLoading()
                switch result {
                case .success(let receiptList):
                    guard let receiptList = receiptList, let receipts = receiptList.data else { break }
                    strongSelf.groupReceiptsByMonth(receipts)
                    strongSelf.areAllReceiptsLoaded =
                        receipts.count < strongSelf.userReceiptLimit ? true : false
                    strongSelf.offset += receipts.count

                case .failure(let error):
                    view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                        strongSelf.listUserReceipts()
                    }
                    return
                }
                view.reloadData()
            }
    }

    private func listPrepaidCardReceiptHandler()
        -> (Result<HyperwalletPageList<HyperwalletReceipt>?, HyperwalletErrorType>) -> Void {
            return { [weak self] (result) in
                guard let strongSelf = self, let view = strongSelf.view else {
                    return
                }
                strongSelf.isLoadInProgress = false
                view.hideLoading()
                switch result {
                case .success(let receiptList):
                    guard let receiptList = receiptList, let receipts = receiptList.data else { break }
                    strongSelf.areAllReceiptsLoaded = true
                    strongSelf.groupReceiptsByMonth(receipts.reversed())

                case .failure(let error):
                    guard let prepaidCardToken = strongSelf.prepaidCardToken else { break }
                    view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                        strongSelf.listPrepaidCardReceipts(prepaidCardToken)
                    }
                    return
                }
                view.reloadData()
            }
    }

    private func groupReceiptsByMonth(_ receipts: [HyperwalletReceipt]) {
        let groupedSections = Dictionary(grouping: receipts,
                                         by: {
                                            ISO8601DateFormatter
                                                .ignoreTimeZone
                                                .date(from: $0.createdOn ?? "")!
                                                .firstDayOfMonth()
        })

        let sortedGroupedSections = groupedSections
            .sorted(by: { $0.key > $1.key })

        for section in sortedGroupedSections {
            if let sectionIndex = sectionData.firstIndex(where: { $0.key == section.key }) {
                sectionData[sectionIndex].value.append(contentsOf: section.value)
            } else {
                sectionData.append(section)
            }
        }
    }

    private func setUpPrepaidCardQueryParam() -> HyperwalletPrepaidCardQueryParam {
        let queryParam = HyperwalletPrepaidCardQueryParam()
        // Only fetch active prepaid cards
        queryParam.status = HyperwalletPrepaidCardQueryParam.QueryStatus.activated.rawValue
        return queryParam
    }
}

class SegmentedControlItem {
    let token: String
    let segmentedControlHeader: String
    let receiptSourceType: ReceiptSourceType
    var isSelected: Bool

    init(token: String,
         segmentedControlHeader: String,
         receiptSourceType: ReceiptSourceType,
         isSelected: Bool) {
        self.token = token
        self.segmentedControlHeader = segmentedControlHeader
        self.receiptSourceType = receiptSourceType
        self.isSelected = isSelected
    }
}

/// Enum to store the type of Source - User or PrepaidCard
enum ReceiptSourceType {
    /// Represents user
    case user
    /// Represents prepaid card
    case prepaidCard
}
