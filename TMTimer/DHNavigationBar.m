//
//  DHNavigationBar.m
//  TMTimer
//
//  Created by Derrick Ho on 3/24/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHNavigationBar.h"
#import "DHGradients.h"

static const NSInteger kGodsMagicNumber = 77;

@implementation DHNavigationBar

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
    [TMTimerStyleKit drawTMNavBarWithFrame:rect];
}

@end
