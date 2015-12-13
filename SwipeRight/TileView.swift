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
    }
  }
  
  convenience init(xCoord: CGFloat, yCoord: CGFloat, tileWidth: CGFloat) {
    self.init()
    self.frame = CGRectMake(xCoord, yCoord, tileWidth, tileWidth)
    self.backgroundColor = UIColor.cyanColor()
    numberLabel = UILabel(frame: CGRectMake(tileWidth / 2.1, tileWidth / 5.2, tileWidth / 2, tileWidth / 2))
    self.addSubview(numberLabel!)
  }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
