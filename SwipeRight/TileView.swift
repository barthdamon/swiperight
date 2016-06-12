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
  var gradient: CAGradientLayer?
  var innerShadow: CALayer?
  var borderViews: Array<UIView> = []
  let borderWidth: CGFloat = 2.0
  
  func setup(label: UILabel, overlay: Bool, coordinates: TileCoordinates) {
//    self.frame = CGRectMake(xCoord, yCoord, tileWidth, tileWidth)
//    numberLabel = UILabel(frame: CGRectMake(tileWidth / 2.1, tileWidth / 5.2, tileWidth / 1.5, tileWidth / 1.5))
    self.numberLabel = label
    self.coordinates = coordinates
//    self.addSubview(numberLabel!)
    if overlay {
      self.backgroundColor = UIColor.clearColor()
      gradient?.removeFromSuperlayer()
      self.numberLabel?.font = ThemeHelper.defaultHelper.sw_game_overlay_font
    } else {
      self.backgroundColor = UIColor.clearColor()
      gradient?.removeFromSuperlayer()
      self.numberLabel?.font = ThemeHelper.defaultHelper.sw_game_font
    }
    setBorder()
    //todo: setup border depending on placement
//    self.layer.borderColor = ThemeHelper.defaultHelper.sw_tile_separator_color.CGColor
//    self.layer.borderWidth = 0
    
//    gradient = CAGradientLayer.verticalGradientLayerForBounds(self.frame, colors: (start: ThemeHelper.defaultHelper.sw_button_top_color, end: ThemeHelper.defaultHelper.sw_button_bottom_color), rounded: false)
//    self.layer.insertSublayer(gradient!, atIndex: 0)
  }

  func drawShadowLayer(correct: Bool) {
    innerShadow = CALayer()
    // Shadow path (1pt ring around bounds)
    let path = UIBezierPath(rect: innerShadow!.bounds.insetBy(dx: -5, dy: -5))
    let cutout = UIBezierPath(rect: innerShadow!.bounds).bezierPathByReversingPath()
    path.appendPath(cutout)
    innerShadow!.shadowPath = path.CGPath
    innerShadow!.masksToBounds = true
    // Shadow properties
    let color = correct ? ThemeHelper.defaultHelper.sw_tile_correct_shadow_color.CGColor : ThemeHelper.defaultHelper.sw_tile_incorrect_shadow_color.CGColor
    innerShadow!.shadowColor = color
    innerShadow!.shadowOffset = CGSizeZero
    innerShadow!.shadowOpacity = 1
    innerShadow!.shadowRadius = 3
    // Add
    layer.insertSublayer(innerShadow!, atIndex:0)
  }
  
  
  func drawCorrect() {
//    self.backgroundColor = UIColor.whiteColor()
    drawShadowLayer(true)
    UIView.animateWithDuration(0.1) {
//      self.transform = CGAffineTransformMakeScale(1.2, 1.2)
 //     self.layer.shadowRadius = 5
//      self.layer.shadowOpacity = 0.3
//      self.layer.shadowOffset = CGSizeZero
 //     self.layer.shadowColor = ThemeHelper.defaultHelper.sw_shadow_color.CGColor
    }
  }
  
  func drawIncorrect() {
//    self.backgroundColor = UIColor.whiteColor()
    drawShadowLayer(false)
    UIView.animateWithDuration(0.3) {
//      self.layer.shadowRadius = 5
//      self.layer.shadowOpacity = 0.3
//      self.layer.shadowOffset = CGSizeZero
//      self.layer.shadowColor = ThemeHelper.defaultHelper.sw_shadow_color.CGColor
    }
  }
  
  func drawNormal() {
    innerShadow?.shadowRadius = 0
    self.backgroundColor = UIColor.clearColor()
    UIView.animateWithDuration(0.3) {
      self.transform = CGAffineTransformIdentity
      self.layer.shadowRadius = 0
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
  
  func pickRandomNumber(sender: AnyObject) {
    if let label = numberLabel {
      let newLabel = UILabel(frame: CGRectMake(0,0,label.frame.width, label.frame.height))
      newLabel.backgroundColor = UIColor.clearColor()
      newLabel.font = ThemeHelper.defaultHelper.sw_game_font
      let random = Int.random(0...99)
      newLabel.text = "\(random)"
      newLabel.alpha = 0
      self.addSubview(newLabel)
      UIView.animateWithDuration(0.15, animations: { 
        newLabel.alpha = 1
        UIView.animateWithDuration(0.15, animations: { 
          newLabel.alpha = 0
        })
      })
    }
  }
  
  func countdownForCenter(callback: (Bool) -> ()) {
    var countDown = 3
    func tickTock() {
      self.numberLabel?.alpha = 0
      self.numberLabel?.text = String(countDown)
      UIView.animateWithDuration(1, animations: { () -> Void in
        self.numberLabel?.alpha = 1
        }, completion: { (complete) -> Void in
          if countDown == 1 {
            callback(true)
          } else {
            countDown -= 1
            tickTock()
          }
      })
    }
    tickTock()
  }
  
  func setBorder() {
    guard let coordinates = coordinates else { return }
    if coordinates.x != 0 {
      let lineView = UIView(frame: CGRectMake(0, 0, borderWidth, self.bounds.size.height))
      lineView.backgroundColor = ThemeHelper.defaultHelper.sw_tile_separator_color
      lineView.hidden = true
      self.addSubview(lineView)
      borderViews.append(lineView)
    }
    if coordinates.y != 0 {
      let lineView = UIView(frame: CGRectMake(0, 0, self.bounds.size.width, borderWidth))
      lineView.backgroundColor = ThemeHelper.defaultHelper.sw_tile_separator_color
      lineView.hidden = true
      self.addSubview(lineView)
      borderViews.append(lineView)
    }
    if coordinates.y != 2 {
      let lineView = UIView(frame: CGRectMake(0, self.bounds.size.height, self.bounds.size.width, borderWidth))
      lineView.backgroundColor = ThemeHelper.defaultHelper.sw_tile_separator_color
      lineView.hidden = true
      self.addSubview(lineView)
      borderViews.append(lineView)
    }
  }
  
  func hideBorders(hidden: Bool) {
    borderViews.forEach({$0.hidden = hidden})
  }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
