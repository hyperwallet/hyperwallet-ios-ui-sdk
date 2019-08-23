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

import UIKit

/// The UIFont extension
public extension UIFont {
    var bold: UIFont { return withWeight(.bold) }
    var semibold: UIFont { return withWeight(.semibold) }
    var medium: UIFont { return withWeight(.medium) }

    /// To register UIFont
    ///
    /// - Parameters:
    ///   - fileName: String
    ///   - type: String
    static func register(_ fileName: String, type: String) {
        guard let resourceBundleURL = HyperwalletBundle.bundle.path(forResource: fileName, ofType: type) else {
            print("Font path not found")
            return
        }
        guard let fontData = NSData(contentsOfFile: resourceBundleURL),
            let dataProvider = CGDataProvider(data: fontData) else {
                print("Invalid font file")
                return
        }
        guard let fontRef = CGFont(dataProvider) else {
            print("Init font error")
            return
        }
        var errorRef: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) else {
            print("Register failed")
            return
        }
    }

    /// To add weight to preferredFont
    ///
    /// - Parameters:
    /// - weight : UIFont.Weight
    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
        traits[.weight] = weight
        attributes[.name] = fontName
        attributes[.traits] = traits
        attributes[.family] = familyName
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
