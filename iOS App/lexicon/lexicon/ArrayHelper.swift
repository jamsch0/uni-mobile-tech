//
//  ArrayHelper.swift
//  lexicon
//
//  Created by Tom Gardiner on 21/04/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import Foundation

extension Array {
	// Shuffles the collection in place.
	mutating func shuffle() {
		// Fisher-Yates shuffle algoritm
		for i in (0..<self.count).reversed() {
			let j = Int(arc4random_uniform(UInt32(i)))
			self.swap(i, j)
		}
	}
	
	// Returns the elements of the collection, shuffled.
	func shuffled() -> [Element] {
		var newArray = self
		newArray.shuffle()
		
		return newArray
	}
	
	// Swaps two elements in the collection.
	mutating func swap(_ i: Int, _ j: Int) {
		let temp = self[i]
		self[i] = self[j]
		self[j] = temp
	}
}
