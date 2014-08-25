//
//  SKTimerGaugeView.m
//  TMTimer
//
//  Created by Derrick Ho on 8/24/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "SKTimerGaugeView.h"
#import "TMTimerStyleKit.h"

@implementation SKTimerGaugeView

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
    [TMTimerStyleKit drawGauge50WithG_minSeconds:_minSeconds g_maxSeconds:_maxSeconds g_elapsedSeconds:_elapsedSeconds];
}


@end
