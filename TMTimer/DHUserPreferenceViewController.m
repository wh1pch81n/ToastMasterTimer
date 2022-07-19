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
#import "TMIAPHelper.h"
#import "TMPurchasesViewController.h"

@interface DHUserPreferenceViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *changeFlagTableViewCell;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *removeAdsButton;
@property (weak, nonatomic) IBOutlet UISwitch *threeSecondDelay;
@property (weak, nonatomic) IBOutlet UISwitch *showRunningTimer;
@property (weak, nonatomic) IBOutlet UISwitch *showUserHints;
@property (weak, nonatomic) IBOutlet UISwitch *vibrateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *viewProfileLabel;
@property (strong, nonatomic) TMPurchasesViewController *purchasesViewController;
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
    
    [self.rateButton
     setTitleColor:[TMTimerStyleKit tM_ThemeBlue]
     forState:UIControlStateNormal];
    self.viewProfileLabel
    .textColor = [TMTimerStyleKit tM_ThemeBlue];
    self.threeSecondDelay
    .onTintColor = [TMTimerStyleKit tM_ThemeAqua];
    self.showRunningTimer
    .onTintColor = [TMTimerStyleKit tM_ThemeAqua];
    self.showUserHints
    .onTintColor = [TMTimerStyleKit tM_ThemeAqua];
    self.vibrateSwitch
    .onTintColor = [TMTimerStyleKit tM_ThemeAqua];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.threeSecondDelay
        .thumbTintColor = [TMTimerStyleKit tM_ThemeAqua_bg];
        self.showRunningTimer
        .thumbTintColor = [TMTimerStyleKit tM_ThemeAqua_bg];
        self.showUserHints
        .thumbTintColor = [TMTimerStyleKit tM_ThemeAqua_bg];
        self.vibrateSwitch
        .thumbTintColor = [TMTimerStyleKit tM_ThemeAqua_bg];
    }
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTopVC:self];
    
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	BOOL threeSecondDelay = [UD boolForKey:kUserDefault3SecondDelay];
	[self.threeSecondDelay setOn:threeSecondDelay animated:YES];
    DHDLog(nil, @"ThreeSecondDelay is %d", threeSecondDelay);
    
    
	NSNumber *showRunningTimer = [UD objectForKey:kUserDefaultShowRunningTimer];
	[self.showRunningTimer setOn:showRunningTimer.boolValue animated:YES];
    DHDLog(nil, @"showRunningTimer is %d", showRunningTimer.boolValue);
    
    NSNumber *showUserHints = [UD objectForKey:kUserDefaultShowUserHints];
    [self.showUserHints setOn:showUserHints.boolValue animated:YES];
    DHDLog(nil, @"show user hints is %@", showUserHints.boolValue ?@"enabled":@"disabled");
    
    NSNumber *vibrate = [UD objectForKey:kUserDefaultsVibrateOnFlagChange];
    [self.vibrateSwitch setOn:vibrate.boolValue animated:YES];
    
    DHDLog(nil, @"show user hints is %@", vibrate.boolValue ?@"enabled":@"disabled");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[TMIAPHelper sharedInstance] canDisplayAds] == NO ||
        (UIDevice.currentDevice.systemVersion.floatValue < 7))
      {
        [self.removeAdsButton setEnabled:NO];
      }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchAction:(id)sender {
    DHDLog(nil, @"ThreeSecondDelay became %d", self.threeSecondDelay.on);

	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	[UD setBool:self.threeSecondDelay.on forKey:kUserDefault3SecondDelay];
	
    DHDLog(nil, @"showRunningTimer became %d", self.showRunningTimer.on);
    
	[UD setBool:self.showRunningTimer.on forKey:kUserDefaultShowRunningTimer];
    
    DHDLog(nil, @"show user hints is %@", self.showUserHints.on?@"enabled":@"disabled");

    [UD setBool:self.showUserHints.on forKey:kUserDefaultShowUserHints];
    
    DHDLog(nil, @"vibrations is %@", self.vibrateSwitch.on?@"enabled":@"disabled");
    
    [UD setBool:self.vibrateSwitch.on forKey:kUserDefaultsVibrateOnFlagChange];
    
    
}

- (IBAction)tappedClearSpeakerList:(id)sender {
    //launch alert and if select yes, then call clearListOfSpeakers

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Data?" message:@"Selecting YES will clear the entire list of speech times." preferredStyle:UIAlertControllerStyleAlert];
    __weak DHUserPreferenceViewController *weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf clearListOfSpeechTimes];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}]];
    
    [self presentViewController:alert animated:YES completion:^{}];
}


#pragma mark - Core Data

- (void)clearListOfSpeechTimes {
    DHDLog(nil, @"begin clearing list of speech times");
    
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
    
    
    DHDLog(nil, @"finished clearing list of speech times");
    
}

- (IBAction)unwindBackToUserPreferences:(UIStoryboardSegue *)sender {
}

#pragma mark - SEGUE

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"UserProfileSegue"]) {
        [[segue destinationViewController] setManagedObjectContext:_managedObjectContext];
    }
}

#pragma mark - In App Purchase

- (IBAction)tappedInAppPurchasesButton:(id)sender {
    TMPurchasesViewController *pvc = [TMPurchasesViewController.alloc initWithNibName:@"TMPurchasesViewController" bundle:nil];
    self.purchasesViewController = pvc;
    [self.navigationController pushViewController:pvc animated:YES];
}
- (IBAction)tappedRestorePastPurchases:(id)sender {
    [TMIAPHelper.sharedInstance restoreCompletedTransactions];
}

@end
