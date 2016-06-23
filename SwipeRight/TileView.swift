//
//  TileView.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//
import Foundation
import UIKit

class TileView: UIView {
  
  var numberLabel: UILabel?
  var number: Int? {
    didSet {
      numberLabel?.text = String(number!)
      self.userInteractionEnabled = number == -1 ? false : true
      if number == -1 {
        self.numberLabel?.hidden = true
      } else {
        self.numberLabel?.hidden = false
      }
    }
  }
  var partOfSolution = false
  var coordinates: TileCoordinates?
  var subView: UIView?
  var drawnCorrect: Bool = false
  
  func setup(label: UILabel, subview: UIView, overlay: Bool, coordinates: TileCoordinates) {
    self.numberLabel = label
    self.coordinates = coordinates
    self.subView = subview
    self.numberLabel?.backgroundColor = UIColor.clearColor()
//    self.clipsToBounds = true
  }
  
  func showBorder(show: Bool) {
    if show {
      self.layer.borderColor = ThemeHelper.defaultHelper.sw_tile_separator_color.CGColor
      self.layer.borderWidth = 1
    } else {
      self.layer.borderWidth = 0
    }
  }
  
  func drawCorrect(operation: Operation, callback: (Bool) -> ()) {
    drawnCorrect = true
    UIView.animateWithDuration(0.05, animations: {
        self.numberLabel?.transform = CGAffineTransformMakeScale(1.1,1.1)
        self.drawShadow(true, operation: operation)
      }) { (complete) in
        callback(true)
    }
  }
  
  func highlightForTutorial(controller: GameViewController, operation: Operation, callback: (Bool) -> ()) {
    UIView.animateWithDuration(0.3, animations: {
      self.numberLabel?.transform = CGAffineTransformMakeScale(1.25,1.25)
      self.drawShadow(true, operation: operation)
    }) { (complete) in
      UIView.animateWithDuration(0.3, animations: {
        if !controller.pausingForEffect && !self.drawnCorrect {
          self.numberLabel?.transform = CGAffineTransformIdentity
          self.backgroundColor = UIColor.clearColor()
          self.innerView.backgroundColor = UIColor.clearColor()
          self.innerShadow?.shadowOpacity = 0
          self.innerShadow?.shadowRadius = 0
        } else {
          self.drawnCorrect = false
        }
      }) { (complete) in
        callback(true)
      }
    }
  }
  
  func drawShadow(correct: Bool, operation: Operation) {
    let color = correct ? ThemeHelper.defaultHelper.sw_tile_correct_color : ThemeHelper.defaultHelper.sw_tile_incorrect_color
//    guard let subview = subView else { return }
    self.innerView.backgroundColor = operation.color
    innerShadow?.shadowColor = color
    innerShadow?.shadowOpacity = 0.8
    let radius = self.bounds.width / 4
    innerShadow?.shadowRadius = radius
//    subView?.layer.cornerRadius = subview.bounds.height / 2
//    self.backgroundColor = operation.color
//    self.layer.shadowColor = color.CGColor
//    self.layer.shadowOffset = CGSizeZero
//    self.layer.shadowOpacity = 1
//    self.layer.shadowRadius = 25
  }
  
  func drawIncorrect(operation: Operation) {
    drawShadow(false, operation: operation)
  }
  
  func drawNormal(callback: (Bool) -> ()) {
    self.backgroundColor = UIColor.clearColor()
    self.innerView.backgroundColor = UIColor.clearColor()
    self.numberLabel?.transform = CGAffineTransformIdentity
    UIView.animateWithDuration(0.1, animations: {
//      self.innerView.backgroundColor = UIColor.clearColor()
      self.innerShadow?.shadowOpacity = 0
      self.innerShadow?.shadowRadius = 0
      self.numberLabel?.hidden = true
//      self.layer.shadowOpacity = 0
//      self.layer.shadowRadius = 0
//      self.numberLabel?.alpha = 0
      }) { (done) in
        callback(done)
    }
  }
  
  func animateCountdown(callback: (Bool) -> () ) {
    guard let coordinates = coordinates else { callback(false); return }
    if coordinates.x == 1 && coordinates.y == 1 {
      countdownForCenter(callback)
    } else {
      callback(false)
    }
  }
  
  func countdownForCenter(callback: (Bool) -> ()) {
//    self.numberLabel?.font = ThemeHelper.defaultHelper.sw_countdown_font
    var countDown = 3
    func tickTock() {
      self.numberLabel?.alpha = 0
      self.numberLabel?.text = String(countDown)
      UIView.animateWithDuration(1, animations: { () -> Void in
        self.numberLabel?.alpha = 1
        }, completion: { (complete) -> Void in
          if countDown == 1 {
            self.numberLabel?.alpha = 0
//            self.numberLabel?.font = ThemeHelper.defaultHelper.sw_tile_font
            callback(true)
          } else {
            countDown -= 1
            tickTock()
          }
      })
    }
    tickTock()
  }
  
  
  
  
  
  
  
  
  
  // Mark: shadow inset
  
  /*
   CREDITS FOR SHADOW:
   https://github.com/inamiy/YIInnerShadowView
   https://github.com/n8armstrong/fancy-inset-view
   */
  
  
  
  var innerShadow: YIInnerShadowView?
  
  var innerView: UIView!
  
  var cornerRadius: CGFloat = 5.0 {
    didSet {
      layer.cornerRadius = cornerRadius
      innerView.layer.cornerRadius = cornerRadius
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupShadow()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupShadow()
  }
  
  func setupShadow() {
//    clipsToBounds = true
//    layer.masksToBounds = false
    
    innerShadow = YIInnerShadowView(frame: CGRectZero)
    innerShadow!.shadowRadius = 0
    innerShadow!.shadowOffset = CGSizeMake(0.0, 1.0)
    innerShadow!.shadowOpacity = 0.8
    
    // inner shadow
    innerView = UIView()
    innerView.layer.masksToBounds = true
    innerView.addSubview(innerShadow!)
    insertSubview(innerView, atIndex: 0)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    innerView.frame = bounds
    innerShadow!.frame = CGRectInset(bounds, -1.0, -1.0)
  }

}
