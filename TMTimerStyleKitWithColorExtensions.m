//
//  TMTimerStyleKitWithColorExtensions.m
//  TMTimer
//
//  Created by Derrick Ho on 8/25/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMTimerStyleKitWithColorExtensions.h"
#import "TMChangeFlagGraphicTableViewController.h"

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

+ (UIImage *)timerFlagWithMinTime:(float)minTime maxTime:(float)maxTime elapsedTime:(float)elapsedTime {
    __block float _minTime = minTime;
    __block float _maxTime = maxTime;
    DHDLog(^{
        _minTime /= kSecondsInAMinute;
        _maxTime /= kSecondsInAMinute;
    }, nil);
    minTime = _minTime;
    maxTime = _maxTime;
    
    UIImage *img;
    NSString *flagName = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsCurrentTimerFlagName];
    if ([flagName isEqualToString:kFlagSelectionPlain]) {
        img = [TMTimerStyleKit imageOfPlainGauge50_WithG_minSeconds:minTime
                                                       g_maxSeconds:maxTime
                                                   g_elapsedSeconds:elapsedTime];
        
    } else if ([flagName isEqualToString:kFlagSelectionWine]) {
        img = [TMTimerStyleKit imageOfWineGauge50WithG_minSeconds:minTime
                                                     g_maxSeconds:maxTime
                                                 g_elapsedSeconds:elapsedTime];
        DHDLog(nil, @"The Wine will be correct, but the spill time will be wrong.  Reason is because of a 30 second hard coded value in the code.  A minor issue and nothing to worry about.");
    } else { //it is either blank or in gauge
        img = [TMTimerStyleKit imageOfGauge50WithG_minSeconds:minTime
                                                 g_maxSeconds:maxTime
                                             g_elapsedSeconds:elapsedTime];
        DHDLog(nil, @"The Guage color will be correct, but the pointer will be wrong.  Reason is because of a 30 second hard coded value in the guage code.  A minor issue and nothing to worry about.");
    }

    return img;
}

@end
