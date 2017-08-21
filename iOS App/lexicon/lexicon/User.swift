//
//  User.swift
//  lexicon
//
//  Created by James Chapman on 03/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import CoreData
import Foundation

public class User: NSManagedObject {
	@NSManaged public var id: String
    @NSManaged public var created: Date
    @NSManaged public var username: String
    @NSManaged public var langTo: Language
    @NSManaged public var langFrom: Language
    
    public var token: String?
	
	public static func create(id: String, username: String, to langTo: Language, from langFrom: Language, created: Date = Date(), token: String? = nil) -> User {
		let user: User = self.insert()
		
		user.id = id
		user.created = created
		user.username = username
		user.langTo = langTo
		user.langFrom = langFrom
		user.token = token
		
		return user
	}
	
	public static func create(fromJson json: Any) -> User? {
		guard let json = json as? [String: Any],
			  let id = json["_id"] as? String,
			  let created = json["created"] as? String,
			  let username = json["name"] as? String,
			  let langTo = Language.get(fromJson: json["langTo"] as Any, createIfNotFound: true),
			  let langFrom = Language.get(fromJson: json["langFrom"] as Any, createIfNotFound: true)
		else {
			return nil
		}
		
		return self.create(id: id, username: username, to: langTo, from: langFrom, created: Date.date(isoString: created) ?? Date(), token: json["token"] as? String)
	}
	
	public static func get() -> User? {
		// We should only ever be storing the current user in CoreData, so there will be only one
		return self.fetchAll().first
	}
	
	public static func get(id: String) -> User? {
		return self.fetch(key: "id", value: id).first
	}
}
