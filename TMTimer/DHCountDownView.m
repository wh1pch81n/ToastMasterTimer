//
//  DHCountDownView.m
//  TMTimer
//
//  Created by Derrick Ho on 3/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHCountDownView.h"

@interface DHCountDownView ()
@property (strong, nonatomic) UILabel *characterDisplayed;
@end

@implementation DHCountDownView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.characterDisplayed = [[UILabel alloc] initWithFrame:frame];
	}
	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)runCountDownThenDoThisWhenComplete:(void (^)())complete {
	if (!self.delegate) {
		return;
	}
	NSString *charArr = [self.delegate stringOfCharactersToCountDown];
	for(int delay = 0; delay <= charArr.length; ++delay) {
		if (delay == charArr.length) {
			if (complete) {
				complete();
			}
			break;
		}
		double delayInSeconds = [self.delegate characterDelay];
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self.characterDisplayed setText:[charArr substringWithRange:NSMakeRange(delay, 1)]];
		});
	}
}

@end
