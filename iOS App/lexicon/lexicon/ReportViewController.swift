//
//  ReportViewController.swift
//  lexicon
//
//  Created by James Chapman on 06/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import Social
import UIKit

class ReportTableViewCell: UITableViewCell {
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!
}

class ReportViewController: UITableViewController {
    let formatter = DateFormatter()
    var test: Test!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.formatter.dateStyle = DateFormatter.Style.short
        self.formatter.timeStyle = DateFormatter.Style.short
        
        self.navigationItem.title = "Test: \(self.formatter.string(from: self.test.completed!))"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.test.questions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let question = self.test.questions[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportTableViewCell", for: indexPath) as! ReportTableViewCell
        cell.promptLabel.text = "Question \(indexPath.row + 1): \(question.prompt ?? question.word.slug)"
        
        let response = question.response ?? "Not attempted"
        
        if question.isCorrect {
            cell.responseLabel.text = response
            cell.accessoryType = .checkmark
        } else {
            let correctAnswer = " (\(question.answer ?? question.word.slug))"
            
            let attributedString = NSMutableAttributedString(string: response + correctAnswer)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 0, length: response.characters.count))
            
            cell.responseLabel.attributedText = attributedString
            cell.accessoryType = .none
        }

        return cell
    }
    
    @IBAction func shareButtonPress(_ sender: UIBarButtonItem) {
        guard self.test.completed != nil else {
            return
        }
        
        let langName = (self.test.langTo.name?.bestTranslation(for: self.test.langFrom)?.text)!
        let text = "I just got \(self.test.correct) out of \(self.test.questions.count) questions correct on a \(langName) test using the Lexicon app! Come learn \(langName) with me today!"
       
        if let tweetCompose = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
            tweetCompose.setInitialText(text)
            self.present(tweetCompose, animated: true, completion: nil)
        }
    }
    
    @IBAction func suggestTranslationPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
              let indexPath = self.tableView.indexPathForRow(at: sender.location(in: self.view))
        else {
            return
        }
        
        let word = self.test.questions[indexPath.row].word
        let translation = word.bestTranslation(for: self.test.langTo)
        
        let alert = UIAlertController(title: "Rate Translation", message: "Increase the translation's rating by pressing Send or suggest a new one in the box below.", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { $0.text = translation?.text })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { action in
            guard let text = alert.textFields?[0].text else {
                return
            }
            
//            if text == translation?.text {
//                word.translations[self.test.langTo]
//            } else {
//                word.translations[self.test.langTo]?.append(Translation(text: text))
//            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
