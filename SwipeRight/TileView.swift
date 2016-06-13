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
  
  func setup(label: UILabel, subview: UIView, overlay: Bool, coordinates: TileCoordinates) {
    self.numberLabel = label
    self.coordinates = coordinates
    self.subView = subview
    if overlay {
      self.backgroundColor = UIColor.clearColor()
      self.numberLabel?.font = ThemeHelper.defaultHelper.sw_game_overlay_font
    } else {
      self.backgroundColor = UIColor.clearColor()
      self.numberLabel?.font = ThemeHelper.defaultHelper.sw_game_font
    }
    self.numberLabel?.backgroundColor = UIColor.clearColor()
  }
  
  func drawCorrect(callback: (Bool) -> ()) {
    self.backgroundColor = ThemeHelper.defaultHelper.sw_tile_correct_color
    UIView.animateWithDuration(0.05, animations: {
      self.transform = CGAffineTransformMakeScale(1.2,1.2)
      }) { (complete) in
      callback(true)
    }
  }
  
  func drawIncorrect() {
    self.backgroundColor = ThemeHelper.defaultHelper.sw_tile_incorrect_color
  }
  
  func drawNormal() {
    if self.number != -1 {
      self.transform = CGAffineTransformIdentity
      self.backgroundColor = UIColor.clearColor()
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

}
