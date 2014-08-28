//
//  DHColorForTime.m
//  TMTimer
//
//  Created by Derrick Ho on 4/13/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHColorForTime.h"

@implementation DHColorForTime

+ (id)shared
{
    static DHColorForTime *colorForTime = nil;
    @synchronized(self) {
        if(colorForTime == nil) {
            colorForTime = [[self alloc] init];
        }
    }
    return colorForTime;
}

- (id)init
{
    if ((self = [super init])) {
        
    }
    return self;
}

/**
 Offers a color value based on the how the min and max values in relations to the given seconds
 @param seconds number of seconds
 @param min number of minutes before the green flag shows up
 @param max number of minutes before the red flag shows up
 @return the color.
 */
- (UIColor *)colorForSeconds:(NSTimeInterval)seconds min:(NSTimeInterval)min_ max:(NSTimeInterval)max_
{
    __block NSTimeInterval min = min_, max = max_;
    if (seconds <= 0) {
        return [UIColor clearColor];
    }
    const int k60Seconds = 60;
    DHRLog(^{
        min *= k60Seconds;
        max *= k60Seconds;
    }, nil);
    UIColor *color;
    if (seconds >= max) {
        color = [TMTimerStyleKit g_HighPressureColor];
    }
    else if(seconds >= ((max+min)/2)) {
        color = [TMTimerStyleKit g_MediumPressureColor];
    }
    else if(seconds >= min) {
        color = [TMTimerStyleKit g_LowPressureColor];
    }
    else {
        color = [UIColor blackColor];
    }
    return  color;
}
@end
