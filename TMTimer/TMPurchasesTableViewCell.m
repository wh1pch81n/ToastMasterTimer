//
//  TMPurchasesTableViewCell.m
//  TMTimer
//
//  Created by Derrick Ho on 9/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMPurchasesTableViewCell.h"

@implementation TMPurchasesTableViewCell

- (void)drawRect:(CGRect)rect {
    [self.productNameLabel setTextColor:[TMTimerStyleKit tM_ThemeBlue]];
}

@end
