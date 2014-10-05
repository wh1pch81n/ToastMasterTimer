//
//  DHEditUserProfileTableViewCell.h
//  TMTimer
//
//  Created by Derrick Ho on 8/19/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

@import UIKit;

@interface DHEditUserProfileTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *blurb;
@property (strong, nonatomic) IBOutlet UILabel *range;
@property (strong, nonatomic) IBOutlet UIView *flag;
@property (weak, nonatomic) IBOutlet UIImageView *gauge;

@end
