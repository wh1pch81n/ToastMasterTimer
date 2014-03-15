//
//  DHCountDownView.h
//  TMTimer
//
//  Created by Derrick Ho on 3/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DHCountDownViewDelegate <NSObject>
@required
/**
 The amount of time that should be taken displaying each character
 */
- (float)characterDelay;
/**
 A string of characters that will be displayed one at a time
 after each characterDelay
 */
- (NSString *)stringOfCharactersToCountDown;
@end

@interface DHCountDownView : UIView
@property (weak, nonatomic) id <DHCountDownViewDelegate> delegate;

- (void)runCountDownThenDoThisWhenComplete:(void(^)())complete;
@end
