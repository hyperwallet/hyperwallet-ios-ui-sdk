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

protocol ScheduleTransferView: class {
    func showError(_ error: HyperwalletErrorType, _ retry: (() -> Void)?)
    func notifyTransferScheduled(_ transfer: HyperwalletTransfer)
}

final class ScheduleTransferViewPresenter {
    private unowned let view: ScheduleTransferView
    private(set) var sectionData = [ScheduleTransferSectionData]()
    private var transferMethod: HyperwalletTransferMethod
    private var transfer: HyperwalletTransfer

    /// Initialize ConfirmTransferPresenter
    init(view: ScheduleTransferView, transferMethod: HyperwalletTransferMethod, transfer: HyperwalletTransfer) {
        self.view = view
        self.transferMethod = transferMethod
        self.transfer = transfer
    }

    func initializeSections() {
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
//        Hyperwallet.shared.scheduleTransfer(transferToken: transfer.token,
//                                            notes: "schedule a transfer",
//                                            completion: scheduleTransferHandler())
    }

    private func scheduleTransferHandler() -> (HyperwalletTransfer?, HyperwalletErrorType?) -> Void {
        return { [weak self] (result, error) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                if let error = error {
                    strongSelf.view.showError(error, { strongSelf.scheduleTransfer() })
                } else {
                    if let transfer = result {
                        strongSelf.view.notifyTransferScheduled(transfer)
                    }
                }
            }
        }
    }
}
