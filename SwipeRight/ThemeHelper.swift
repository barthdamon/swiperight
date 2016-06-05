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
  
  let sw_tile_separator_color: UIColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
  let sw_gameview_shadow_color: UIColor = UIColor(red:0.33, green:0.69, blue:0.78, alpha:1.00)
  let sw_gameview_background_color: UIColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
  let sw_blue_color: UIColor = UIColor(red: 0.35, green: 0.71, blue: 0.85, alpha: 1)
  let sw_green_color: UIColor = UIColor(red: 0.42, green: 0.84, blue: 0.73, alpha: 1)

}