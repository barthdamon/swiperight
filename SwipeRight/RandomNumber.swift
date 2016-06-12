//
//  RandomNumber.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit


//Random number generator
extension Int
{
  static func random(range: Range<Int> ) -> Int
  {
    var offset = 0
    
    if range.startIndex < 0   // allow negative ranges
    {
      offset = abs(range.startIndex)
    }
    
    let mini = UInt32(range.startIndex + offset)
    let maxi = UInt32(range.endIndex   + offset)
    
    return Int(mini + arc4random_uniform(maxi - mini)) - offset
  }
  
  static func randomDivisible() -> Int {
    let random = Int(2 + arc4random_uniform(40 - 2)) - 0
    return 2 * random
  }
}