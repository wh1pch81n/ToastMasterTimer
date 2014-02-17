//
//  Event+helperMethods.m
//  TMTimer
//
//  Created by ryukkusakku on 2/16/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "Event+helperMethods.h"

@implementation Event (helperMethods)

- (void)setBgColorDataWithColor:(UIColor *)color {
    [self setBgColor:[NSKeyedArchiver archivedDataWithRootObject:color]];
}

- (UIColor *)bgColorFromData {
    return (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:self.bgColor];
}

@end
