import UIKit

extension UITextField {
    func setBottomBorder() {
        let caLayer = CALayer()
        caLayer.frame = CGRect(x: 0, y: self.frame.size.height + 3, width: self.frame.size.width, height: 1)
        caLayer.backgroundColor = UIColor(red: 203.0 / 255,
                                          green: 210.0 / 255,
                                          blue: 214.0 / 255,
                                          alpha: 1.0)
            .cgColor
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.clear.cgColor
        layer.addSublayer(caLayer)
    }
}
