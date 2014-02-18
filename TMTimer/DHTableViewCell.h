//
//  DHTableViewCell.h
//  TMTimer
//
//  Created by ryukkusakku on 2/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contestantName;
@property (weak, nonatomic) IBOutlet UILabel *modifiedDate;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTime;
@property (weak, nonatomic) IBOutlet UILabel *timeRange;
@property (weak, nonatomic) IBOutlet UIView *flag;

@end
