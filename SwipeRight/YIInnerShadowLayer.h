//
//  YIInnerShadowLayer.h
//  SwipeRight!
//
//  Created by Matthew Barth on 6/13/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
  YIInnerShadowMaskNone       = 0,
  YIInnerShadowMaskTop        = 1 << 1,
  YIInnerShadowMaskBottom     = 1 << 2,
  YIInnerShadowMaskLeft       = 1 << 3,
  YIInnerShadowMaskRight      = 1 << 4,
  YIInnerShadowMaskVertical   = YIInnerShadowMaskTop | YIInnerShadowMaskBottom,
  YIInnerShadowMaskHorizontal = YIInnerShadowMaskLeft | YIInnerShadowMaskRight,
  YIInnerShadowMaskAll        = YIInnerShadowMaskVertical | YIInnerShadowMaskHorizontal
} YIInnerShadowMask;

//
// Ideas from Matt Wilding:
// http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer
//
@interface YIInnerShadowLayer : CAShapeLayer

@property (nonatomic) YIInnerShadowMask shadowMask;

@end