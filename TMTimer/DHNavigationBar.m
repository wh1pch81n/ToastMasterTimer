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

- (void)drawRect:(CGRect)rect
{
	UIColor *topColor = [UIColor colorWithRed:49.0/255.0 green:249.0/255.0 blue:236.0/255.0 alpha:1]; //cyanish color
	UIColor *bottomColor = [UIColor colorWithRed:36.0/255.0 green:123.0/255.0 blue:128.0/255 alpha:1]; //cyanish bluish color
	[DHGradients drawRectAtULPoint:rect.origin
														size:rect.size
												 ulColor:topColor
												 urColor:topColor
												 llColor:bottomColor
												 lrColor:bottomColor];
	UIColor *sprinkleColor = [UIColor colorWithRed:49/255.0 green:249/255.0 blue:236/255.0 alpha:0.5];
	[DHGradients produceRandomDots:kGodsMagicNumber
												 inFrame:rect
											 withColor:sprinkleColor];
}

@end
