//
//  RandomNumber.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

//Random number generator
func randoNumber(minX minX:UInt32, maxX:UInt32) -> Int {
  if (minX == 1 && maxX == 1) || (minX == 0 && maxX == 1) {
    return 1
  } else {
    let result = (arc4random() % (maxX - minX + 1)) + minX
    return Int(result)
  }
}