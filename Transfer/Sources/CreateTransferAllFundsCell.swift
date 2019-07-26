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
#endif

final class CreateTransferAllFundsCell: UITableViewCell {
    typealias TransferAllFundsSwitchHandler = (_ value: Bool) -> Void
    static let reuseIdentifier = "\(type(of: self))ReuseIdentifier"

    private var transferAllFundsSwitchHandler: TransferAllFundsSwitchHandler?

    private var transferAllFundsSwitch: UISwitch = {
        let transferAllSwitch = UISwitch(frame: .zero)
        transferAllSwitch.setOn(false, animated: false)
        return transferAllSwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.heightAnchor.constraint(equalToConstant: Theme.Cell.smallHeight).isActive = true
        self.selectionStyle = .none
        setUpSwitch()
        setUpTitleLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setUpSwitch() {
        textLabel?.text = "transfer_all_funds".localized()
    }

    private func setUpTitleLabel() {
        transferAllFundsSwitch.addTarget(self, action: #selector(switchStateDidChange), for: .valueChanged)
        accessoryView = transferAllFundsSwitch
    }

    @objc
    private func switchStateDidChange() {
        transferAllFundsSwitchHandler?(transferAllFundsSwitch.isOn)
    }

    func configure(setOn: Bool, _ handler: @escaping TransferAllFundsSwitchHandler) {
        transferAllFundsSwitch.setOn(setOn, animated: false)
        transferAllFundsSwitchHandler = handler
    }
}

extension CreateTransferAllFundsCell {
    // MARK: Theme manager's proxy properties
    @objc dynamic var titleLabelFont: UIFont! {
        get { return textLabel?.font }
        set { textLabel?.font = newValue }
    }

    @objc dynamic var titleLabelColor: UIColor! {
        get { return textLabel?.textColor }
        set { textLabel?.textColor = newValue }
    }
}
