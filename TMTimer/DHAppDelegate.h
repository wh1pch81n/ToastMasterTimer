//
//  DHAppDelegate.h
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kName;
extern NSString *const kMinValue;
extern NSString *const kMaxValue;

extern NSString *const kHost;

@interface DHAppDelegate : UIResponder <UIApplicationDelegate>

@property (weak, nonatomic) UIViewController *topVC;
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
