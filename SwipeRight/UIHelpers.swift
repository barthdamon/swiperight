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

extension UILabel {
  
  func boldRange(range: Range<String.Index>) {
    if let text = self.attributedText, boldFont = ThemeHelper.defaultHelper.sw_bold_font {
      let attr = NSMutableAttributedString(attributedString: text)
      let start = text.string.startIndex.distanceTo(range.startIndex)
      let length = range.startIndex.distanceTo(range.endIndex)
      attr.addAttributes([NSFontAttributeName: boldFont], range: NSMakeRange(start, length))
      self.attributedText = attr
    }
  }
  
  func boldSubstring(substr: String) {
    let range = self.text?.rangeOfString(substr)
    if let r = range {
      boldRange(r)
    }
  }
}

extension UIView {
  static func becomeButtonForGameView(selector: Selector) {
    
  }
}
















