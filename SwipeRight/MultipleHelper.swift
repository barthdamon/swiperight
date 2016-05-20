//
//  MultipleCombination.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

struct MultipleCombination {
  var x: Int!
  var b: Int!
  var sum: Int!
}

class MultipleHelper: NSObject {
  
  static var defaultHelper = MultipleHelper()
  
  var range = 10
  func increaseRange() {
    range += 15
  }
  var allCombinations: Array<MultipleCombination> = []

  func initializeCombinations() {
    for xIndex in 2...12 {
      for bIndex in 2...12 {
        allCombinations.append(MultipleCombination(x: xIndex, b: bIndex, sum: xIndex * bIndex))
      }
    }
  }

  func combinationWithinRange() -> MultipleCombination {
    let filteredCombinations = allCombinations.filter { (combination) -> Bool in
      if combination.x < range && combination.b < range && combination.sum < range {
        return true
      } else {
        return false
      }
    }
    let filteredCount = filteredCombinations.count - 1
    let randomIndex = Int.random(0...filteredCount)
    return filteredCombinations[randomIndex]
  }
  
  
}