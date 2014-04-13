//
//  Event+helperMethods.h
//  TMTimer
//
//  Created by ryukkusakku on 2/16/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "Event.h"

@interface Event (helperMethods)

- (void)setBgColorDataWithColor:(UIColor *)color __attribute__((deprecated));
- (UIColor *)bgColorFromData __attribute__((deprecated));

@end
