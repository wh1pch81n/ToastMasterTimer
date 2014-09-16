//
//  TMTimerStyleKitWithColorExtensions.h
//  TMTimer
//
//  Created by Derrick Ho on 8/25/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMTimerStyleKit.h"

@interface TMTimerStyleKitWithColorExtensions : TMTimerStyleKit

@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* tmColorThemeBlueTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* tmColorThemeAquaTargets;
@property(strong, nonatomic) IBOutletCollection(NSObject) NSArray* tmColorThemeAquaBGTargets;

/**
 Serves a timer flag based on the currently selected flag.
 i.e. if plain is selected you get squares.
 i.e. if you get the gauge then you get the gauges
 i.e. if you get the wine then you get the wine
*/
+ (UIImage *)timerFlagWithMinTime:(float)minTime maxTime:(float)maxTime elapsedTime:(float)elapsedTime;

@end
