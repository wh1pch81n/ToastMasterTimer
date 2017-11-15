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
    [self _setupCoreDataStack];
    [self setArrOfAlerts:[NSMutableArray new]];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    DHMasterViewController *controller = (DHMasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
	
	[[UINavigationBar appearance] setTitleTextAttributes:
     @{
       NSFontAttributeName: [UIFont systemFontOfSize:kNavBarFontSize],
       NSForegroundColorAttributeName: [TMTimerStyleKit tM_ThemeBlue]
       }];
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName: [TMTimerStyleKit tM_ThemeBlue]}
                                                forState:UIControlStateNormal];
	
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
	[self registeringUserPreferences];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    DHDLog(nil, @"Will resign active");
    
	[self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DHDLog( nil, @"did enter background");
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cacheLib = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:cacheLib error:&error]) {
        NSString *fileToDelete = [NSString stringWithFormat:@"%@/%@", cacheLib, file];
        
        DHDLog( nil, @"try Delete: ~/%@", file);
        
        BOOL success = [fm removeItemAtPath:fileToDelete error:&error];
        if (!success || error) {
            DHDLog( nil, @"Could not delete: ~/%@", file);
        }
    }
    
	[self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    DHDLog( nil, @"did will enter foreground");
    
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
    url_str = [url_str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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

- (void)_setupCoreDataStack
{
    // setup managed object model
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TMTimer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    // setup persistent store coordinator
    NSURL *storeURL = [[[[NSFileManager defaultManager]
                         URLsForDirectory:NSDocumentDirectory
                         inDomains:NSUserDomainMask]
                        lastObject]
                       URLByAppendingPathComponent:@"TMTimer.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @(YES),
                              NSInferMappingModelAutomaticallyOption: @(YES)
                              };
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
      {
        [DHError displayValidationError:error];
      }
    
    // create MOC
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
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
       kQuickStart:@NO,
       kUserDefaultShowUserHints:@YES,
       kUserDefaultsVibrateOnFlagChange:@NO,
       kUserDefaultsHasShownManualFlagInfoBefore:@NO
       }];
}

@end
