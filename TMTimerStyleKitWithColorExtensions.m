//
//  TMTimerStyleKitWithColorExtensions.m
//  TMTimer
//
//  Created by Derrick Ho on 8/25/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMTimerStyleKitWithColorExtensions.h"

@implementation TMTimerStyleKitWithColorExtensions

- (void)setColorTargets:(NSArray*)themeTarget color:(UIColor *)themeColor
{
    for (id target in themeTarget) {
        SEL sel = NULL;
        if ([target isKindOfClass:[UILabel class]]) {
            sel = @selector(setTextColor:);
        } else if ([target isKindOfClass:[UIView class]]) {
            sel = @selector(setBackgroundColor:);
        } else if ([target isKindOfClass:[UISegmentedControl class]]) {
            sel = @selector(setTintColor:);
        } else {
            continue;
        }
        [target performSelector:sel withObject:themeColor];
    }
}

- (void)setTmColorThemeBlueTargets: (NSArray*)tmColorThemeBlueTargets
{
    _tmColorThemeBlueTargets = tmColorThemeBlueTargets;
    
    [self setColorTargets:self.tmColorThemeBlueTargets color:[TMTimerStyleKit tM_ThemeBlue]];
}

- (void)setTmColorThemeAquaTargets: (NSArray*)tmColorThemeAquaTargets
{
    _tmColorThemeAquaTargets = tmColorThemeAquaTargets;
    
    [self setColorTargets:self.tmColorThemeAquaTargets color:[TMTimerStyleKit tM_ThemeAqua]];
}

- (void)setTmColorThemeAquaBGTargets: (NSArray*)tmColorThemeAquaBGTargets
{
    _tmColorThemeAquaBGTargets = tmColorThemeAquaBGTargets;
    
    [self setColorTargets:self.tmColorThemeAquaBGTargets color:[TMTimerStyleKit tM_ThemeAqua_bg]];
}
@end