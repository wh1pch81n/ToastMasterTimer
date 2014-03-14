//
//  DHUserPreferenceViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 3/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHUserPreferenceViewController.h"
#import "DHGlobalConstants.h"

@interface DHUserPreferenceViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *threeSecondDelay;

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
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	NSNumber *threeSecondDelay = [UD objectForKey:kUserDefault3SecondDelay];
	[self.threeSecondDelay setOn:threeSecondDelay.boolValue animated:YES];
	NSLog(@"ThreeSecondDelay is %d", threeSecondDelay.boolValue);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchAction:(id)sender {
	NSLog(@"ThreeSecondDelay became %d", self.threeSecondDelay.on);
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	[UD setObject:@(self.threeSecondDelay.on) forKey:kUserDefault3SecondDelay];
}
@end