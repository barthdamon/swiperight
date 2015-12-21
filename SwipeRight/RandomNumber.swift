//
//  RandomNumber.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

//Random number generator
func randoNumber(min: UInt32?, max:UInt32) -> Int {
  var result = Int(arc4random_uniform(max + 1))
  
  func getRandom() {
    let check = arc4random_uniform(max + 1)
    if check < min {
      getRandom()
    } else {
      result = Int(check)
    }
  }
  
  if let _ = min {
    getRandom()
    return result
  } else {
    return result
  }
}