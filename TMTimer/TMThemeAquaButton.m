//
//  TMThemeAquaButton.m
//  TMTimer
//
//  Created by Derrick Ho on 8/25/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMThemeAquaButton.h"

@implementation TMThemeAquaButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [TMTimerStyleKit drawButtonFrameAquaWithSoftAquaBGWithFrame:rect tM_ThemeCornerRadius:kThemeCornerRadius];
    [self setTitleColor:TMTimerStyleKit.tM_ThemeAqua forState:UIControlStateNormal];
}


@end
