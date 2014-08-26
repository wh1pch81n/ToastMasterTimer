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

@property (weak, nonatomic) IBOutlet UISegmentedControl *presetSegmentedButton;

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //[self.flag setBackgroundColor:self.entity.bgColorFromData];
//    Event *object = self.entity;
//    NSTimeInterval total = [object.endDate timeIntervalSinceDate:object.startDate];
//    UIColor *bgColor = [[DHColorForTime shared] colorForSeconds:total
//                                                            min:object.minTime.integerValue
//                                                            max:object.maxTime.integerValue];
//    if ([bgColor isEqual:[UIColor blackColor]]) {
//        bgColor = [UIColor clearColor];
//    }
//    [self.flag setBackgroundColor:bgColor];
}
- (void)drawRect:(CGRect)rect {
    self.elapsedTime.textColor = [TMTimerStyleKit tM_ThemeBlue];
    self.presetSegmentedButton.tintColor = [TMTimerStyleKit tM_ThemeBlue];
}
@end
