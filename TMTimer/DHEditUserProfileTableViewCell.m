//
//  DHEditUserProfileTableViewCell.m
//  TMTimer
//
//  Created by Derrick Ho on 8/19/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHEditUserProfileTableViewCell.h"

static const int kCellBottomMargin = 5;
static const int kCellSideMargin = 10;

@implementation DHEditUserProfileTableViewCell

-(void)drawRect:(CGRect)rect {
    self.layer.cornerRadius = kThemeCornerRadius;
    self.backgroundColor = [TMTimerStyleKit tM_ThemeAqua_bg];
    [self.layer setMasksToBounds:YES];
    [self.layer setBounds:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - kCellBottomMargin)];
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += kCellSideMargin;
    frame.size.width -= 2 * kCellSideMargin;
    [super setFrame:frame];
}

@end
