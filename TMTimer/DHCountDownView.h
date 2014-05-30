//
//  DHCountDownView.h
//  TMTimer
//
//  Created by Derrick Ho on 3/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DHCountDownViewDelegate <NSObject>

//@required
///**
// The amount of time that should be taken displaying each character
// */
//- (float)characterDelay;
///**
// A string of characters that will be displayed one at a time
// after each characterDelay
// */
//- (NSString *)stringOfCharactersToCountDown;
//
//@optional
///**
// This method is called when the timer has completed its countdown
// 
// if you want to dismiss the countdownview, you should do it in here
// */
//- (void)countDownHasCompleted;

@end

@interface DHCountDownView : UIView
@property (weak, nonatomic) id <DHCountDownViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<DHCountDownViewDelegate>)delegate characterDelay:(float)characterDelay stringOfCharactersToCountDown:(NSString *)stringOfCharactersToCountDown completedCountDown:(void(^)())completed;

- (void)runCountDown:(BOOL)run;

@end
