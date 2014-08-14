//
//  DHManualFlagViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 5/9/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHManualFlagViewController.h"
#import "DHAppDelegate.h"

NSString *const kUIAlertDemoEndedTitle = @"End or Repeat";
NSString *const kUIAlertDemoCancelButtonTitle = @"Finish";
NSString *const kUIAlertDemoRepeatButtonTitle = @"Repeat";

@interface DHManualFlagViewController ()

@property unsigned int st;
@property (weak, nonatomic) IBOutlet UIView *greenView;
@property (weak, nonatomic) IBOutlet UIView *yellowView;
@property (weak, nonatomic) IBOutlet UIView *redView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation DHManualFlagViewController

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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self initializeTouchEvents];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 sets up the view and subviews so that it will respond to touch events
 */
- (void)initializeTouchEvents {
    [self.greenView setUserInteractionEnabled:NO];
    [self.yellowView setUserInteractionEnabled:NO];
    [self.redView setUserInteractionEnabled:NO];
    [self.view becomeFirstResponder];
    [self.view setMultipleTouchEnabled:YES];
    
}

#pragma mark - Finite State Machine

- (void)FSM_black_flag {
    [[self view] setBackgroundColor:[UIColor blackColor]];
}

- (void)FSM_green_flag {
    [[self view] setBackgroundColor:[UIColor greenColor]];
}

- (void)FSM_yellow_flag {
    [[self view] setBackgroundColor:[UIColor yellowColor]];
}

- (void)FSM_red_flag {
    [[self view] setBackgroundColor:[UIColor redColor]];
}

- (void)FSM_end {
    //present a pop up that will ask if they want to exit or to repeat
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kUIAlertDemoEndedTitle
                                message:nil
                               delegate:self
                      cancelButtonTitle:kUIAlertDemoCancelButtonTitle
                      otherButtonTitles:kUIAlertDemoRepeatButtonTitle, nil];
    [alert show];
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate arrOfAlerts] addObject:alert];
}

- (void)FSM_exit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - info

- (IBAction)tappedInfoButton:(id)sender {
#warning needs implementing.  Create an animated graphic that will tell the user how to use the flags.
}

#pragma mark - tap

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint lastTouchPosition = [(UITouch *)event.allTouches.allObjects.lastObject locationInView:self.view];
    switch (event.allTouches.count) {
        case 1:
            if (CGRectContainsPoint(self.redView.frame, lastTouchPosition)) {
                [self FSM_red_flag];
            } else if (CGRectContainsPoint(self.yellowView.frame, lastTouchPosition)) {
                [self FSM_yellow_flag];
            }else {
                [self FSM_green_flag];
            }
            break;
        case 2:
            [self FSM_yellow_flag];
            break;
        case 3:
            [self FSM_red_flag];
            break;
        default:
            [self FSM_black_flag];
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    switch (event.allTouches.count - touches.count) {
        case 1:
            [self FSM_green_flag];
            break;
        case 2:
            [self FSM_yellow_flag];
            break;
        case 3:
            [self FSM_red_flag];
            break;
       
        default:
            [self FSM_black_flag];
            break;
    }
}

@end
