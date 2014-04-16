//
//  UISegmentedControl+extractMinMaxData.m
//  TMTimer
//
//  Created by Derrick Ho on 4/15/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "UISegmentedControl+extractMinMaxData.h"

@implementation UISegmentedControl (extractMinMaxData)

- (void)valuesOfTappedSegmentedControlMinValue:(NSNumber *__autoreleasing *)min maxValue:(NSNumber *__autoreleasing *)max
{
    NSString *str = [self titleForSegmentAtIndex:self.selectedSegmentIndex];
    NSArray *arr = [str componentsSeparatedByString:@"~"];
    
    *min = @([[arr firstObject] intValue]);
    *max = @([[arr lastObject] intValue]);
}

@end
