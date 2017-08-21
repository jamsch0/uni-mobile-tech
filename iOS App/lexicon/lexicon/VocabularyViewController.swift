//
//  VocabularyTableViewController.swift
//  lexicon
//
//  Created by James Chapman on 02/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import PromiseKit
import UIKit

class VocabularyTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var wordCountLabel: UILabel!
}

class VocabularyViewController: UITableViewController {
    var categories: [Category] = []
    var test: Test?
    
    @IBOutlet var startTestButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let langTo = ServerHelper.user!.langTo
        let langFrom = ServerHelper.user!.langFrom
        let category = self.categories[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "vocabularyTableViewCell", for: indexPath) as! VocabularyTableViewCell
        
        if let categoryNameLangTo = category.name.bestTranslation(for: langTo),
           let categoryNameLangFrom = category.name.bestTranslation(for: langFrom)
        {
            cell.categoryLabel.text = "\(categoryNameLangFrom.text) - \(categoryNameLangTo.text)"
        } else {
            cell.categoryLabel.text = category.name.slug
        }
        
        cell.categoryImage.image = category.image ?? #imageLiteral(resourceName: "defaultImage")
        cell.wordCountLabel.text = "\(category.words.count) words"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.updateStartTestButton()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.updateStartTestButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let destination = (segue.destination as? UINavigationController)?.topViewController as? TestViewController else {
            return
        }
        
        destination.test = self.test
        destination.unwindDestination = self
    }
    
    func loadCategories() {
        ServerHelper.getCategories()
            .then { categories -> Promise<Void> in
				self.categories = categories
				
                return when(resolved: categories.map { category in
                    ServerHelper.getImageFor(category: category)
                        .then { _ in
                            when(resolved: category.words.map { word in ServerHelper.getImageFor(word: word) })
                        }
                }).asVoid()
            }.catch { _ in
                self.categories = Category.fetchAll()
            }.always {
                self.tableView.reloadData()
            }
    }

    func updateStartTestButton() {
        self.startTestButton.isEnabled = (self.tableView.indexPathsForSelectedRows?.count ?? 0) > 0
    }
    
    @IBAction func startTestButtonPress(_ sender: UIBarButtonItem) {
        let categories = self.tableView.indexPathsForSelectedRows!.map({ self.categories[$0.row] })
        
        _ = ServerHelper.newTest(categories: categories).recover { _ -> Test in
			let user = ServerHelper.user!
			let test = Test.create(userId: user.id, questions: [], to: user.langTo, from: user.langFrom)
			test.questions = categories.map { $0.words }.joined().map { Question.create(test, word: $0) }.shuffled()
			
			return test
		}.then { test -> Void in
			self.test = test
			self.performSegue(withIdentifier: "startTestSegue", sender: nil)
		}
    }
		
    @IBAction func unwindFromTest(_ sender: UIStoryboardSegue) {
        self.tableView.indexPathsForSelectedRows?.forEach({ self.tableView.deselectRow(at: $0, animated: false) })
        self.updateStartTestButton()
        
        guard let source = sender.source as? TestViewController,
              let reports = (self.navigationController?.tabBarController?.viewControllers?[1] as? UINavigationController)?.topViewController as? ReportsViewController
        else {
            return
        }
        
        if source.test.completed != nil {
            reports.completedTests.append(source.test)
        } else {
            reports.incompleteTests.append(source.test)
        }
        
        reports.tableView.reloadData()
    }
}
