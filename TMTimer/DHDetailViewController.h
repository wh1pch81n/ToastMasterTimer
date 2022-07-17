//
//  DHDetailViewController.h
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <AudioToolbox/AudioServices.h>
#import "DHCountDownView.h"

@class Event;
@interface DHDetailViewController : UIViewController <UISplitViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, DHCountDownViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) Event *detailItem;
@property (weak, nonatomic) NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField; //TODO:Rename this to blurbTextField

@end
