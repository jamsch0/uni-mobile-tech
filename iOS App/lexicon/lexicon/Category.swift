//
//  Category.swift
//  lexicon
//
//  Created by James Chapman on 03/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import CoreData
import UIKit

public class Category: NSManagedObject {
    @NSManaged public var name: Word
	@NSManaged public var imageData: Data?
	@NSManaged private var wordsSet: NSSet
	
	public var words: [Word] {
		return self.wordsSet.allObjects as! [Word]
	}
	
	public var image: UIImage? {
		if let data = self.imageData {
			return UIImage(data: data)
		} else {
			return nil
		}
	}
	
	public static func create(name: Word, words: [Word]) -> Category {
		let category: Category = self.insert()
		
		category.name = name
		category.wordsSet = NSSet(array: words)
		
		return category
	}
	
	public static func create(fromJson json: Any) -> Category? {
		guard let json = json as? [String: Any],
			  let name = Word.get(fromJson: json["name"] as Any),
			  let words = json["words"] as? [[String: Any]]
		else {
			return nil
		}
		
		return self.create(name: name, words: words.flatMap { Word.get(fromJson: $0, createIfNotFound: true) })
	}
	
	public static func get(name: Word) -> Category? {
		return self.fetch(key: "name", value: name).first
	}
	
	public static func get(fromJson json: Any, createIfNotFound create: Bool = false) -> Category? {
		guard let json = json as? [String: Any],
			  let name = Word.get(fromJson: json["name"] as Any, createIfNotFound: true)
		else {
			return nil
		}
		
		return self.get(name: name) ?? (create ? self.create(fromJson: json) : nil)
	}
}
