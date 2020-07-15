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

/// A HyperwalletUI extension to UIImage.
public extension UIImage {
    /// Get an icon image with the given icon name, text color, size and background color
    ///
    /// - Parameters:
    ///   - name: The preferred `HyperwalletIconContent`.
    ///   - iconSize: The image size
    ///   - fontSize: The font size of the icon
    ///   - textColor: The text color (optional).
    /// - returns: A string that will appear as icon
    static func fontIcon(_ name: String,
                         _ iconSize: CGSize,
                         _ fontSize: CGFloat,
                         _ textColor: UIColor) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        let fontSize = fontSize
        let attributedString = NSAttributedString(string: name, attributes: [
            NSAttributedString.Key.font: UIFont(name: "hw_mobile_ui_sdk_icons", size: fontSize)!,
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraph
        ])

        UIGraphicsBeginImageContextWithOptions(iconSize, false, 0.0)
        attributedString.draw(in: CGRect(x: 0,
                                         y: (iconSize.height - fontSize) / 2,
                                         width: iconSize.width,
                                         height: fontSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// Create Background Pattern
    ///
    /// - Parameters:
    ///   - color: UIColor
    ///   - size: CGSize
    ///   - cornerRadius: Int
    /// - Returns: UIImage
    static func createBackgroundPattern(color: UIColor, size: CGSize, cornerRadius: Int) -> UIImage {
        let image = imageWithColor(color: color, size: size)
        return roundedImage(image: image, cornerRadius: cornerRadius)
    }

    /// Get an image with specified colors
    ///
    /// - Parameters:
    ///   - color: color of the image
    ///   - size: size for the image
    /// - Returns: image
    private static func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()

        UIRectFill(rect)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("can't create image")
        }
        UIGraphicsEndImageContext()
        return image
    }

    /// Get the image with rounded corners
    ///
    /// - Parameters:
    ///   - image: image to be formatted
    ///   - cornerRadius: cornerRadius
    /// - Returns: image with rounded corners
    private static func roundedImage(image: UIImage, cornerRadius: Int) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: CGFloat(cornerRadius)
            ).addClip()
        image.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
