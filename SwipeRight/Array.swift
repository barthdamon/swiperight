//
//  Array.swift
//  SwipeRight!
//
//  Created by Matthew Barth on 7/6/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

extension Array {
  func lookup(index : UInt) throws -> Element {
    if Int(index) >= count {throw
      NSError(domain: "com.sadun", code: 0,
              userInfo: [NSLocalizedFailureReasonErrorKey:
                "Array index out of bounds"])}
    return self[Int(index)]
  }
}