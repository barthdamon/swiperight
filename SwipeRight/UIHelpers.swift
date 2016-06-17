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
  var offsetX: Double?
  var offsetY: Double?
  var negOffsetX: Double?
  var negOffsetY: Double?
  var active: Bool = true
  
  func becomeButtonForGameView(target: UIViewController, label: UILabel, delegate: ButtonDelegate) {
    self.userInteractionEnabled = true
    self.label = label
    self.delegate = delegate
    
    let firstColor = ThemeHelper.defaultHelper.sw_button_top_color
    let secondColor = ThemeHelper.defaultHelper.sw_button_bottom_color
    let gradientLayer = CAGradientLayer.verticalGradientLayerForBounds(self.bounds, colors: (start: firstColor, end: secondColor), rounded: self.bounds.height / 2)
//    self.layer.hidden = false
    self.layer.insertSublayer(gradientLayer, atIndex: 0)
    
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.shadowColor = ThemeHelper.defaultHelper.sw_shadow_color.CGColor
    self.layer.shadowOpacity = 0.3
    self.layer.shadowOffset = CGSizeZero
    self.layer.shadowRadius = 10
    offsetX = Double(self.frame.width * 1.2)
    offsetY = Double(self.frame.height * 1.8)
    negOffsetX = Double(self.frame.width * -0.2)
    negOffsetY = Double(self.frame.height * -0.8)
  }
  
  func togglePressed(down: Bool) {
    if active {
      if down {
        self.label?.alpha = 0.4
        self.layer.shadowRadius = 0
      } else {
        self.label?.alpha = 1
        self.layer.shadowRadius = 10
      }
    }
  }
  
  func toggleActive(active: Bool) {
    self.active = active
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("Button touch start")
    togglePressed(true)
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    let loc = touch.locationInView(self)
    if let offsetX = offsetX, offsetY = offsetY, negOffsetX = negOffsetX, negOffsetY = negOffsetY {
      let locX = Double(loc.x)
      let locY = Double(loc.y)
      if (locX > offsetX || locX < negOffsetX) || (locY > offsetY || locY < negOffsetY) {
        togglePressed(false)
      }
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print("Button touch end")
    guard let touch = touches.first else { return }
    let loc = touch.locationInView(self)
    if (loc.x < self.frame.width && loc.x > 0) && (loc.y < self.frame.height && loc.y > 0) {
      delegate?.buttonPressed(self)
    }
    togglePressed(false)
  }
  
  
  
  func setAsOperation(operation: Operation, status: OperationStatus) {
    self.userInteractionEnabled = false
  }
}

class OperationImageView: UIImageView {
  
  var operation: Operation?
  
  func displayOperationStatus(activeOperations: Array<Operation>) {
    if let operation = operation {
      if activeOperations.contains(operation) {
        UIView.animateWithDuration(0.3, animations: { 
          self.transform = CGAffineTransformMakeScale(1.5, 1.5)
          self.layer.shadowColor = operation.color.CGColor
          self.layer.shadowOpacity = 1
          self.layer.shadowOffset = CGSizeZero
          self.layer.shadowRadius = 10
        })
      } else {
        UIView.animateWithDuration(0.3, animations: {
          self.transform = CGAffineTransformIdentity
          self.layer.shadowRadius = 0
        })
      }
    }
  }
}
















