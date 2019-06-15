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
//final class ConfirmTransferPresenter {
//    private(set) var sectionData = [AddTransferSectionData]()
//    
//    func initializeSections(transferMethod: HyperwalletTransferMethod, transfer: HyperwalletTransfer) {
//        sectionData.removeAll()
//        let confirmTransferDestinationSection = AddTransferDestinationData(transferMethod: transferMethod)
//        sectionData.append(addTransferDestinationSection)
//        
//        if let currency = transferMethod.getField(fieldName: .transferMethodCurrency) as? String {
//            let addTransferUserInputSection = AddTransferUserInputData(destinationCurrency: currency)
//            sectionData.append(addTransferUserInputSection)
//        }
//        
//        let addTransferButtonData = AddTransferButtonData()
//        sectionData.append(addTransferButtonData)
//    }
//    
//    /// Get the list of all Activated transfer methods from core SDK
//    func loadTransferMethods() {
//        let queryParam = HyperwalletTransferMethodQueryParam()
//        queryParam.limit = 100
//        queryParam.status = .activated
//        Hyperwallet.shared.listTransferMethods(queryParam: queryParam, completion: loadTransferMethodHandler())
//    }
//    
//    private func loadTransferMethodHandler()
//        -> (HyperwalletPageList<HyperwalletTransferMethod>?, HyperwalletErrorType?) -> Void {
//            return { [weak self] (result, error) in
//                guard let strongSelf = self else {
//                    return
//                }
//                DispatchQueue.main.async {
//                    strongSelf.view.hideLoading()
//                    if let error = error {
//                        strongSelf.view.showError(error, { strongSelf.loadTransferMethods() })
//                        return
//                    }
//                    if let data = result?.data, data.isNotEmpty() {
//                        strongSelf.transferMethods = data
//                        strongSelf.view.showAddTransfer(with: strongSelf.transferMethods.first!)
//                    }
//                }
//            }
//    }
//}
