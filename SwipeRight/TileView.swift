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
  var borderViews: Array<UIView> = []
  let borderWidth: CGFloat = 2.0
  
  func setup(label: UILabel, overlay: Bool, coordinates: TileCoordinates) {
    self.numberLabel = label
    self.coordinates = coordinates
    if overlay {
      self.backgroundColor = UIColor.clearColor()
      gradient?.removeFromSuperlayer()
      self.numberLabel?.font = ThemeHelper.defaultHelper.sw_game_overlay_font
    } else {
      self.backgroundColor = UIColor.clearColor()
      gradient?.removeFromSuperlayer()
      self.numberLabel?.font = ThemeHelper.defaultHelper.sw_game_font
    }

  }
  
  func setTileForOperation(operation: Operation) {
    let cornerRadius = bounds.height / 1.5
    self.layer.cornerRadius = cornerRadius
    gradient = CAGradientLayer.verticalGradientLayerForBounds(self.frame, colors: (start: ThemeHelper.defaultHelper.sw_button_top_color, end: operation.color), rounded: cornerRadius)
    
//    self.numberLabel.backgroundColor =
  }

  func drawShadowLayer(correct: Bool) {

//    let color = correct ? ThemeHelper.defaultHelper.sw_tile_correct_shadow_color.CGColor : ThemeHelper.defaultHelper.sw_tile_incorrect_shadow_color.CGColor
//    let colors = [color, UIColor.clearColor().CGColor]
//    self.layer.insertSublayer(gradient!, atIndex: 0)
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
    gradient?.removeFromSuperlayer()
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
  
//  func setBorder() {
//    guard let coordinates = coordinates else { return }
//    if coordinates.x != 0 {
//      let lineView = UIView(frame: CGRectMake(0, 0, borderWidth, self.frame.size.height))
//      lineView.backgroundColor = ThemeHelper.defaultHelper.sw_tile_separator_color
//      lineView.hidden = true
//      self.addSubview(lineView)
//      borderViews.append(lineView)
//    }
//    if coordinates.y != 0 {
//      let lineView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, borderWidth))
//      lineView.backgroundColor = ThemeHelper.defaultHelper.sw_tile_separator_color
//      lineView.hidden = true
//      self.addSubview(lineView)
//      borderViews.append(lineView)
//    }
//    if coordinates.y != 2 {
//      let lineView = UIView(frame: CGRectMake(0, self.frame.size.height, self.frame.size.width, borderWidth))
//      lineView.backgroundColor = ThemeHelper.defaultHelper.sw_tile_separator_color
//      lineView.hidden = true
//      self.addSubview(lineView)
//      borderViews.append(lineView)
//    }
//  }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
