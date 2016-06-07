//
//  GradientLayer.swift
//  SwipedRight
//
//  Created by Matthew Barth on 5/30/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit



extension CAGradientLayer {
  static func gradientLayerForBounds(bounds: CGRect, colors: (start: UIColor, end: UIColor)) -> CAGradientLayer {
    
    let layer = CAGradientLayer()
    layer.frame = bounds
    
    layer.startPoint = CGPoint(x: 0, y: 0.5)
    layer.endPoint = CGPoint(x: 1, y: 0.5)
    let colors: [CGColorRef] = [
      colors.start.CGColor,
      colors.end.CGColor,
    ]
    layer.colors = colors
    layer.opaque = false
    layer.locations = [0.0, 1.0]
    
    return layer
  }
  
  static func verticalGradientLayerForBounds(bounds: CGRect, colors: (start: UIColor, end: UIColor), rounded: Bool) -> CAGradientLayer {
    
    let layer = CAGradientLayer()
    layer.frame = bounds
    if rounded {
      layer.cornerRadius = bounds.height / 2
    }
    
    layer.startPoint = CGPoint(x: 0, y: 0)
    layer.endPoint = CGPoint(x: 0, y: 1)
    let colors: [CGColorRef] = [
      colors.start.CGColor,
      colors.end.CGColor,
      ]
    layer.colors = colors
    layer.opaque = false
    layer.locations = [0.0, 1.0]
    
    return layer
  }
}

  