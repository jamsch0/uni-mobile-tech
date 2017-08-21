//
//  Language.swift
//  lexicon
//
//  Created by James Chapman on 02/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import CoreData
import UIKit

public class Language: NSManagedObject {
	@NSManaged public var isoCode: String
	@NSManaged public var nameSlug: String
	@NSManaged public var imageData: Data?
	
	public var name: Word? {
		return Word.get(slug: self.nameSlug)
	}
	
	public var image: UIImage? {
		if let data = self.imageData {
			return UIImage(data: data)
		} else {
			return nil
		}
	}
	
	public static func create(isoCode: String, nameSlug: String) -> Language {
		let language: Language = self.insert()
		
		language.isoCode = isoCode;
		language.nameSlug = nameSlug;
		
		return language
	}
	
	public static func create(fromJson json: Any) -> Language? {
		guard let json = json as? [String: Any],
			  let isoCode = json["_id"] as? String,
			  let nameSlug = json["name"] as? String
		else {
			return nil
		}
		
		return self.create(isoCode: isoCode, nameSlug: nameSlug)
	}
	
	public static func get(isoCode: String) -> Language? {
		return self.fetch(key: "isoCode", value: isoCode).first
	}
	
	public static func get(fromJson json: Any, createIfNotFound create: Bool = false) -> Language? {
		guard let json = json as? [String: Any],
			  let isoCode = json["_id"] as? String
		else {
			return nil
		}
		
		return self.get(isoCode: isoCode) ?? (create ? self.create(fromJson: json) : nil)
	}
}

func ==(lhs: Language, rhs: Language) -> Bool {
    return lhs.isoCode == rhs.isoCode
}
