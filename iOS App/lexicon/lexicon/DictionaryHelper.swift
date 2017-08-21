//
//  DictionaryHelper.swift
//  lexicon
//
//  Created by James Chapman on 02/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

extension Dictionary {
    subscript(key: Key, withDefault value: @autoclosure (Void) -> Value) -> Value {
        mutating get {
            if self[key] == nil {
                self[key] = value()
            }
            
            return self[key]!
        }
        set {
            self[key] = newValue
        }
    }
}
