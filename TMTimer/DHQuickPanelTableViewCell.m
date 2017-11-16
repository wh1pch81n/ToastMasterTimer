//
//  DHQuickPanelTableViewCell.m
//  TMTimer
//
//  Created by Derrick Ho on 8/26/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHQuickPanelTableViewCell.h"

@implementation DHQuickPanelTableViewCell

- (void)drawRect:(CGRect)rect {
      self.presetSegmentedButtons.tintColor = [TMTimerStyleKit tM_ThemeBlue];
}

@end
