//
//  Word.swift
//  lexicon
//
//  Created by James Chapman on 20/02/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import CoreData
import UIKit

public class Translation: NSManagedObject {
	@NSManaged public var text: String
    @NSManaged public var rating: Int
	@NSManaged public var language: Language
	
	public static func create(text: String, language: Language, rating: Int = 1) -> Translation {
		let translation: Translation = self.insert()
		
		translation.text = text
		translation.rating = rating
		translation.language = language
		
		return translation
	}
	
	public static func create(fromJson json: Any) -> Translation? {
		guard let json = json as? [String: Any],
			  let text = json["text"] as? String,
			  let rating = json["rating"] as? Int,
			  let isoCode = json["language"] as? String,
			  let language = Language.get(isoCode: isoCode)
		else {
			return nil
		}
		
		return self.create(text: text, language: language, rating: rating)
	}
}

public class Word: NSManagedObject {
    @NSManaged public var slug: String
	@NSManaged public var imageData: Data?
	@NSManaged private var translationsSet: NSSet
	
	public var image: UIImage? {
		if let data = self.imageData {
			return UIImage(data: data)
		} else {
			return nil
		}
	}
	
	public var translations: [Translation] {
		return self.translationsSet.allObjects as! [Translation]
	}
	
	public func bestTranslation(for language: Language) -> Translation? {
		return self.translations.first(where: { $0.language == language })
	}
	
	public static func create(slug: String, translations: [Translation]) -> Word {
		let word: Word = self.insert()
		
		word.slug = slug
		word.translationsSet = NSSet(array: translations)
		
		return word
	}
	
	public static func create(fromJson json: Any) -> Word? {
		guard let json = json as? [String: Any],
			  let slug = json["_id"] as? String,
			  let translations = json["translations"] as? [[String: Any]]
		else {
			return nil
		}
		
		return self.create(slug: slug, translations: translations.flatMap { Translation.create(fromJson: $0) })
	}
	
	public static func get(slug: String) -> Word? {
		return self.fetch(key: "slug", value: slug).first
	}
	
	public static func get(fromJson json: Any, createIfNotFound create: Bool = false) -> Word? {
		guard let json = json as? [String: Any],
			  let slug = json["_id"] as? String
		else {
			return nil
		}
		
		return self.get(slug: slug) ?? (create ? self.create(fromJson: json) : nil)
	}
}

func ==(lhs: Word, rhs: Word) -> Bool {
    return lhs.slug == rhs.slug
}
