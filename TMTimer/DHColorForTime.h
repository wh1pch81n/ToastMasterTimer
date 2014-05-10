//
//  DHColorForTime.h
//  TMTimer
//
//  Created by Derrick Ho on 4/13/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHColorForTime : NSObject

+ (id)shared;
- (UIColor *)colorForSeconds:(NSTimeInterval)seconds min:(NSTimeInterval)min max:(NSTimeInterval)max;

@end
