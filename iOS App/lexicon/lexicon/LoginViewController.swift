//
//  ViewController.swift
//  lexicon
//
//  Created by James Chapman on 20/02/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else {
            self.doLogin()
        }
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let languages = (segue.destination as? UINavigationController)?.topViewController as? LanguageViewController {
            languages.loadLanguages()
        } else if let tabBar = segue.destination as? UITabBarController,
                  let vocabulary = (tabBar.viewControllers?[0] as? UINavigationController)?.topViewController as? VocabularyViewController,
                  let reports = (tabBar.viewControllers?[1] as? UINavigationController)?.topViewController as? ReportsViewController
        {
            vocabulary.loadCategories()
            reports.loadReports()
        }
    }
    
    func doLogin() {
        guard let username = self.usernameTextField.text,
              let password = self.passwordTextField.text,
			  !username.isEmpty, !password.isEmpty
        else {
            return
        }
        
        ServerHelper.login(username: username, password: password)
            .then { _ in
				self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }.catch { error in
				if let user = User.get() {
					ServerHelper.user = user
					self.performSegue(withIdentifier: "loginSegue", sender: nil)
				} else if let status = (error as? HTTPStatusError)?.status {
					switch status {
					case 401:
						self.showErrorAlert(message: "Password incorrect")
					case 404:
						self.showErrorAlert(message: "Username not found")
					default:
						self.showErrorAlert()
					}
				} else {
                    let error = error as NSError
					
                    if error.domain != NSURLErrorDomain && error.code != NSURLErrorBadURL {
                        self.showErrorAlert()
                    }
                }
            }
    }
    
    @IBAction func loginButtonPress(_ sender: UIButton) {
        self.doLogin()
    }
    
    @IBAction func registerButtonPress(_ sender: UIButton) {
        guard !(self.usernameTextField.text?.isEmpty ?? true),
              !(self.passwordTextField.text?.isEmpty ?? true)
        else {
            return
        }
        
        self.performSegue(withIdentifier: "registerSegue", sender: nil)
    }
    
    @IBAction func unwindFromLanguageSelection(_ sender: UIStoryboardSegue) {
        guard let source = sender.source as? LanguageViewController,
              let username = self.usernameTextField.text,
              let password = self.passwordTextField.text
        else {
            return
        }
        
        let langFrom = source.fromLang!
        let langTo = source.languages[(source.collectionView?.indexPathsForSelectedItems?[0].row)!]
        
        ServerHelper.register(username: username, password: password, to: langTo, from: langFrom)
            .then {
                self.doLogin()
            }.catch { error in
                if let status = (error as? HTTPStatusError)?.status {
                    switch status {
                    case 409:
                        self.showErrorAlert(message: "Username already in use!")
                    default:
                        self.showErrorAlert()
                    }
                } else {
                    let error = error as NSError
                    
                    if error.domain != NSURLErrorDomain && error.code != NSURLErrorBadURL {
                        self.showErrorAlert()
                    }
                }
            }
        
    }
	
	@IBAction func unwindFromMain(_ sender: UIStoryboardSegue) {
		self.usernameTextField.text = nil
		self.passwordTextField.text = nil
		
		ServerHelper.user = nil
		let _: [User] = User.deleteAll()
		CoreDataHelper.saveContext()
	}
}

