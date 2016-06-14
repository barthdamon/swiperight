//
//  ThemeHelper.swift
//  SwipedRight
//
//  Created by Matthew Barth on 6/4/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

class ThemeHelper: NSObject {
  
  static var defaultHelper = ThemeHelper()
  
  let addImage = UIImage(named: "addition")
  let subtractImage = UIImage(named: "subtraction")
  let multiplyImage = UIImage(named: "multiplication")
  let divideImage = UIImage(named: "division")
  
  let addImageGray = UIImage(named: "additionGray")
  let subtractImageGray = UIImage(named: "subtractionGray")
  let multiplyImageGray = UIImage(named: "multiplicationGray")
  let divideImageGray = UIImage(named: "divisionGray")
  
  // Colors
  let sw_tile_separator_color: UIColor = UIColor.darkGrayColor()
  let sw_shadow_color: UIColor = UIColor.darkGrayColor()
  let sw_gameview_background_color: UIColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
  let sw_background_color: UIColor = UIColor(red:0.71, green:0.74, blue:0.74, alpha:1.00)
  let sw_background_glow_color: UIColor = UIColor(red:0.82, green:0.84, blue:0.84, alpha:1.00)
  
  let sw_button_top_color: UIColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
  let sw_button_bottom_color: UIColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.00)
  
  
  let sw_tile_top_color: UIColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
  let sw_tile_bottom_color: UIColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.00)
  let sw_tile_correct_color = UIColor.whiteColor()
  //UIColor(red:0.28, green:0.75, blue:0.20, alpha:1.00)
  let sw_tile_incorrect_color = UIColor(red:0.90, green:0.00, blue:0.00, alpha:1.00)
  

  // Fonts
  let sw_font = UIFont(name: "DIN-Medium", size: 16)
  let sw_font_large = UIFont(name: "DIN-Medium", size: 32)
  let sw_bold_font = UIFont(name: "DIN-Bold", size: 13)
  
  let sw_game_font = UIFont(name: "DIN-Medium", size: 25)
  let sw_game_overlay_font = UIFont(name: "DIN-Medium", size: 40)
}

@IBDesignable class TIFAttributedLabel: UILabel {
  
  @IBInspectable var fontSize: CGFloat = 17.0
  @IBInspectable var fontFamily: String = "DIN Medium"
  
  override func awakeFromNib() {
    let attrString = NSMutableAttributedString(attributedString: self.attributedText!)
    attrString.addAttribute(NSFontAttributeName, value: UIFont(name: self.fontFamily, size: self.fontSize)!, range: NSMakeRange(0, attrString.length))
    self.attributedText = attrString
  }
}