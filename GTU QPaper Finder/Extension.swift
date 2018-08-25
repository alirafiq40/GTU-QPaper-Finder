//
//  Extension.swift
//  DigiMenu
//
//  Created by Rayo2 on 9/28/17.
//  Copyright © 2017 Rayo Infotech. All rights reserved.
//

import UIKit

extension UIView {
    func addBorder(ofSize size:CGFloat?, color: UIColor?, cornerRadius: CGFloat?) {
        if let cornerRadius = cornerRadius {
            self.layer.cornerRadius = cornerRadius
        }
        if let size = size {
            self.layer.borderWidth = size
        }
        
        if let color = color {
            self.layer.borderColor = color.cgColor
        }
    }
}

extension Dictionary where Key == String {
    var success:Bool {
        if let result = self["success"] as? Int {
            return result == 1
        }
        return false
    }
    
    var message:String {
        if let result = self["message"] as? String {
            return result
        }
        return ""
    }
}

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1.0) {
        func intToColorFloat(int: Int) -> CGFloat {
            let divisor: CGFloat = 255
            return CGFloat(int) / divisor
        }
        self.init(red: intToColorFloat(int: r), green: intToColorFloat(int: g), blue: intToColorFloat(int: b), alpha: alpha)
    }
}

extension UIView {
    func makeCircular(forced:Bool? = false) {
        if self.frame.width == self.frame.height {
            self.layer.cornerRadius = self.frame.width / 2
            self.clipsToBounds = true
        } else if let forced = forced, forced == true {
            self.layer.cornerRadius = self.frame.height / 2
            self.clipsToBounds = true
        } else {
            print("View is not square")
        }
    }
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            let top = topViewController(nav.visibleViewController)
            return top
        }
        
        if let tab = base as? UITabBarController{
            if let selected = tab.selectedViewController {
                let top = topViewController(selected)
                return top
            }
        }
        
        if let presented = base?.presentedViewController{
            let top = topViewController(presented)
            return top
        }
        return base
    }
}
