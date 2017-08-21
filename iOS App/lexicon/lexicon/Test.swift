//
//  Test.swift
//  lexicon
//
//  Created by James Chapman on 20/02/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import CoreData
import Foundation

public class Question: NSManagedObject {
	@NSManaged public var test: Test
	@NSManaged public var word: Word
    @NSManaged public var response: String?
    
    public var prompt: String? {
		return self.word.bestTranslation(for: self.test.langFrom)?.text
    }
    
    public var answer: String? {
		return self.word.bestTranslation(for: self.test.langTo)?.text
    }
    
    public var isAttempted: Bool {
        return self.response != nil && !self.response!.isEmpty
    }
    
    public var isCorrect: Bool {
        return self.response?.caseInsensitiveCompare(self.answer ?? "") == .orderedSame
    }
	
	public func toJson() -> [String: Any] {
		var json = ["word": self.word.slug]
		
		if let response = self.response {
			json["response"] = response
		}
		
		return json
	}
	
	public static func create(_ test: Test, word: Word) -> Question {
		let question: Question = self.insert()
		
		question.test = test
		question.word = word
		
		return question
	}
	
	public static func create(_ test: Test, fromJson json: Any) -> Question? {
		guard let json = json as? [String: Any],
			  let slug = json["word"] as? String,
			  let word = Word.get(slug: slug)
		else {
			return nil
		}
		
		let question = self.create(test, word: word)
		question.response = json["response"] as? String
		
		return question
	}
}

public class Test: NSManagedObject {
    @NSManaged public var id: String?
	@NSManaged public var userId: String
    @NSManaged public var created: Date
	@NSManaged public var completed: Date?
    @NSManaged public var langTo: Language
    @NSManaged public var langFrom: Language
    @NSManaged private var questionsSet: NSSet
	@NSManaged public var markedForSync: Bool
	@NSManaged public var markedForDeletion: Bool
	
	public var user: User? {
		return User.get(id: self.userId)
	}
	
	public var questions: [Question] {
		get {
			return self.questionsSet.allObjects as! [Question]
		}
		set {
			self.questionsSet = NSSet(array: newValue)
		}
	}
	
    public var attempted: Int {
        return self.questions.filter({ $0.isAttempted }).count
    }
    
    public var correct: Int {
        return self.questions.filter({ $0.isCorrect }).count
    }
	
	public func toJson() -> [String: Any] {
		var json: [String: Any] = [
			"user": self.userId,
			"created": Date.isoString(from: self.created),
			"langTo": self.langTo.isoCode,
			"langFrom": self.langFrom.isoCode,
			"questions": self.questions.map({ $0.toJson() })
		]
		
		if let id = self.id {
			json["_id"] = id
		}
		
		if let completed = self.completed {
			json["completed"] = Date.isoString(from: completed)
		}
		
		return json
	}
	
	public static func create(id: String? = nil, userId: String, questions: [Question], to langTo: Language, from langFrom: Language, created: Date = Date(), completed: Date? = nil) -> Test {
		let test: Test = self.insert()
		
		test.id = id
		test.userId = userId
		test.created = created
		test.completed = completed
		test.langTo = langTo
		test.langFrom = langFrom
		test.questionsSet = NSSet(array: questions)
		test.markedForSync = false
		test.markedForDeletion = false
		
		return test
	}
	
	public static func create(fromJson json: Any) -> Test? {
		guard let json = json as? [String: Any],
			  let userId = json["user"] as? String,
			  let created = json["created"] as? String,
			  let langToIsoCode = json["langTo"] as? String,
			  let langFromIsoCode = json["langFrom"] as? String,
			  let langTo = Language.get(isoCode: langToIsoCode),
			  let langFrom = Language.get(isoCode: langFromIsoCode),
			  let questions = json["questions"] as? [[String: Any]]
		else {
			return nil
		}
		
		let test: Test = self.insert()
		
		test.id = json["_id"] as? String
		test.userId = userId
		test.created = Date.date(isoString: created) ?? Date()
		test.langTo = langTo
		test.langFrom = langFrom
		test.questionsSet = NSSet(array: questions.flatMap { Question.create(test, fromJson: $0) })
		test.markedForSync = false
		test.markedForDeletion = false
		
		if let completed = json["completed"] as? String {
			test.completed = Date.date(isoString: completed)
		}
		
		return test
	}
	
	public static func get(id: String) -> Test? {
		return self.fetch(key: "id", value: id).first
	}
	
	public static func get(fromJson json: Any, createIfNotFound create: Bool = false) -> Test? {
		guard let json = json as? [String: Any],
			  let id = json["_id"] as? String
		else {
			return nil
		}
		
		return self.get(id: id) ?? (create ? self.create(fromJson: json) : nil)
	}
	
	public static func fetchAll(forUser user: User) -> [Test] {
		return self.fetch(key: "userId", value: user.id)
	}
}
