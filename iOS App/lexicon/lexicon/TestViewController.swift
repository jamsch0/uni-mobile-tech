//
//  TestViewController.swift
//  lexicon
//
//  Created by James Chapman on 02/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import AVFoundation
import UIKit

class TestViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var promptImage: UIImageView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var responseTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var test: Test!
    var questionCounter = 0
    var unwindDestination: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.responseTextField.delegate = self
        self.responseTextField.becomeFirstResponder()
        
        self.updatePromptLabel()
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        if self.responds(to: action) {
            return fromViewController == self.unwindDestination
        }
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ServerHelper.sendTest(self.test).catch { _ in
			self.test.markedForSync = true
		}
    }
    
    func speakAnswer() {
        guard let answer = self.test.questions[self.questionCounter].answer else {
            return
        }
        
        let utterance = AVSpeechUtterance(string: answer)
        utterance.voice = AVSpeechSynthesisVoice(language: self.test.langTo.isoCode)
        
        self.speechSynthesizer.speak(utterance)
    }
    
    func updatePromptLabel() {
        let question = self.test.questions[self.questionCounter]
        
        self.promptLabel.text = question.prompt
        self.responseTextField.text = question.response
        self.promptImage.image = question.word.image ?? #imageLiteral(resourceName: "defaultImage")
        
        self.navigationItem.title = "Question \(self.questionCounter + 1) of \(self.test.questions.count)"
    }
    
    func updateQuestionResponse() {
        self.test.questions[self.questionCounter].response = self.responseTextField.text
    }
    
    func previousQuestion() {
        self.updateQuestionResponse()
        self.responseTextField.returnKeyType = .next
        self.nextButton.setTitle("Next", for: .normal)
        
        if self.questionCounter > 0 {
            self.questionCounter -= 1
            self.updatePromptLabel()
        }
        
        if self.questionCounter == 0 {
            self.backButton.isEnabled = false
        }
    }
    
    func nextQuestion() {
        self.speakAnswer()
        
        self.updateQuestionResponse()
        self.backButton.isEnabled = true
        
        if self.questionCounter < self.test.questions.count - 1 {
            self.questionCounter += 1
            self.updatePromptLabel()
        } else {
            test.completed = Date()
            return self.performSegue(withIdentifier: "stopTestSegue", sender: nil)
        }
        
        if self.questionCounter == self.test.questions.count - 1 {
            self.responseTextField.returnKeyType = .done
            self.nextButton.setTitle("Done", for: .normal)
        }
    }
    
    func tryNextQuestion() {
        self.updateQuestionResponse()
        
        if self.test.questions[self.questionCounter].isCorrect {
            self.nextQuestion()
        } else {
            self.showBasicAlert(title: "Incorrect", message: "Sorry, that's not correct, please try again.")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tryNextQuestion()
        return false
    }
    
    @IBAction func skipButtonPress(_ sender: UIButton) {
        self.nextQuestion()
    }
    
    @IBAction func nextButtonPress(_ sender: UIButton) {
        self.tryNextQuestion()
    }
    
    @IBAction func backButtonPress(_ sender: UIBarButtonItem) {
        self.previousQuestion()
    }
    
    @IBAction func stopTestButtonPress(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Stop Test",
                                      message: "Are you sure you want to stop the test? This will not mark the test as completed and can be resumed from the reports menu.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "stopTestSegue", sender: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
