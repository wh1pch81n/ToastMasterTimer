//
//  DHCountDownView.h
//  TMTimer
//
//  Created by Derrick Ho on 3/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DHCountDownViewDelegate <NSObject>

@end

@interface DHCountDownView : UIView
@property (weak, nonatomic) id <DHCountDownViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<DHCountDownViewDelegate>)delegate characterDelay:(float)characterDelay stringOfCharactersToCountDown:(NSString *)stringOfCharactersToCountDown completedCountDown:(void(^)())completed;

- (void)runCountDown:(BOOL)run;

@end
