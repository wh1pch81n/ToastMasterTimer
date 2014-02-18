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

@implementation DHTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIColor *color = [self.entity bgColorFromData];
    [super setSelected:selected animated:animated];
    NSLog(@"\n%@\n%@\n",
          color,
          self.flag.backgroundColor);
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.flag setBackgroundColor:self.entity.bgColorFromData];
}



@end
