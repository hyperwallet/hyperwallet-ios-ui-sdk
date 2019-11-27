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

/// Represents the text input widget.
class TextWidget: AbstractWidget {
    var textField: PasteOnlyTextField = {
        let textField = PasteOnlyTextField()
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        if #available(iOS 11.0, *) {
            textField.textDragInteraction?.isEnabled = false
        }
        return textField
    }()

    override func value() -> String {
        return textField.text ?? ""
    }

    override func focus() {
        textField.becomeFirstResponder()
    }

    override func handleTap(sender: UITapGestureRecognizer? = nil) {
        focus()
    }

    override func setupLayout(field: HyperwalletField) {
        super.setupLayout(field: field)
        setUpTextField(for: field)
    }

    private func setUpTextField(for field: HyperwalletField) {
        textField.placeholder = "\(field.placeholder ?? "")"
        textField.delegate = self
        textField.accessibilityIdentifier = field.name
        textField.text = field.value

        if field.isEditable ?? true {
            textField.isUserInteractionEnabled = true
            textField.clearButtonMode = .always
            textField.textColor = Theme.Text.color
        } else {
            textField.clearButtonMode = .never
            textField.textColor = Theme.Text.disabledColor
        }
        textField.isUserInteractionEnabled = field.isEditable ?? true
        textField.clearButtonMode = field.isEditable ?? true ? .always : .never
        textField.textColor = field.isEditable ?? true ? Theme.Text.color : Theme.Text.disabledColor
        textField.font = Theme.Label.bodyFont
        textField.adjustsFontForContentSizeCategory = true
        addArrangedSubview(textField)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let pattern = "+# (@@@) ***-####" // temporarily for testing
        if !string.isEmpty && !pattern.isEmpty {
            var inputText = string
            var currentText = textField.text ?? ""
            let startIndex = currentText.index(currentText.startIndex, offsetBy: range.location)
            if range.length > 0 {
                let replaceRange = startIndex ..< currentText.index(startIndex, offsetBy: range.length)
                currentText = currentText.replacingCharacters(in: replaceRange, with: string)
                inputText = ""
            }
            textField.text = formatDisplayString(inputText: inputText,
                                                 formattedText: currentText,
                                                 startIndex: range.location,
                                                 pattern: pattern)
            return false
        }
        return true
    }

    private func formatDisplayString(inputText: String,
                                     formattedText: String,
                                     startIndex: Int,
                                     pattern: String) -> String {
        var patternIndex = pattern.index(pattern.startIndex, offsetBy: startIndex)
        var currentTextIndex = formattedText.index(formattedText.startIndex, offsetBy: startIndex)
        let textBeforStartIndex = String(formattedText.prefix(upTo: currentTextIndex))
        let textAfterStartIndex = String(formattedText.suffix(from: currentTextIndex))
        var finalText = textBeforStartIndex

        if startIndex < pattern.count {
            let filteredTextAfterStartIndex =
                getTextForPatternCharacter(PatternCharacter.lettersAndNumbersPatternCharacter.rawValue,
                                           inputText + textAfterStartIndex)
            if let filteredTextAfterStartIndex = filteredTextAfterStartIndex, !filteredTextAfterStartIndex.isEmpty {
                let currentText = textBeforStartIndex + filteredTextAfterStartIndex
                while true {
                    let patternRange = patternIndex ..< pattern.index(after: patternIndex)
                    let currentPatternCharacter = String(pattern[patternRange])
                    let currentTextRange = currentTextIndex ..< currentText.index(after: currentTextIndex)
                    let currentTextCharacter = String(currentText[currentTextRange])

                    switch currentPatternCharacter {
                    case PatternCharacter.lettersAndNumbersPatternCharacter.rawValue:
                        finalText += currentTextCharacter
                        currentTextIndex = currentText.index(after: currentTextIndex)
                        patternIndex = pattern.index(after: patternIndex)

                    case PatternCharacter.lettersOnlyPatternCharacter.rawValue,
                         PatternCharacter.numbersOnlyPatternCharacter.rawValue:
                        let filteredCharacter =
                            getTextForPatternCharacter(currentPatternCharacter, currentTextCharacter)
                        if let filteredCharacter = filteredCharacter, !filteredCharacter.isEmpty {
                            finalText += filteredCharacter
                            patternIndex = pattern.index(after: patternIndex)
                        }
                        currentTextIndex = currentText.index(after: currentTextIndex)

                    default:
                        finalText += currentPatternCharacter
                        patternIndex = pattern.index(after: patternIndex)
                    }

                    if patternIndex >= pattern.endIndex || currentTextIndex >= currentText.endIndex {
                        break
                    }
                }
            }
        }
        return finalText
    }

    private func getTextForPatternCharacter(_ patternCharacter: String, _ text: String) -> String? {
        switch patternCharacter {
        case PatternCharacter.lettersAndNumbersPatternCharacter.rawValue:
            return text.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()

        case PatternCharacter.lettersOnlyPatternCharacter.rawValue:
            return text.components(separatedBy: CharacterSet.letters.inverted).joined()

        case PatternCharacter.numbersOnlyPatternCharacter.rawValue:
            return text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        default:
            return nil
        }
    }
}

enum PatternCharacter: String {
    case lettersAndNumbersPatternCharacter = "*"
    case lettersOnlyPatternCharacter = "@"
    case numbersOnlyPatternCharacter = "#"
}
