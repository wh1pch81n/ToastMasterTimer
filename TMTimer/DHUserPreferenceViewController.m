//
//  DHUserPreferenceViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 3/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHUserPreferenceViewController.h"
#import "DHGlobalConstants.h"
#import "DHAppDelegate.h"
#import "DHError.h"

@interface DHUserPreferenceViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *threeSecondDelay;
@property (weak, nonatomic) IBOutlet UISwitch *showRunningTimer;
@property (weak, nonatomic) IBOutlet UISwitch *showUserHints;
@property (weak, nonatomic) IBOutlet UISwitch *vibrateSwitch;
@end

@implementation DHUserPreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTopVC:self];
    
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	NSNumber *threeSecondDelay = [UD objectForKey:kUserDefault3SecondDelay];
	[self.threeSecondDelay setOn:threeSecondDelay.boolValue animated:YES];
#if DEBUG
    NSLog(@"ThreeSecondDelay is %d", threeSecondDelay.boolValue);
#endif
    
	NSNumber *showRunningTimer = [UD objectForKey:kUserDefaultShowRunningTimer];
	[self.showRunningTimer setOn:showRunningTimer.boolValue animated:YES];
#if DEBUG
    NSLog(@"showRunningTimer is %d", showRunningTimer.boolValue);
#endif
    
    NSNumber *showUserHints = [UD objectForKey:kUserDefaultShowUserHints];
    [self.showUserHints setOn:showUserHints.boolValue animated:YES];
#if DEBUG
    NSLog(@"show user hints is %@", showUserHints.boolValue ?@"enabled":@"disabled");
#endif
    
    NSNumber *vibrate = [UD objectForKey:kUserDefaultsVibrateOnFlagChange];
    [self.vibrateSwitch setOn:vibrate.boolValue animated:YES];
#if DEBUG
    NSLog(@"show user hints is %@", vibrate.boolValue ?@"enabled":@"disabled");
#endif

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchAction:(id)sender {
#if DEBUG
    NSLog(@"ThreeSecondDelay became %d", self.threeSecondDelay.on);
#endif
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	[UD setObject:@(self.threeSecondDelay.on) forKey:kUserDefault3SecondDelay];
	
#if DEBUG
    NSLog(@"showRunningTimer became %d", self.showRunningTimer.on);
#endif
	[UD setObject:@(self.showRunningTimer.on) forKey:kUserDefaultShowRunningTimer];
    
#if DEBUG
    NSLog(@"show user hints is %@", self.showUserHints.on?@"enabled":@"disabled");
#endif
    [UD setObject:@(self.showUserHints.on) forKey:kUserDefaultShowUserHints];
    
#if DEBUG
    NSLog(@"vibrations is %@", self.vibrateSwitch.on?@"enabled":@"disabled");
#endif
    [UD setObject:@(self.vibrateSwitch.on) forKey:kUserDefaultsVibrateOnFlagChange];

    
}

- (IBAction)tappedClearSpeakerList:(id)sender {
    //launch alert and if select yes, then call clearListOfSpeakers
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Data?"
                                                    message:@"Selecting YES will clear the entire list of speakers."
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
}


#pragma mark - Core Data

- (void)clearListOfSpeakers {
#if DEBUG
    NSLog(@"begin clearing list of speakers");
#endif

    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *allSpeakers = [[NSFetchRequest alloc] init];
    [allSpeakers setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:appDelegate.managedObjectContext]];
    [allSpeakers setIncludesPropertyValues:NO];//Only fetch the managedObjectID
    NSError *err;
    NSArray *speakers = [appDelegate.managedObjectContext executeFetchRequest:allSpeakers error:&err];
    
    if (!err) {
        [DHError displayValidationError:err];
    }
    
    for (NSManagedObject *speaker in speakers) {
        [appDelegate.managedObjectContext deleteObject:speaker];
    }
    
    NSError *saveError;
    if(![appDelegate.managedObjectContext save:&saveError]) {
        [DHError displayValidationError:saveError];
    }
    
    
#if DEBUG
    NSLog(@"finished clearing list of speakers");
#endif
    
}

#pragma mark - uialertviewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate arrOfAlerts] removeObject:alertView];
    if (buttonIndex == 1) {
        [self clearListOfSpeakers];
    }
}

@end
