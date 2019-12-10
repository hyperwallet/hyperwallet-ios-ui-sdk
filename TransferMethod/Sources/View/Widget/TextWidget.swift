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
        if (field.mask?.defaultPattern) != nil {
            let text = getUnformattedText()
            if !text.isEmpty {
                textField.text = formatDisplayString(with: getFormatPattern(inputText: text), inputText: text)
            } else {
                textField.text = ""
            }
        }
    }

    func formatDisplayString(with pattern: String?, inputText: String) -> String {
        if let pattern = pattern {
            let currentText = getTextForPatternCharacter(PatternCharacter.lettersAndNumbersPatternCharacter.rawValue,
                                                         inputText)
            var finalText = ""
            var currentIndex = CurrentIndex(textIndex: inputText.startIndex, patternIndex: pattern.startIndex)
            var isEscapedCharacter = false

            if let currentText = currentText, !currentText.isEmpty {
                var patternCharactersToBeWritten = ""

                while true {
                    let currentPatternCharacter = pattern[currentIndex.patternIndex]

                    if isEscapedCharacter {
                        isEscapedCharacter = false
                        finalText += String(currentPatternCharacter)
                        currentIndex.patternIndex = pattern.index(after: currentIndex.patternIndex)
                        if currentIndex.patternIndex >= pattern.endIndex
                            || currentIndex.textIndex >= currentText.endIndex {
                            break
                        }
                        continue
                    }

                    applyFormatForPatternCharacter(currentText: currentText,
                                                   finalText: &finalText,
                                                   currentIndex: &currentIndex,
                                                   pattern: pattern,
                                                   patternCharactersToBeWritten: &patternCharactersToBeWritten)
                    isEscapedCharacter = self.isEscapedCharacter(currentPatternCharacter)

                    if currentIndex.patternIndex >= pattern.endIndex
                        || currentIndex.textIndex >= currentText.endIndex {
                        break
                    }
                }
            }
            return finalText
        }
        return inputText
    }

    private func applyFormatForPatternCharacter(currentText: String,
                                                finalText: inout String,
                                                currentIndex: inout CurrentIndex,
                                                pattern: String,
                                                patternCharactersToBeWritten: inout String) {
        let currentPatternCharacter = pattern[currentIndex.patternIndex]
        let currentTextCharacter = currentText[currentIndex.textIndex]

        switch currentPatternCharacter {
        case PatternCharacter.lettersAndNumbersPatternCharacter.rawValue:
            formatTextForLettersAndNumbers(currentTextCharacter: currentTextCharacter,
                                           finalText: &finalText,
                                           currentIndex: &currentIndex,
                                           pattern: pattern,
                                           patternCharactersToBeWritten: &patternCharactersToBeWritten)
            currentIndex.textIndex = currentText.index(after: currentIndex.textIndex)

        case PatternCharacter.lettersOnlyPatternCharacter.rawValue,
             PatternCharacter.numbersOnlyPatternCharacter.rawValue:
            let filteredCharacter =
                getTextForPatternCharacter(currentPatternCharacter, String(currentTextCharacter))
            if let filteredCharacter = filteredCharacter?.first {
                formatTextForLettersAndNumbers(currentTextCharacter: filteredCharacter,
                                               finalText: &finalText,
                                               currentIndex: &currentIndex,
                                               pattern: pattern,
                                               patternCharactersToBeWritten: &patternCharactersToBeWritten)
            }
            currentIndex.textIndex = currentText.index(after: currentIndex.textIndex)

        default:
            if !self.isEscapedCharacter(currentPatternCharacter) {
                if currentPatternCharacter == currentTextCharacter {
                    finalText += String(currentTextCharacter)
                    currentIndex.textIndex = currentText.index(after: currentIndex.textIndex)
                } else {
                    patternCharactersToBeWritten += String(currentPatternCharacter)
                }
            }
            currentIndex.patternIndex = pattern.index(after: currentIndex.patternIndex)
        }
    }

    private func formatTextForLettersAndNumbers(currentTextCharacter: Character,
                                                finalText: inout String,
                                                currentIndex: inout CurrentIndex,
                                                pattern: String,
                                                patternCharactersToBeWritten: inout String) {
        finalText += patternCharactersToBeWritten
        patternCharactersToBeWritten = ""
        finalText += String(currentTextCharacter)
        currentIndex.patternIndex = pattern.index(after: currentIndex.patternIndex)
    }

    private func getTextForPatternCharacter(_ patternCharacter: Character, _ text: String) -> String? {
        switch patternCharacter {
        case PatternCharacter.lettersAndNumbersPatternCharacter.rawValue:
            return text
                .components(separatedBy: CharacterSet(charactersIn: allowedLetters + allowedNumbers).inverted).joined()

        case PatternCharacter.lettersOnlyPatternCharacter.rawValue:
            return text.components(separatedBy: CharacterSet(charactersIn: allowedLetters).inverted).joined()

        case PatternCharacter.numbersOnlyPatternCharacter.rawValue:
            return text.components(separatedBy: CharacterSet(charactersIn: allowedNumbers).inverted).joined()

        default:
            return nil
        }
    }

    func getFormatPattern(inputText: String) -> String? {
        var maskPattern = field.mask?.defaultPattern
        let conditionalPatterns = field.mask?.conditionalPatterns

        if let matchingConditionalPattern = conditionalPatterns?.first(where: {
            NSRegularExpression($0.regex).matches(inputText)
        }) {
            maskPattern = matchingConditionalPattern.pattern
        }
        return maskPattern
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
            return getTextForPatternCharacter(PatternCharacter.lettersAndNumbersPatternCharacter.rawValue, text) ?? ""
        }
        return ""
    }

}

private struct CurrentIndex {
    var textIndex: String.Index
    var patternIndex: String.Index
}

private enum PatternCharacter: Character {
    case lettersAndNumbersPatternCharacter = "*"
    case lettersOnlyPatternCharacter = "@"
    case numbersOnlyPatternCharacter = "#"
}
