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
@property (weak, nonatomic) IBOutlet UILabel *viewProfileLabel;
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
    self.viewProfileLabel.textColor = [TMTimerStyleKit tM_ThemeBlue];
    self.threeSecondDelay.onTintColor = [TMTimerStyleKit tM_ThemeAqua];
    self.showRunningTimer.onTintColor = [TMTimerStyleKit tM_ThemeAqua];
    self.showUserHints.onTintColor = [TMTimerStyleKit tM_ThemeAqua];
    self.vibrateSwitch.onTintColor = [TMTimerStyleKit tM_ThemeAqua];
    
    self.threeSecondDelay.thumbTintColor = [TMTimerStyleKit tM_ThemeAqua_bg];
    self.showRunningTimer.thumbTintColor = [TMTimerStyleKit tM_ThemeAqua_bg];
    self.showUserHints.thumbTintColor = [TMTimerStyleKit tM_ThemeAqua_bg];
    self.vibrateSwitch.thumbTintColor = [TMTimerStyleKit tM_ThemeAqua_bg];
    
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTopVC:self];
    
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	NSNumber *threeSecondDelay = [UD objectForKey:kUserDefault3SecondDelay];
	[self.threeSecondDelay setOn:threeSecondDelay.boolValue animated:YES];
    DHDLog(^{
        NSLog(@"ThreeSecondDelay is %d", threeSecondDelay.boolValue);
    });
    
	NSNumber *showRunningTimer = [UD objectForKey:kUserDefaultShowRunningTimer];
	[self.showRunningTimer setOn:showRunningTimer.boolValue animated:YES];
    DHDLog(^{
        NSLog(@"showRunningTimer is %d", showRunningTimer.boolValue);
    });
    
    NSNumber *showUserHints = [UD objectForKey:kUserDefaultShowUserHints];
    [self.showUserHints setOn:showUserHints.boolValue animated:YES];
    DHDLog(^{
        NSLog(@"show user hints is %@", showUserHints.boolValue ?@"enabled":@"disabled");
    });
    
    NSNumber *vibrate = [UD objectForKey:kUserDefaultsVibrateOnFlagChange];
    [self.vibrateSwitch setOn:vibrate.boolValue animated:YES];
    DHDLog(^{
        NSLog(@"show user hints is %@", vibrate.boolValue ?@"enabled":@"disabled");
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchAction:(id)sender {
    DHDLog(^{
        NSLog(@"ThreeSecondDelay became %d", self.threeSecondDelay.on);
    });
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	[UD setObject:@(self.threeSecondDelay.on) forKey:kUserDefault3SecondDelay];
	
    DHDLog(^{
        NSLog(@"showRunningTimer became %d", self.showRunningTimer.on);
    });
	[UD setObject:@(self.showRunningTimer.on) forKey:kUserDefaultShowRunningTimer];
    
    DHDLog(^{
        NSLog(@"show user hints is %@", self.showUserHints.on?@"enabled":@"disabled");
    });
    [UD setObject:@(self.showUserHints.on) forKey:kUserDefaultShowUserHints];
    
    DHDLog(^{
        NSLog(@"vibrations is %@", self.vibrateSwitch.on?@"enabled":@"disabled");
    });
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
    DHDLog(^{
        NSLog(@"begin clearing list of speakers");
    });
    
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
    
    
    DHDLog(^{
        NSLog(@"finished clearing list of speakers");
    });
    
}

#pragma mark - uialertviewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate arrOfAlerts] removeObject:alertView];
    if (buttonIndex == 1) {
        [self clearListOfSpeakers];
    }
}

- (IBAction)unwindBackToUserPreferences:(UIStoryboardSegue *)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - SEGUE

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"UserProfileSegue"]) {
        [[segue destinationViewController] setManagedObjectContext:_managedObjectContext];
    }
}

@end
