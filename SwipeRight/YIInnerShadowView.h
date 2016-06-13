//
//  YIInnerShadowView.h
//  SwipeRight!
//
//  Created by Matthew Barth on 6/13/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for YIInnerShadowView.
FOUNDATION_EXPORT double YIInnerShadowViewVersionNumber;

//! Project version string for YIInnerShadowView.
FOUNDATION_EXPORT const unsigned char YIInnerShadowViewVersionString[];

#import <QuartzCore/QuartzCore.h>
#import "YIInnerShadowLayer.h"

@interface YIInnerShadowView : UIView

@property (nonatomic, strong, readonly) YIInnerShadowLayer* innerShadowLayer;

@property (nonatomic) YIInnerShadowMask shadowMask;

@property (nonatomic, strong) UIColor* shadowColor;
@property (nonatomic)         CGFloat  shadowOpacity;
@property (nonatomic)         CGSize   shadowOffset;
@property (nonatomic)         CGFloat  shadowRadius;

@property (nonatomic)         CGFloat  cornerRadius;

@end