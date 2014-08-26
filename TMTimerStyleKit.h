//
//  TMTimerStyleKit.h
//  Toastmaster Timer
//
//  Created by Derrick Ho on 8/24/14.
//  Copyright (c) 2014 dnthome. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TMTimerStyleKit : NSObject

// Drawing Methods
+ (void)drawTimerGaugeMediumWithFrame: (CGRect)frame minSeconds: (CGFloat)minSeconds maxSeconds: (CGFloat)maxSeconds elapsedSeconds: (CGFloat)elapsedSeconds;
+ (void)drawTimerGaugeSmallWithMinSeconds: (CGFloat)minSeconds maxSeconds: (CGFloat)maxSeconds elapsedSeconds: (CGFloat)elapsedSeconds;
+ (void)drawGauge50WithMinSeconds: (CGFloat)minSeconds maxSeconds: (CGFloat)maxSeconds elapsedSeconds: (CGFloat)elapsedSeconds;

@end
