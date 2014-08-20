//
//  DHTableViewCell.h
//  TMTimer
//
//  Created by ryukkusakku on 2/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;
@interface DHTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *contestantName; //ths is actually the blurb.  change later
@property (weak, nonatomic) IBOutlet UILabel *creationDate;
@property (weak, nonatomic) IBOutlet UILabel *elapsedTime;
@property (weak, nonatomic) IBOutlet UILabel *timeRange;
@property (weak, nonatomic) IBOutlet UIView *flag;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (strong, nonatomic) Event *entity;

@end
