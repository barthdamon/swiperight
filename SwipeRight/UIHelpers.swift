//
//  UIHelpers.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/1/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

enum OperationStatus {
  case Current
  case Active
  case Inactive
}

protocol ButtonDelegate {
  func buttonPressed(sender: ButtonView)
}



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

class ButtonView: UIView, UIGestureRecognizerDelegate {
  
  var delegate: ButtonDelegate?
  var label: UILabel?
  
  func becomeButtonForGameView(target: UIViewController, label: UILabel, delegate: ButtonDelegate) {
    self.userInteractionEnabled = true
    self.label = label
    self.delegate = delegate
    
    let firstColor = ThemeHelper.defaultHelper.sw_button_top_color
    let secondColor = ThemeHelper.defaultHelper.sw_button_bottom_color
    let gradientLayer = CAGradientLayer.verticalGradientLayerForBounds(self.bounds, colors: (start: firstColor, end: secondColor), rounded: true)
//    self.layer.hidden = false
    self.layer.insertSublayer(gradientLayer, atIndex: 0)
    
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.shadowColor = ThemeHelper.defaultHelper.sw_shadow_color.CGColor
    self.layer.shadowOpacity = 0.3
    self.layer.shadowOffset = CGSizeZero
    self.layer.shadowRadius = 10
    
//    self.clipsToBounds = true
  }
  
  func togglePressed(down: Bool) {
    if down {
      self.label?.alpha = 0.4
      self.layer.shadowRadius = 0
    } else {
      self.label?.alpha = 1
      self.layer.shadowRadius = 10
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("BUTTON TOUCH START")
    togglePressed(true)
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("BUTTON TOUCH END")
    togglePressed(false)
    delegate?.buttonPressed(self)
  }
  
  
  
  func setAsOperation(operation: Operation, status: OperationStatus) {
    self.userInteractionEnabled = false
  }
}
















