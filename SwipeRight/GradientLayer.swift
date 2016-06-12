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
  
  static func verticalGradientLayerForBounds(bounds: CGRect, colors: (start: UIColor, end: UIColor), rounded: CGFloat) -> CAGradientLayer {
    
    let layer = CAGradientLayer()
    layer.frame = bounds
    layer.cornerRadius = rounded
    
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

class RadialGradientLayer: CALayer {
  
  override init(){
    
    super.init()
    
    needsDisplayOnBoundsChange = true
  }
  
  init(center:CGPoint,radius:CGFloat,colors:[CGColor]){
    
    self.center = center
    self.radius = radius
    self.colors = colors
    
    super.init()
    
  }
  
  required init(coder aDecoder: NSCoder) {
    
    super.init()
    
  }
  
  var center:CGPoint = CGPointMake(50,50)
  var radius:CGFloat = 20
  var colors:[CGColor] = [UIColor(red: 251/255, green: 237/255, blue: 33/255, alpha: 1.0).CGColor , UIColor(red: 251/255, green: 179/255, blue: 108/255, alpha: 1.0).CGColor]
  
  override func drawInContext(ctx: CGContext) {
    
    CGContextSaveGState(ctx)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradientCreateWithColors(colorSpace, colors, [0.0,1.0])
    
    CGContextDrawRadialGradient(ctx, gradient, center, 0.0, center, radius, CGGradientDrawingOptions.DrawsAfterEndLocation)
    
  }
  
}

  