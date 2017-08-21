//
//  ServerHelper.swift
//  lexicon
//
//  Created by James Chapman on 20/02/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

enum SerializationError: Error {
    case missing
    case invalid(Any)
}

struct HTTPStatusError: Error {
    let status: Int
}

struct ServerHelper {
    
    static var user: User?
    
    private static func makeRequest(path: String, method: HTTPMethod, body: Any?) -> Promise<(Int, Data?)> {
        guard let server = UserDefaults.standard.string(forKey: "serverPreference") else {
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
            return Promise(error: NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL))
        }
        
        var request = URLRequest(url: URL(string: server + path)!)
        request.httpMethod = method.rawValue
        
        if let token = self.user?.token {
            request.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body,
           let data = try? JSONSerialization.data(withJSONObject: body, options: [])
        {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        }
        
        return Promise { fulfill, reject in
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let error = error {
                    reject(error)
                }
                
                let status = (response as? HTTPURLResponse)?.statusCode ?? 503
                
                if status >= 200 && status < 400 {
                    fulfill((status, data))
                } else {
                    reject(HTTPStatusError(status: status))
                }
            }).resume()
        }
    }
    
    private static func convertToJson(_ status: Int, _ data: Data?) throws -> Promise<(Int, Any)> {
        if let data = data {
            return Promise(value: (status, try JSONSerialization.jsonObject(with: data, options: [])))
        }
        
        return Promise(error: SerializationError.missing)
    }
    
    static func getImage(path: String) -> Promise<(Int, Data)> {
        return self.makeRequest(path: path, method: .get, body: nil).then { (status, data) -> Promise<(Int, Data)> in
            if let data = data {
                return Promise(value: (status, data))
            }
            
            return Promise(error: SerializationError.missing)
        }
    }
    
    static func getImageFor(category: Category) -> Promise<UIImage?> {
        let categoryName = category.name.slug.replacingOccurrences(of: ".", with: "_")
        
        return self.getImage(path: "/images/categories/\(categoryName).jpg").then { (_, data) in
            category.imageData = data
            return Promise(value: category.image)
        }
    }
    
    static func getImageFor(language: Language) -> Promise<UIImage?> {
        return self.getImage(path: "/images/languages/\(language.isoCode).png").then { (_, data) in
            language.imageData = data
            return Promise(value: language.image)
        }
    }
    
    static func getImageFor(word: Word) -> Promise<UIImage?> {
        let wordName = word.slug.replacingOccurrences(of: ".", with: "_")
        
        return self.getImage(path: "/images/words/\(wordName).jpg").then { (_, data) in
            word.imageData = data
            return Promise(value: word.image)
        }
    }
    
    static func get(path: String) -> Promise<(Int, Any)> {
        return self.makeRequest(path: path, method: .get, body: nil).then(execute: self.convertToJson)
    }
    
    static func delete(path: String) -> Promise<Int> {
		return self.makeRequest(path: path, method: .delete, body: nil).then { (status, _) in return Promise(value: status) }
    }
    
    static func put(path: String, body: Any) -> Promise<Int> {
		return self.makeRequest(path: path, method: .put, body: body).then { (status, _) in return Promise(value: status) }
    }
    
    static func post(path: String, body: Any) -> Promise<(Int, Any)> {
        return self.makeRequest(path: path, method: .post, body: body).then(execute: self.convertToJson)
    }
    
    static func login(username: String, password: String) -> Promise<User> {
        return self.post(path: "/api/login", body: ["name": username, "password": password]).then { (_, json) in
            guard let user = User.create(fromJson: json) else {
                return Promise(error: SerializationError.invalid(json))
            }
            
            self.user = user
            return Promise(value: user)
        }
    }
    
    static func register(username: String, password: String, to langTo: Language, from langFrom: Language) -> Promise<Void> {
        let body: [String: Any] = ["name": username, "password": password, "to": langTo.isoCode, "from": langFrom.isoCode];
        return self.post(path: "/api/users", body: body).then { _ in return Promise(value: ()) }
    }
    
    static func getCategory(name: String) -> Promise<Category> {
        let path = "/api/categories/\(name)"
        
        return self.get(path: path).then { (_, json) in
            guard let category = Category.get(fromJson: json, createIfNotFound: true) else {
                return Promise(error: SerializationError.invalid(json))
            }
            
            return Promise(value: category)
        }
    }
    
	static func getCategories() -> Promise<[Category]> {
        let langTo = self.user!.langTo.isoCode
        let langFrom = self.user!.langFrom.isoCode
        let path = "/api/categories?lang=\(langTo)&lang=\(langFrom)"
        
        return self.get(path: path).then { (_, json) in
            guard let categoriesJson = json as? [Any] else {
                return Promise(error: SerializationError.invalid(json))
            }
            
            var categories: [Category] = []
            
            for categoryJson in categoriesJson {
                guard let category = Category.get(fromJson: categoryJson, createIfNotFound: true) else {
                    return Promise(error: SerializationError.invalid(categoryJson))
                }
                
                categories.append(category)
            }
            
            return Promise(value: categories)
        }
    }
    
    static func getLanguages() -> Promise<[Language]> {
        return self.get(path: "/api/languages").then { (_, json) in
            guard let languagesJson = json as? [Any] else {
                return Promise(error: SerializationError.invalid(json))
            }
            
            var languages: [Language] = []
            
            for languageJson in languagesJson {
                guard let language = Language.get(fromJson: languageJson, createIfNotFound: true) else {
                    return Promise(error: SerializationError.invalid(languageJson))
                }
                
                languages.append(language)
            }
            
            return Promise(value: languages)
        }
    }
    
    static func getTests() -> Promise<[Test]> {
        let path = "/api/users/\(self.user!.username)/tests"
    
        return self.get(path: path).then { (_, json) in
            guard let testsJson = json as? [Any] else {
                return Promise(error: SerializationError.invalid(json))
            }
            
            var tests: [Test] = []
            
            for testJson in testsJson {
				guard let test = Test.get(fromJson: testJson, createIfNotFound: true) else {
                    return Promise(error: SerializationError.invalid(testJson))
                }
                
                tests.append(test)
            }
            
            return Promise(value: tests)
        }
    }
    
    static func newTest(categories: [Category]) -> Promise<Test> {
        let langTo = self.user!.langTo.isoCode
        let langFrom = self.user!.langFrom.isoCode
        let path = "/api/users/\(self.user!.username)/tests/new"
        let body: [String: Any] = ["to": langTo, "from": langFrom, "categories": categories.map({ $0.name.slug })]
        
        return self.post(path: path, body: body).then { (_, json) in
            guard let test = Test.create(fromJson: json) else {
                return Promise(error: SerializationError.invalid(json))
            }
            
            return Promise(value: test)
        }
    }
    
    static func sendTest(_ test: Test) -> Promise<Test?> {
		if let id = test.id {
			return self.put(path: "/api/users/\(self.user!.username)/tests/\(id)", body: test.toJson()).then { _ in return Promise(value: nil) }
		} else {
			return self.post(path: "/api/users/\(self.user!.username)/tests", body: test.toJson()).then { (_, json) in
				guard let test = Test.create(fromJson: json) else {
					return Promise(error: SerializationError.invalid(json))
				}
				
				return Promise(value: test)
			}
		}
    }
    
	static func deleteTest(_ test: Test) -> Promise<Void> {
        return self.delete(path: "/api/users/\(self.user!.username)/tests/\(test.id!)").then { _ in return Promise(value: ()) }
    }
}
