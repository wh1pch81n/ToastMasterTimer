//
//  SKTimerGaugeView.h
//  TMTimer
//
//  Created by Derrick Ho on 8/24/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKTimerGaugeView : UIView

@property NSTimeInterval minSeconds;
@property NSTimeInterval maxSeconds;
@property NSTimeInterval elapsedSeconds;

@end
