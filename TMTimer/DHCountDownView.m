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
		[self addSubview:self.characterDisplayed];
		self.backgroundColor = [UIColor clearColor];
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

- (void)runCountDown:(BOOL)run ThenDoThisWhenComplete:(void (^)())complete {
	if (!self.delegate) {
		return;
	}
	if (run == NO) {
		if (complete) {
			complete();
		}
		return;
	}
	NSString *charArr = [self.delegate stringOfCharactersToCountDown];
	for(int delay = 0; delay <= charArr.length; ++delay) {

		double delayInSeconds = [self.delegate characterDelay]* delay;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			if (delay == charArr.length) {
				if (complete) {
					complete();
				}
			} else {
				NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:[charArr substringWithRange:NSMakeRange(delay, 1)] attributes:
																			 @{NSFontAttributeName: [UIFont systemFontOfSize:200]
																				 }];
				[self.characterDisplayed setAttributedText:attrStr];
				[self.characterDisplayed setTextAlignment:NSTextAlignmentCenter];
//				[UIView animateWithDuration:delayInSeconds/2 animations:^{
//					self.characterDisplayed.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
//				} completion:Nil];
				NSLog(@"%@", self.characterDisplayed.text);
			}
		});
	}
}

@end
