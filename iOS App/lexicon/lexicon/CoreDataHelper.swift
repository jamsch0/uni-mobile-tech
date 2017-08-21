//
//  CoreDataHelper.swift
//  lexicon
//
//  Created by James Chapman on 08/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import CoreData

class CoreDataHelper {
    static let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "lexicon")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
	
	static var context: NSManagedObjectContext {
		return self.persistentContainer.viewContext
	}
    
    static func saveContext() {
        if self.context.hasChanges {
            do {
                try self.context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

extension NSManagedObject {
	func delete() {
		CoreDataHelper.context.delete(self)
	}
	
	static func getFetchRequest<T: NSManagedObject>() -> NSFetchRequest<T> {
		return NSFetchRequest(entityName: String(describing: T.self))
	}
	
	static func fetchAll<T: NSManagedObject>() -> [T] {
		let fetchRequest: NSFetchRequest<T> = T.getFetchRequest()
		
		do {
			return try CoreDataHelper.context.fetch(fetchRequest)
		} catch {
			let error = error as NSError
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
	}
	
	static func fetch<T: NSManagedObject, V: Equatable>(key: String, value: V) -> [T] {
		let fetchRequest: NSFetchRequest<T> = T.getFetchRequest()
		
		do {
			return try CoreDataHelper.context.fetch(fetchRequest).filter { $0.value(forKey: key) as? V == value }
		} catch {
			let error = error as NSError
			fatalError("unresolved error \(error), \(error.userInfo)")
		}
	}
	
	@discardableResult
	static func deleteAll<T: NSManagedObject>() -> [T] {
		let fetchRequest: NSFetchRequest<T> = T.getFetchRequest()
		
		do {
			let searchResults = try CoreDataHelper.context.fetch(fetchRequest)
			searchResults.forEach { CoreDataHelper.context.delete($0) }
			
			CoreDataHelper.saveContext()
			return searchResults
		} catch {
			let error = error as NSError
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
	}
	
	@discardableResult
	static func delete<T: NSManagedObject, V: Equatable>(key: String, value: V) -> T? {
		let fetchRequest: NSFetchRequest<T> = T.getFetchRequest()
		
		do {
			if let searchResult = try CoreDataHelper.context.fetch(fetchRequest).first { $0.value(forKey: key) as? V == value } {
				CoreDataHelper.context.delete(searchResult)
				CoreDataHelper.saveContext()
				
				return searchResult
			}
			
			return nil
		} catch {
			let error = error as NSError
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
	}
	
	static func insert<T: NSManagedObject>() -> T {
		return NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: CoreDataHelper.context) as! T
	}
}
