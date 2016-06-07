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
  func becomeButtonForGameView(target: UIViewController, selector: Selector) {
    let tapRecognizer = UITapGestureRecognizer(target: target, action: selector)
    tapRecognizer.numberOfTapsRequired = 1
    tapRecognizer.numberOfTouchesRequired = 1
    self.addGestureRecognizer(tapRecognizer)
    
    let firstColor = ThemeHelper.defaultHelper.sw_button_top_color
    let secondColor = ThemeHelper.defaultHelper.sw_button_bottom_color
    let gradientLayer = CAGradientLayer.verticalGradientLayerForBounds(self.bounds, colors: (start: firstColor, end: secondColor), rounded: true)
//    self.layer.hidden = false
    self.layer.insertSublayer(gradientLayer, atIndex: 0)
    
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.shadowColor = UIColor.darkGrayColor().CGColor
    self.layer.shadowOpacity = 0.3
    self.layer.shadowOffset = CGSizeZero
    self.layer.shadowRadius = 10
    
//    self.clipsToBounds = true
  }
}
















