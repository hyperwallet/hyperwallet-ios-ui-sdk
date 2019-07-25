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
import TransferRepository
#endif
import HyperwalletSDK

protocol ScheduleTransferView: class {
    func showProcessing()
    func dismissProcessing(handler: @escaping () -> Void)
    func showConfirmation(handler: @escaping (() -> Void))
    func showError(title: String, message: String)
    func notifyTransferScheduled(_ hyperwalletStatusTransition: HyperwalletStatusTransition)
}

final class ScheduleTransferPresenter {
    private unowned let view: ScheduleTransferView
    private(set) var sectionData = [ScheduleTransferSectionData]()
    private var transferMethod: HyperwalletTransferMethod
    private var transfer: HyperwalletTransfer

    /// Initialize ScheduleTransferPresenter
    init(view: ScheduleTransferView, transferMethod: HyperwalletTransferMethod, transfer: HyperwalletTransfer) {
        self.view = view
        self.transferMethod = transferMethod
        self.transfer = transfer
    }

    private lazy var transferRepository = {
        TransferRepositoryFactory.shared.transferRepository()
    }()

    func loadScheduleTransfer() {
        initializeSections()
    }

    private func initializeSections() {
        sectionData.removeAll()
        let confirmTransferDestinationSection = ScheduleTransferDestinationData(transferMethod: transferMethod)
        sectionData.append(confirmTransferDestinationSection)

        if let foreignExchanges = transfer.foreignExchanges {
            let scheduleTransferForeignExchangesSection =
                ScheduleTransferForeignExchangeData(foreignExchanges: foreignExchanges)
            sectionData.append(scheduleTransferForeignExchangesSection)
        }

        let scheduleTransferSummaryData = ScheduleTransferSummaryData(transfer: transfer)
        sectionData.append(scheduleTransferSummaryData)

        if let scheduleTransferNotesData = ScheduleTransferNotesData(transfer: transfer) {
            sectionData.append(scheduleTransferNotesData)
        }

        let scheduleTransferButtonData = ScheduleTransferButtonData()
        sectionData.append(scheduleTransferButtonData)
    }

    func scheduleTransfer() {
        view.showProcessing()
        transferRepository.scheduleTransfer(transfer.token!) { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }

            switch result {
            case .failure(let error):
                strongSelf.view.dismissProcessing(handler: {
                    strongSelf.view.showError(title: "error".localized(), message: error
                        .getHyperwalletErrors()?.errorList?.first?.message ?? "")
                })

            case .success(let resultStatusTransition):
                guard let statusTransition = resultStatusTransition else {
                    return
                }
                strongSelf.view.showConfirmation(handler: { () -> Void in
                    strongSelf.view.notifyTransferScheduled(statusTransition)
                })
            }
        }
    }
}
