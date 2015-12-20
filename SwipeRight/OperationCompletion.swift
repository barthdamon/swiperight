//
//  OperationCompletion.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/19/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation


func completeOperation(sum: Int, first: Int?, second: Int?, operation: Operation) -> Int {
  var int = 0
  if let first = first {
    //solve for second number
    switch operation {
    case .Add:
      int = sum - first
    case .Subtract:
      int = first - sum
    default:
      break
    }
  } else if let second = second {
    //solve for first number
    switch operation {
    case .Add:
      int = sum - second
    case .Subtract:
      int = sum + second
    default:
      break
    }
  }
  
  return int
}