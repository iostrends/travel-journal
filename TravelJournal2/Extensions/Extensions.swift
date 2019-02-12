//
//  Extensions.swift
//  TravelJournal2
//
//  Created by Niclas Nordling on 2019-02-05.
//  Copyright © 2019 Niclas Nordling. All rights reserved.
//

import UIKit

extension UIButton {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UITextField {
    func setInsetLeft(_ amount:CGFloat){
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = padding
        self.leftViewMode = .always
    }
    func setInsetRight(_ amount:CGFloat) {
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = padding
        self.rightViewMode = .always
    }
}

extension UIColor {
    class func mainRed() -> UIColor {
        return UIColor(red: 144/255, green: 12/255, blue: 63/255, alpha: 1.0)
    }
    
    class func placeholderColor() -> UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.6)
    }
    
    class func loginBackground() -> UIColor {
        return UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 0.1)
    }
}

extension UIFont {
    class func logoFontNormal() -> UIFont {
        guard let font = UIFont(name: "Medinah", size: 85.0) else {
            return UIFont.systemFont(ofSize: 20)
        }
        return font
    }
    
    class func logoFontSmall() -> UIFont {
        guard let font = UIFont(name: "Medinah", size: 55.0) else {
            return UIFont.systemFont(ofSize: 20)
        }
        return font
    }
    
    class func buttonFont() -> UIFont {
        guard let font = UIFont(name: "Hamilyn", size: 30.0) else {
            return UIFont.systemFont(ofSize: 20)
        }
        return font
    }
    
    class func titleFont() -> UIFont {
        guard let font = UIFont(name: "AvenirNext-Regular", size: 25.0) else {
            return UIFont.systemFont(ofSize: 20)
        }
        return font
    }
    
    class func textFont() -> UIFont {
        guard let font = UIFont(name: "AvenirNext-Regular", size: 17.0) else {
            return UIFont.systemFont(ofSize: 20)
        }
        return font
    }
}
