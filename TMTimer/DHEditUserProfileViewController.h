//
//  DHEditUserProfileViewController.h
//  TMTimer
//
//  Created by Derrick Ho on 8/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

enum Mode {UserProfileMode_NEW_PROFILE, UserProfileMode_MODIFY_PROFILE};

@interface DHEditUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectID *objectID;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) enum Mode EditingMode;

- (id)initWithContext:(NSManagedObjectContext *)context objectID:(NSManagedObjectID *)objectID editingMode:(enum Mode)mode;

@end
