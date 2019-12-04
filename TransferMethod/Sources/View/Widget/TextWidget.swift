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
    private var allowedLetters: String {
        let lowercaseLetters = UInt32("a") ... UInt32("z")
        let uppercaseLetters = UInt32("A") ... UInt32("Z")
        return String(String.UnicodeScalarView(lowercaseLetters.compactMap(UnicodeScalar.init)) +
            uppercaseLetters.compactMap(UnicodeScalar.init))
    }

    private var allowedNumbers: String {
        let numbers = UInt32("0") ... UInt32("9")
        return String(String.UnicodeScalarView(numbers.compactMap(UnicodeScalar.init)))
    }

    var textField: PasteOnlyTextField = {
        let textField = PasteOnlyTextField()
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        if #available(iOS 11.0, *) {
            textField.textDragInteraction?.isEnabled = false
        }
        return textField
    }()

    override func value() -> String {
        if let scrubRegex = field.mask?.scrubRegex,
            let text = textField.text {
            return getScrubbedText(formattedText: text, scrubRegex: scrubRegex)
        }
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
        if let valueString = field.value {
            textField.text = formatDisplayString(with: getFormatPattern(inputText: valueString), inputText: valueString)
        } else {
            textField.text = field.value
        }

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
        textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        addArrangedSubview(textField)
    }

    @objc
    private func textFieldDidChange() {
        let text = getUnformattedText()
        if !text.isEmpty {
            textField.text = formatDisplayString(with: getFormatPattern(inputText: text), inputText: text)
        } else {
            textField.text = ""
        }
    }

    func formatDisplayString(with pattern: String?, inputText: String) -> String {
        if let pattern = pattern {
            let currentText = getTextForPatternCharacter(PatternCharacter.anyPatternCharacter.rawValue,
                                                         inputText)
            var currentTextIndex = inputText.startIndex
            var finalText = ""
            var isEscapedCharacter = false
            var patternIndex = pattern.startIndex

            if let currentText = currentText, !currentText.isEmpty {
                var patternCharactersToBeWritten = ""

                while true {
                    let patternRange = patternIndex ..< pattern.index(after: patternIndex)
                    let currentPatternCharacter = [Character](pattern[patternRange])
                    let currentTextRange = currentTextIndex ..< currentText.index(after: currentTextIndex)
                    let currentTextCharacter = String(currentText[currentTextRange])

                    if isEscapedCharacter {
                        isEscapedCharacter = false
                        finalText += currentPatternCharacter
                        patternIndex = pattern.index(after: patternIndex)
                        if patternIndex >= pattern.endIndex || currentTextIndex >= currentText.endIndex {
                            break
                        }
                        continue
                    }

                    applyFormatForPatternCharacter(currentPatternCharacter: currentPatternCharacter,
                                                   currentText: currentText,
                                                   currentTextCharacter: currentTextCharacter,
                                                   currentTextIndex: &currentTextIndex,
                                                   finalText: &finalText,
                                                   isEscapedCharacter: &isEscapedCharacter,
                                                   pattern: pattern,
                                                   patternIndex: &patternIndex,
                                                   patternCharactersToBeWritten: &patternCharactersToBeWritten)

                    if patternIndex >= pattern.endIndex || currentTextIndex >= currentText.endIndex {
                        break
                    }
                }
            }
            return finalText
        }
        return inputText
    }

    // swiftlint:disable function_parameter_count
    private func applyFormatForPatternCharacter(currentPatternCharacter: [Character],
                                                currentText: String,
                                                currentTextCharacter: String,
                                                currentTextIndex: inout String.Index,
                                                finalText: inout String,
                                                isEscapedCharacter: inout Bool,
                                                pattern: String,
                                                patternIndex: inout String.Index,
                                                patternCharactersToBeWritten: inout String) {
        switch currentPatternCharacter.first {
        case PatternCharacter.anyPatternCharacter.rawValue:
            handleTextForLettersAndNumbers(currentText: currentText,
                                           currentTextCharacter: currentTextCharacter,
                                           currentTextIndex: &currentTextIndex,
                                           finalText: &finalText,
                                           pattern: pattern,
                                           patternCharactersToBeWritten: &patternCharactersToBeWritten,
                                           patternIndex: &patternIndex)

        case PatternCharacter.lettersOnlyPatternCharacter.rawValue,
             PatternCharacter.numbersOnlyPatternCharacter.rawValue:
            let filteredCharacter =
                getTextForPatternCharacter(currentPatternCharacter.first!, currentTextCharacter)
            handleTextForLettersAndNumbers(currentText: currentText,
                                           currentTextCharacter: filteredCharacter,
                                           currentTextIndex: &currentTextIndex,
                                           finalText: &finalText,
                                           pattern: pattern,
                                           patternCharactersToBeWritten: &patternCharactersToBeWritten,
                                           patternIndex: &patternIndex)

        default:
            isEscapedCharacter = self.isEscapedCharacter(currentPatternCharacter.first!)
            if !isEscapedCharacter {
                if String(currentPatternCharacter) == currentTextCharacter {
                    finalText += currentTextCharacter
                    currentTextIndex = currentText.index(after: currentTextIndex)
                } else {
                    patternCharactersToBeWritten += currentPatternCharacter
                }
            }
            patternIndex = pattern.index(after: patternIndex)
        }
    }

    private func handleTextForLettersAndNumbers(currentText: String,
                                                currentTextCharacter: String?,
                                                currentTextIndex: inout String.Index,
                                                finalText: inout String,
                                                pattern: String,
                                                patternCharactersToBeWritten: inout String,
                                                patternIndex: inout String.Index) {
        if let currentTextCharacter = currentTextCharacter, !currentTextCharacter.isEmpty {
            finalText += patternCharactersToBeWritten
            patternCharactersToBeWritten = ""
            finalText += currentTextCharacter
            patternIndex = pattern.index(after: patternIndex)
        }
        currentTextIndex = currentText.index(after: currentTextIndex)
    }

    private func getTextForPatternCharacter(_ patternCharacter: Character, _ text: String) -> String? {
        switch patternCharacter {
        case PatternCharacter.anyPatternCharacter.rawValue:
            return text

        case PatternCharacter.lettersOnlyPatternCharacter.rawValue:
            return text.components(separatedBy: CharacterSet(charactersIn: allowedLetters).inverted).joined()

        case PatternCharacter.numbersOnlyPatternCharacter.rawValue:
            return text.components(separatedBy: CharacterSet(charactersIn: allowedNumbers).inverted).joined()

        default:
            return nil
        }
    }

    private func getFormatPattern(inputText: String) -> String? {
        return getMaskPattern(inputText: inputText,
                              defaultPattern: field.mask?.defaultPattern,
                              conditionalPatterns: field.mask?.conditionalPatterns)
    }

    func getMaskPattern(inputText: String,
                        defaultPattern: String?,
                        conditionalPatterns: [HyperwalletSDK.HyperwalletConditionalPattern]?) -> String? {
        let scrubbedText = getTextForPatternCharacter(PatternCharacter.anyPatternCharacter.rawValue,
                                                      inputText)
        if let scrubbedText = scrubbedText,
           let matchingConditionalPattern = conditionalPatterns?.first(where: {
            NSRegularExpression($0.regex).matches(scrubbedText)}) {
            return matchingConditionalPattern.pattern
        }
        return defaultPattern
    }

    private func isEscapedCharacter(_ character: Character) -> Bool {
        return character == "\\"
    }

    func getScrubbedText(formattedText: String, scrubRegex: String) -> String {
        return formattedText.replacingOccurrences(
            of: scrubRegex,
            with: "",
            options: NSString.CompareOptions.regularExpression,
            range: nil)
    }

    private func getUnformattedText() -> String {
        if let text = textField.text {
            return getTextForPatternCharacter(PatternCharacter.anyPatternCharacter.rawValue, text) ?? ""
        }
        return ""
    }
}

private enum PatternCharacter: Character {
    case anyPatternCharacter = "*"
    case lettersOnlyPatternCharacter = "@"
    case numbersOnlyPatternCharacter = "#"
}
