//
//  UISegmentedControl+extractMinMaxData.h
//  TMTimer
//
//  Created by Derrick Ho on 4/15/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

@import UIKit;

@interface UISegmentedControl (extractMinMaxData)

- (void)valuesOfTappedSegmentedControlMinValue:(NSNumber **)min maxValue:(NSNumber **)max;

@end
