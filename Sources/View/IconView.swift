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

final class IconView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Theme.Icon.backgroundColor
        tintColor = Theme.Icon.color
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = Theme.Icon.backgroundColor
        tintColor = Theme.Icon.color
    }
    /// Draw an icon iamge
     ///
     /// - Parameter name: The font name of the icon
    func draw(fontName: String) {
        let icon = UIImage.fontIcon(fontName, CGSize(width: 40, height: 40), tintColor, backgroundColor)
        contentMode = .center
        layer.cornerRadius = frame.size.width / 2
        image = icon
        highlightedImage = nil
    }
}
