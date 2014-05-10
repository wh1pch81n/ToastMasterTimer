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
- (UIColor *)colorForSeconds:(NSTimeInterval)seconds min:(NSTimeInterval)min max:(NSTimeInterval)max
{
    if (seconds <= 0) {
        return [UIColor whiteColor];
    }
    const int k60Seconds = 60;
#if DEBUG
#else
    min *= k60Seconds;
    max *= k60Seconds;
#endif
    UIColor *color;
    if (seconds >= max) {
        color = [UIColor redColor];
    }
    else if(seconds >= ((max+min)/2)) {
        color = [UIColor yellowColor];
    }
    else if(seconds >= min) {
        color = [UIColor greenColor];
    }
    else {
        color = [UIColor blackColor];
    }
    return  color;
}
@end
