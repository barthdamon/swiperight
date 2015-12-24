//
//  RandomNumber.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

import Foundation


//Random number generator
func randoNumber(min: Int?, max:Int) -> Int {
  if max < 0 {
    return Int(arc4random_uniform(50))
  } else {
    var result = Int(arc4random_uniform(UInt32(max) + 1))
    
    func getRandom() {
      let check = arc4random_uniform(UInt32(max) + 1)
      if check < UInt32(min!) {
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
}


//Random number generator
//func randoNumber(min: UInt32?, max:UInt32) -> Int {
//  if max < 0 {
//    return Int(arc4random_uniform(50 + 1))
//  } else {
//    var result = Int(arc4random_uniform(max + 1))
//    //  var onlineResult = min + Int(arc4random_uniform(UInt32(max - min + 1)))
//    
//    func getRandom() {
//      let check = arc4random_uniform(max + 1)
//      if check < min {
//        getRandom()
//      } else {
//        result = Int(check)
//      }
//    }
//    
//    if let _ = min {
//      getRandom()
//      return result
//    } else {
//      return result
//      //    return -100 + Int(arc4random_uniform(UInt32(max + 100 + 1)))
//    }
//  }
//}