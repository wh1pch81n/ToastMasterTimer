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
@property (nonatomic, assign) int characterIndex;
@property (nonatomic, copy) void (^complete)();
@property (strong, nonatomic) NSMutableArray *arrTimers;

@end

@implementation DHCountDownView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
       	self.characterDisplayed = [[UILabel alloc] initWithFrame:frame];
		[self addSubview:self.characterDisplayed];
		//self.backgroundColor = [UIColor grayColor];
        //self.characterDisplayed.backgroundColor = [UIColor grayColor];
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
    
    [self setComplete:complete];
    
	NSString *charArr = [self.delegate stringOfCharactersToCountDown];
    self.characterIndex = 0;
	for(int delay = 0; delay <= charArr.length; ++delay) {

		double delayInSeconds = [self.delegate characterDelay]* delay;
        [self performAfterDelay:delayInSeconds];
 	}
}

/**
 Creates an nstimer that will fire once after a set amount of time has passed
 */
- (void)performAfterDelay:(double)delay
{
    [self.arrTimers addObject:[NSTimer scheduledTimerWithTimeInterval:delay
                                     target:self
                                   selector:@selector(changeCharacter)
                                   userInfo:nil
                                    repeats:NO]];
}

- (void)completeAnimation {
    if (self.complete) {
        self.complete();
    }
}

- (void)changeCharacter
{
    if (self.characterIndex >= [self.delegate stringOfCharactersToCountDown].length) {
        [self completeAnimation];
        return;
    }

    NSString *charArr = [self.delegate stringOfCharactersToCountDown];
    NSString *str = [charArr substringWithRange:NSMakeRange(self.characterIndex++, 1)];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str
                                                                  attributes:
                                   @{
                                     NSFontAttributeName: [UIFont systemFontOfSize:200],
                                     
                                     }];
    [self.characterDisplayed setAttributedText:attrStr];
    [self.characterDisplayed setTextAlignment:NSTextAlignmentCenter];
    
    self.characterDisplayed.transform = CGAffineTransformScale(CGAffineTransformIdentity, 3, 3);
    [UIView animateWithDuration:[self.delegate characterDelay]/2 animations:^{
       self.characterDisplayed.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    } completion:Nil];
    
    NSLog(@"%@", self.characterDisplayed.text);
}

@end
