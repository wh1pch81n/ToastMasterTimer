//
//  DHDetailViewController.h
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class Event;
@interface DHDetailViewController : UIViewController <UISplitViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, ADBannerViewDelegate>

@property (strong, nonatomic) Event *detailItem;
@property (weak, nonatomic) NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end
