//
//  UIViewBorder.swift
//  lexicon
//
//  Created by James Chapman on 27/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let borderColor = self.layer.borderColor {
                return UIColor(cgColor: borderColor)
            } else {
                return nil
            }
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
}
