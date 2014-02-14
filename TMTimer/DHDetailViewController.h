//
//  DHDetailViewController.h
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@interface DHDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Event *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
