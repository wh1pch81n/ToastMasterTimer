//
//  DHUserProfileCollectionViewController.h
//  TMTimer
//
//  Created by Derrick Ho on 8/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User_Profile;
@interface DHUserProfileCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/**
 Determines what will happen when a cell is tapped.  
 Default value is nil.  If nil it will present an editing view.
 
 Implement this with a block to perform other things with the User_Profile.
 */
@property (strong, nonatomic) void(^customCellTapResponse)(User_Profile *userProfile, DHUserProfileCollectionViewController *collectionVC);

@end
