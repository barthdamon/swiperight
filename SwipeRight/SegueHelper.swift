//
//  SegueHelper.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/5/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

/// Move to the next screen without an animation.
class PushNoAnimationSegue: UIStoryboardSegue {
  
  override func perform() {
    let source = sourceViewController as UIViewController
    if let navigation = source.navigationController {
      navigation.pushViewController(destinationViewController as UIViewController, animated: false)
    }
  }
  
}


func waitASec(sec: Double, callback: (Bool) ->()) {
  let delay = sec * Double(NSEC_PER_SEC)
  let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
  dispatch_after(time, dispatch_get_main_queue()) {
    callback(true)
  }
}