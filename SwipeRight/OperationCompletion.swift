//
//  OperationCompletion.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/19/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation


func completeOperation(sum: Int?, first: Int?, second: Int?, operation: Operation) -> Int {
  var int = 0
  if let first = first, sum = sum {
    //solve for second number
    switch operation {
    case .Add:
      int = sum - first
    case .Subtract:
      int = first - sum
    case .Divide:
      int = first / sum
    case .Multiply:
      int = sum / first
    }
  } else if let second = second, sum = sum {
    //solve for first number
    switch operation {
    case .Add:
      int = sum - second
    case .Subtract:
      int = sum + second
    case .Divide:
      int = sum * second
    case .Multiply:
      int = sum / second
    }
  } else if let first = first, second = second {
    switch operation {
    case .Add:
      int = first + second
    case .Subtract:
      int = first - second
    case .Divide:
      int = first / second
    case .Multiply:
      int = first * second
    }
  }
  
  return int
}