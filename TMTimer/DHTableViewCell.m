//
//  DHTableViewCell.m
//  TMTimer
//
//  Created by ryukkusakku on 2/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHTableViewCell.h"
#import "Event.h"
#import "Event+helperMethods.h"
#import "DHColorForTime.h"

static const int kCellBottomMargin = 5;
static const int kCellSideMargin = 10;

@interface DHTableViewCell ()

@end

@implementation DHTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.elapsedTime.textColor = [TMTimerStyleKit tM_ThemeBlue];
    
    [self.userImageIcon.layer setCornerRadius:2];
    [self.userImageIcon.layer setBorderWidth:1];
    [self.userImageIcon.layer setBorderColor:[TMTimerStyleKit tM_ThemeBlue].CGColor];
    [self.userImageIcon.layer setMasksToBounds:YES];
    
    {//make the rounded corders of cells and a the margins
        self.layer.cornerRadius = kThemeCornerRadius;
        self.backgroundColor = [TMTimerStyleKit tM_ThemeAqua_bg];
        [self.layer setMasksToBounds:YES];
        [self.layer setBounds:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - kCellBottomMargin)];
    }
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += kCellSideMargin;
    frame.size.width -= 2 * kCellSideMargin;
    [super setFrame:frame];
}

@end
