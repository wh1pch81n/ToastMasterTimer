//
//  TMChangeFalgTableViewCell.h
//  TMTimer
//
//  Created by Derrick Ho on 9/15/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

@import UIKit;

@interface TMChangeFlagTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *greenView;
@property (weak, nonatomic) IBOutlet UIImageView *yellowView;
@property (weak, nonatomic) IBOutlet UIImageView *redView;

@property (strong, nonatomic) NSString *cellName;

@end
