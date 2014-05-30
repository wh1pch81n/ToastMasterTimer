//
//  DHAppDelegate.m
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHAppDelegate.h"
#import "DHGlobalConstants.h"
#import "DHMasterViewController.h"
#import "DHError.h"

NSString *const kName = @"name";
NSString *const kMinValue = @"min_value";
NSString *const kMaxValue = @"max_value";

NSString *const kHost = @"tmtimer328";

@implementation DHAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
    [self setArrOfAlerts:[NSMutableArray new]];
    
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
		UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
		splitViewController.delegate = (id)navigationController.topViewController;
		
		UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
		DHMasterViewController *controller = (DHMasterViewController *)masterNavigationController.topViewController;
		controller.managedObjectContext = self.managedObjectContext;
	} else {
		UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
		DHMasterViewController *controller = (DHMasterViewController *)navigationController.topViewController;
		controller.managedObjectContext = self.managedObjectContext;
	}
	
	[[UINavigationBar appearance] setTitleTextAttributes:
  @{
    NSFontAttributeName: [UIFont systemFontOfSize:kNavBarFontSize],
//		 UITextAttributeFont: [UIFont systemFontOfSize:kNavBarFontSize], // deprecated
		 NSForegroundColorAttributeName: [UIColor whiteColor]
		 }];
	
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
	[self registeringUserPreferences];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
#if DEBUG
    NSLog(@"Will resign active");
#endif
	[self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
#if DEBUG
    NSLog(@"did enter background");
#endif
	[self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
#if DEBUG
    NSLog(@"did will enter foreground");
#endif
    
	[self saveContext];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // Since you have 3 different views, you must make the masterview become the current view if it isn't already the current view.
    //Then you must call the public function of the master view that will allow you to do a quick start.
    //TODO: I suggest using the [url host] and [url path] methods instead of the str manip
   if ([@"com.dnthome.TMTopic" isEqualToString:sourceApplication] == NO) return NO;
    
    NSString *url_str = [url.absoluteString substringFromIndex:@"tmtimer328:".length];
    url_str = [url_str stringByRemovingPercentEncoding];
    NSData *json_data = [url_str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *url_args = [NSJSONSerialization JSONObjectWithData:json_data options:0 error:nil];
    
    for (UIAlertView *alert in self.arrOfAlerts) {
        [alert dismissWithClickedButtonIndex:0 animated:NO]; //press cancle for all of them
    }
    
    [[self topVC] performSegueWithIdentifier:@"unwind" sender:self];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    DHMasterViewController *controller = (DHMasterViewController *)navigationController.topViewController;
    NSString *topic = url_args[kName];
    int min = [(NSNumber *)url_args[kMinValue] intValue];
    int max = [(NSNumber *)url_args[kMaxValue] intValue];
    [controller customStartTopic:topic withMinTime:min withMaxTime:max];
    
    return YES;
}

- (void)saveContext
{
	NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
	if (managedObjectContext != nil) {
		if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			[DHError displayValidationError:error];
		}
	}
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
	if (_managedObjectContext != nil) {
		return _managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		_managedObjectContext = [[NSManagedObjectContext alloc] init];
		[_managedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
	if (_managedObjectModel != nil) {
		return _managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TMTimer" withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (_persistentStoreCoordinator != nil) {
		return _persistentStoreCoordinator;
	}
	
	NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TMTimer.sqlite"];
	
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	
	NSDictionary *options = @{
														NSMigratePersistentStoresAutomaticallyOption: @(YES),
														NSInferMappingModelAutomaticallyOption: @(YES)
														};
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
		[DHError displayValidationError:error];
	}
	
	return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - User Preferences

- (void)registeringUserPreferences {
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 @{
		 kUserDefaultMinTime:@4,
		 kUserDefaultMaxTime:@6,
		 kUserDefault3SecondDelay:@NO,
		 kUserDefaultShowRunningTimer:@YES,
         kQuickStart:@NO
		 }];
}

@end
