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
import HyperwalletSDK
import UIKit

/// Represents the abstract widget input
class AbstractWidget: UIStackView, UITextFieldDelegate {
    private(set) var field: HyperwalletField!
    private var pageName: String!
    private var pageGroup: String!
    lazy var hyperwalletInsights: HyperwalletInsightsProtocol = HyperwalletInsights.shared
    private let errorTypeForm = "FORM"
    typealias InputHandler = () -> Void
    private var inputHandler: InputHandler?
    private(set) var errorMessage: String?
    var isValueUpdated = false

    let label: UILabel = {
        let label = UILabel()
        label.textColor = Theme.Label.textColor
        label.font = Theme.Label.titleFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        return label
    }()

    required init(field: HyperwalletField,
                  pageName: String,
                  pageGroup: String,
                  inputHandler: @escaping InputHandler) {
        self.pageName = pageName
        self.pageGroup = pageGroup
        self.inputHandler = inputHandler
        super.init(frame: CGRect())
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 5
        distribution = .fill
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 11.0, left: 0, bottom: 1.0, right: 16.0)
        self.field = field
        setupLayout(field: field)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func getErrorMessage() -> String? {
        if isInvalidEmptyValue() {
            return field.validationMessage?.empty
        }
        if isInvalidLength() {
            return field.validationMessage?.length
        }
        if isInvalidRegex() {
            return field.validationMessage?.pattern
        }
        return nil
    }

    //swiftlint:disable unavailable_function
    func focus() {
        fatalError("not implemented")
    }

    @objc
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        fatalError("not implemented")
    }

    func hideError() {
        label.textColor = Theme.Text.labelColor
        label.accessibilityIdentifier = String(format: "%@", field.name ?? "")
    }

    func isValid() -> Bool {
        var isValid = true
        if isInvalidEmptyValue() || isInvalidLength() || isInvalidRegex() {
            trackError()
            isValid = false
        } else {
            errorMessage = nil
        }
        return isValid
    }

    func name() -> String {
        return field.name!
    }

    func setupLayout(field: HyperwalletField) {
        label.accessibilityIdentifier = field.name ?? ""
        label.text = field.label ?? ""
        label.isUserInteractionEnabled = field.isEditable ?? true
        label.adjustsFontForContentSizeCategory = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        label.addGestureRecognizer(tap)
        addArrangedSubview(label)
        if let heightAnchor = label.superview?.heightAnchor {
            label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35).isActive = true
        }
    }

    func showError() {
        label.textColor = Theme.Label.errorColor
        label.accessibilityIdentifier = String(format: "%@_error", field.name ?? "")
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
        if let isValueMasked = field.fieldValueMasked, isValueMasked && !isValueUpdated {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument,
                                                              to: textField.endOfDocument)
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let isValueMasked = field.fieldValueMasked, isValueMasked && !isValueUpdated {
            textField.text = ""
        }
        isValueUpdated = true
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let isValueMasked = field.fieldValueMasked, isValueMasked && !isValueUpdated {
            return
        }
        let isFieldValid = isValid()
        if !isFieldValid {
            showError()
        } else {
            hideError()
        }
        inputHandler?()
    }

    //swiftlint:disable unavailable_function
    func value() -> String {
        fatalError("value() has not been implemented")
    }

    private func isInvalidEmptyValue() -> Bool {
        let isInvalid = field.isRequired ?? false && value().isEmpty
        if isInvalid {
            updateErrorMessage(with: field.validationMessage?.empty ?? "")
        }
        return isInvalid
    }

    /// Checks the field should be validated by min and max length constraint
    private func isInvalidLength() -> Bool {
        let minLength = field.minLength ?? 0
        let maxLength = field.maxLength ?? Int.max
        let isInvalid = !value().isEmpty && (value().count < minLength || value().count > maxLength)
        if isInvalid {
            updateErrorMessage(with: field.validationMessage?.length ?? "")
        }
        return isInvalid
    }

    /// Checks the field should be validated by regex constraint
    private func isInvalidRegex() -> Bool {
        guard !value().isEmpty, let regexExpression = field.regularExpression else {
            return false
        }
        let isInvalid = !NSRegularExpression(regexExpression).matches(value())
        if isInvalid {
            updateErrorMessage(with: field.validationMessage?.pattern ?? "")
        }
        return isInvalid
    }

    /// Updates error message with given text
    private func updateErrorMessage(with message: String) {
        errorMessage = (field.label ?? "") + ": " + message
    }

    private func trackError() {
        if let fieldName = field.name,
            let errorMessage = getErrorMessage() {
            let errorInfo = ErrorInfoBuilder(type: errorTypeForm,
                                             message: errorMessage)
                .fieldName(fieldName)
                .build()
            hyperwalletInsights.trackError(pageName: pageName,
                                           pageGroup: pageGroup,
                                           errorInfo: errorInfo)
        }
    }
}
