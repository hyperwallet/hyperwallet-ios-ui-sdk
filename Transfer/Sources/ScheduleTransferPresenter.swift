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

#if !COCOAPODS
import Common
import TransferMethodRepository
import TransferRepository
#endif
import HyperwalletSDK

protocol ScheduleTransferView: class {
    func showLoading()
    func hideLoading()
    func showConfirmation(handler: @escaping (() -> Void))
    func showError(_ error: HyperwalletErrorType,
                   pageName: String,
                   pageGroup: String,
                   _ retry: (() -> Void)?)
    func notifyTransferScheduled(_ hyperwalletStatusTransition: HyperwalletStatusTransition)
}

final class ScheduleTransferPresenter {
    private weak var view: ScheduleTransferView?
    private(set) var sectionData = [ScheduleTransferSectionData]()
    private var transferMethod: HyperwalletTransferMethod
    private var transfer: HyperwalletTransfer
    private var didFxQuoteChange: Bool
    private let pageName = "transfer-funds:review-transfer"
    private let pageGroup = "transfer-funds"
    private var transferSourceCellConfiguration: TransferSourceCellConfiguration

    /// Initialize ScheduleTransferPresenter
    init(
        view: ScheduleTransferView,
        transferMethod: HyperwalletTransferMethod,
        transfer: HyperwalletTransfer,
        didFxQuoteChange: Bool,
        transferSourceCellConfiguration: TransferSourceCellConfiguration) {
        self.view = view
        self.transferMethod = transferMethod
        self.transfer = transfer
        self.didFxQuoteChange = didFxQuoteChange
        self.transferSourceCellConfiguration = transferSourceCellConfiguration
        initializeSections()
    }

    private lazy var transferRepository = {
        TransferRepositoryFactory.shared.transferRepository()
    }()

    private func initializeSections() {
        sectionData.removeAll()

        let confirmTransferSourceSection =
            ScheduleTransferSectionSourceData(transferSourceCellConfiguration: transferSourceCellConfiguration)
        sectionData.append(confirmTransferSourceSection)

        let confirmTransferDestinationSection = ScheduleTransferDestinationData(transferMethod: transferMethod)
        sectionData.append(confirmTransferDestinationSection)

        if let foreignExchanges = transfer.foreignExchanges {
            let scheduleTransferForeignExchangesSection =
                ScheduleTransferForeignExchangeData(foreignExchanges: foreignExchanges)
            sectionData.append(scheduleTransferForeignExchangesSection)
        }

        let scheduleTransferSummaryData = ScheduleTransferSummaryData(
            transfer: transfer,
            didFxQuoteChange: didFxQuoteChange)
        sectionData.append(scheduleTransferSummaryData)

        if let scheduleTransferNotesData = ScheduleTransferNotesData(transfer: transfer) {
            sectionData.append(scheduleTransferNotesData)
        }

        let scheduleTransferButtonData = ScheduleTransferButtonData()
        sectionData.append(scheduleTransferButtonData)
    }

    func scheduleTransfer() {
        view?.showLoading()
        transferRepository.scheduleTransfer(transfer) { [weak self] (result) in
            guard let strongSelf = self, let view = strongSelf.view else {
                return
            }
            view.hideLoading()
            switch result {
            case .failure(let error):
                view.showError(error, pageName: strongSelf.pageName, pageGroup: strongSelf.pageGroup) {
                    strongSelf.scheduleTransfer()
                }

            case .success(let resultStatusTransition):
                guard let statusTransition = resultStatusTransition else {
                    return
                }
                view.showConfirmation(handler: { () -> Void in
                    view.notifyTransferScheduled(statusTransition)
                })
            }
        }
    }
}
