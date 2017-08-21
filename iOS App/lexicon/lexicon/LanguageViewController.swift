//
//  LanguageViewControllerCollectionViewController.swift
//  lexicon
//
//  Created by James Chapman on 27/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import PromiseKit
import UIKit

private let reuseIdentifier = "languageCollectionViewCell"

class LanguageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var languageImage: UIImageView!
    @IBOutlet weak var languageName: UILabel!
}

class LanguageViewController: UICollectionViewController {
    var languages: [Language] = []
    var fromLang: Language?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.collectionView?.allowsSelection = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.languages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let language = self.languages[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LanguageCollectionViewCell
        cell.languageName.text = language.name?.bestTranslation(for: self.fromLang ?? language)?.text ?? language.isoCode
        cell.languageImage.image = language.image ?? #imageLiteral(resourceName: "defaultImage")
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let language = self.languages[indexPath.row]
        
        guard (self.fromLang != nil && language.isoCode == "sv") || (self.fromLang == nil && language.isoCode == "en") else {
            return self.showErrorAlert(message: "\(language.name?.bestTranslation(for: self.fromLang ?? language)?.text ?? language.isoCode) is not implemented yet!")
        }
        
        if self.fromLang == nil {
            self.performSegue(withIdentifier: "nextLanguageSegue", sender: nil)
        } else {
            self.performSegue(withIdentifier: "registerSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextLanguageSegue" {
            let destination = segue.destination as! LanguageViewController
            
            let fromLang = self.languages[(self.collectionView?.indexPathsForSelectedItems?[0].row)!]
            
            destination.languages = self.languages.filter { $0 != fromLang }
            destination.fromLang = fromLang
        }
    }
    
    func loadLanguages() {
        ServerHelper.getLanguages()
            .then { languages -> Promise<Void> in
				self.languages = languages
				
                return when(resolved: languages.map { language in
                    ServerHelper.getImageFor(language: language)
                }).then { _ in
                    ServerHelper.getCategory(name: "language")
                }.asVoid()
            }.catch { error in
                self.languages = Language.fetchAll()
            }.always {
                self.collectionView!.reloadData()
			}
    }
}
