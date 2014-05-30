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

@property float characterDelay;
@property (strong, nonatomic) NSString *stringOfCharactersToCountDown;

@end

@implementation DHCountDownView

- (id)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame delegate:nil characterDelay:0 stringOfCharactersToCountDown:nil completedCountDown:nil];
}

- (id)initWithFrame:(CGRect)frame
           delegate:(id<DHCountDownViewDelegate>)delegate
     characterDelay:(float)characterDelay
stringOfCharactersToCountDown:(NSString *)stringOfCharactersToCountDown
 completedCountDown:(void (^)())completed {
    self = [super initWithFrame:frame];
    if(self) {
        self.characterDisplayed = [[UILabel alloc] initWithFrame:frame];
        [self addSubview:self.characterDisplayed];
        self.delegate = delegate;
        self.characterDelay = characterDelay;
        self.stringOfCharactersToCountDown = stringOfCharactersToCountDown;
        self.complete = completed;
    }
    return self;
}

- (void)runCountDown:(BOOL)run {
	if (!self.delegate) {
		return;
	}
	if (run == NO) {
        [self completeAnimation];
		return;
	}
    
    NSString *charArr = self.stringOfCharactersToCountDown;
    self.characterIndex = 0;
    for(int delay = 0; delay <= charArr.length; ++delay) {
        double delayInSeconds = self.characterDelay * delay;
        [self performAfterDelay:delayInSeconds];
    }
}

/**
 Creates an nstimer that will fire once after a set amount of time has passed
 */
- (void)performAfterDelay:(double)delay
{
    [NSTimer scheduledTimerWithTimeInterval:delay
                                     target:self
                                   selector:@selector(changeCharacter:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)completeAnimation {
    if (self.complete) {self.complete();}
}

- (void)changeCharacter:(NSTimer *)aTimer {
    if (self.characterIndex >= self.stringOfCharactersToCountDown.length) {
        [self completeAnimation];
        return;
    }

    NSString *charArr = self.stringOfCharactersToCountDown;
    NSString *str = [charArr substringWithRange:NSMakeRange(self.characterIndex++, 1)];
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str
                                                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:200]}];
    [self.characterDisplayed setAttributedText:attrStr];
    [self.characterDisplayed setTextAlignment:NSTextAlignmentCenter];
    
    CGAffineTransform bigScale = CGAffineTransformScale(CGAffineTransformIdentity, 3, 3);
    CGAffineTransform smallScale = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
    self.characterDisplayed.alpha = 1;
    self.characterDisplayed.transform = bigScale;
    [UIView animateWithDuration:self.characterDelay/2 animations:^{
        self.characterDisplayed.transform = smallScale;
    }];
    
#if DEBUG
    NSLog(@"Count down text %@", self.characterDisplayed.text);
#endif
}

@end
