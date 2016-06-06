//
//  TileView.swift
//  SwipeRight
//
//  Created by Matthew Barth on 12/13/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

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
  
  convenience init(xCoord: CGFloat, yCoord: CGFloat, tileWidth: CGFloat, overlay: Bool) {
    self.init()
    self.frame = CGRectMake(xCoord, yCoord, tileWidth, tileWidth)
    numberLabel = UILabel(frame: CGRectMake(tileWidth / 2.1, tileWidth / 5.2, tileWidth / 1.5, tileWidth / 1.5))
    self.addSubview(numberLabel!)
    if overlay {
      self.backgroundColor = UIColor.clearColor()
      self.numberLabel?.font = ThemeHelper.defaultHelper.sw_game_overlay_font
    } else {
      self.backgroundColor = UIColor.clearColor()
      self.numberLabel?.font = ThemeHelper.defaultHelper.sw_game_font
    }
    self.layer.borderColor = ThemeHelper.defaultHelper.sw_tile_separator_color.CGColor
    self.layer.borderWidth = 0
  }
  
  func animateCountdown(callback: (Bool) -> () ) {
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

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
