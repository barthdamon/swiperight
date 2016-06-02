//
//  UIHelpers.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/1/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

func alertShow(vc: UIViewController, alertText :String, alertMessage :String) {
  let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
  
  alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
    alert.dismissViewControllerAnimated(true, completion: nil)
  }))
  //can add another action (maybe cancel, here)
  dispatch_async(dispatch_get_main_queue(), { () -> Void in
    vc.presentViewController(alert, animated: true, completion: nil)
  })
}
