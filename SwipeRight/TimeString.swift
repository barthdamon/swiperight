//
//  TimeString.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/15/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation


func stringToGameTime(time: Int) -> String {
  let minutes = time / 60
  var tenMinutes = ""
  var tenSeconds = ""
  var seconds = 0
  if minutes > 0 {
    seconds = time % 60
  } else {
    seconds = time
  }
  
  if seconds < 10 {
    tenSeconds = "0"
  }
  
  if minutes < 10 {
    tenMinutes = ""
  }

  return "\(tenMinutes)\(String(minutes)):\(tenSeconds)\(String(seconds))"
}
