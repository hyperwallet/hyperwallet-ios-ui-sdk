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
                  pageGroup: String) {
        self.pageName = pageName
        self.pageGroup = pageGroup
        super.init(frame: CGRect())
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        spacing = 5
        distribution = .fill
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: 11.0, left: 0, bottom: 11.0, right: 16.0)
        self.field = field
        setupLayout(field: field)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func errorMessage() -> String? {
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
        label.textColor = Theme.Label.textColor
        label.accessibilityIdentifier = String(format: "%@", field.name ?? "")
    }

    func isValid() -> Bool {
        var isValid = true
        if isInvalidEmptyValue() || isInvalidLength() || isInvalidRegex() {
            trackError()
            isValid = false
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
        if let widthAnchor = label.superview?.widthAnchor {
            label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.35).isActive = true
        }
    }

    func showError() {
        label.textColor = Theme.Label.errorColor
        label.accessibilityIdentifier = String(format: "%@_error", field.name ?? "")
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if !isValid() {
            showError()
        } else {
            hideError()
        }
    }

    //swiftlint:disable unavailable_function
    func value() -> String {
        fatalError("value() has not been implemented")
    }

    private func isInvalidEmptyValue() -> Bool {
        return field.isRequired ?? false && value().isEmpty
    }

    /// Checks the field should be validated by min and max length constraint
    private func isInvalidLength() -> Bool {
        let minLength = field.minLength ?? 0
        let maxLength = field.maxLength ?? Int.max
        return !value().isEmpty && (value().count < minLength || value().count > maxLength)
    }

    /// Checks the field should be validated by regex constraint
    private func isInvalidRegex() -> Bool {
        guard !value().isEmpty, let regexExpression = field.regularExpression else {
            return false
        }
        return !NSRegularExpression(regexExpression).matches(value())
    }

    private func trackError() {
        if let fieldName = field.name,
            let errorMessage = errorMessage() {
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
