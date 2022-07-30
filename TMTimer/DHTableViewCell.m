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
    [self.userImageIcon.layer setCornerRadius:2];
    [self.userImageIcon.layer setBorderWidth:1];
    [self.userImageIcon.layer setMasksToBounds:YES];
    
    {//make the rounded corders of cells and a the margins
        self.cellBG.layer.cornerRadius = kThemeCornerRadius;
        //self.cellBG.backgroundColor = [TMTimerStyleKit tM_ThemeAqua_bg];
        [self.cellBG.layer setMasksToBounds:YES];
    }

}

@end
