//
//  DHQuickPanelTableViewCell.m
//  TMTimer
//
//  Created by Derrick Ho on 8/26/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHQuickPanelTableViewCell.h"

@implementation DHQuickPanelTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
      self.presetSegmentedButtons.tintColor = [TMTimerStyleKit tM_ThemeBlue];
}

@end
