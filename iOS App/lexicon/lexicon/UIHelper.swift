//
//  UIHelper.swift
//  lexicon
//
//  Created by James Chapman on 20/02/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showBasicAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String = "Unknown error") {
        showBasicAlert(title: "Error", message: message)
    }
}
