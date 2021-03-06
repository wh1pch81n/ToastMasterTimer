//
//  DHMasterViewController.h
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class DHDetailViewController;

extern NSString *const UserDefaultsKey_NewVersion;

#import <CoreData/CoreData.h>

@interface DHMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DHDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)customStartTopic:(NSString *)topic withMinTime:(int)min withMaxTime:(int)max;

@end
