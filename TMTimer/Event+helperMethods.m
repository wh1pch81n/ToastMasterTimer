//
//  Event+helperMethods.m
//  TMTimer
//
//  Created by ryukkusakku on 2/16/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "Event+helperMethods.h"

static const NSInteger kColorBlack = 1;
static const NSInteger kColorClear = 2;
static const NSInteger kColorRed = 3;
static const NSInteger kColorYellow = 4;
static const NSInteger kColorGreen = 5;
static const NSInteger kColorUnknown = -1;

@implementation Event (helperMethods)

- (void)setBgColorDataWithColor:(UIColor *)color {
    if ([color isEqual:[UIColor blackColor]]) {
        self.bgColor = @(kColorBlack);
    } else if ([color isEqual:[UIColor clearColor]]) {
        self.bgColor = @(kColorClear);
    } else if ([color isEqual:[UIColor redColor]]) {
        self.bgColor = @(kColorRed);
    } else if ([color isEqual:[UIColor yellowColor]]) {
        self.bgColor = @(kColorYellow);
    } else if ([color isEqual:[UIColor greenColor]]) {
        self.bgColor = @(kColorGreen);
    } else  {
        self.bgColor = @(kColorUnknown);
    }
}
- (UIColor *)bgColorFromData {
    switch (self.bgColor.integerValue) {
        case kColorBlack:return [UIColor blackColor];
        case kColorClear:return [UIColor clearColor];
        case kColorGreen:return [UIColor greenColor];
        case kColorRed:return [UIColor redColor];
        case kColorYellow:return [UIColor yellowColor];
        default:
            return [UIColor magentaColor];
    }
}

@end
