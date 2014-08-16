//
//  DHManualFlagViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 5/9/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHManualFlagViewController.h"
#import "DHGlobalConstants.h"
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

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (strong, nonatomic) UIImageView *infoImageView; //contains the animations
@property (assign, nonatomic) BOOL hasRequestedInfoImages;

@end

@implementation DHManualFlagViewController {
    dispatch_queue_t infoQueue;
}

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
    infoQueue = dispatch_queue_create("info_queue", nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadAnimationImagesInBackground];
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

#pragma mark - InfoAnimation

- (void)loadAnimationImagesInBackground {
    if (self.infoImageView) {
        return;
    }
    dispatch_queue_t loadAnimationQueue = dispatch_queue_create("load_animation_queue", NULL);
    dispatch_async(loadAnimationQueue, ^{
        CGRect imageFrame = CGRectMake(self.view.center.x -150, self.view.center.y -150, 300, 300);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        NSURL *pathToInfoImages = [[NSBundle mainBundle] URLForResource:@"ManualFlagInfoAnimationImageNames"
                                                          withExtension:@"plist"];
        NSDictionary *InfoDict = [NSDictionary dictionaryWithContentsOfURL:pathToInfoImages];
        NSString *ext = InfoDict[@"file_extention_name"];
        NSMutableArray *mut = [NSMutableArray new];
        for (NSString *name in InfoDict[@"images"]) {
            [mut addObject:[UIImage imageNamed:[name stringByAppendingPathExtension:ext]]];
        }
        
        [imageView setAnimationImages:mut];
        [imageView setAnimationDuration:mut.count];
        [imageView setAnimationRepeatCount:1];
        [self setInfoImageView:imageView];
        
        NSNumber *autoLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsHasShownManualFlagInfoBefore];
        
        if ([autoLaunch boolValue] == NO) {
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserDefaultsHasShownManualFlagInfoBefore];
            [self presentInfoAnimation];
        } else if (self.hasRequestedInfoImages == YES) {
            self.hasRequestedInfoImages = NO;
            [self presentInfoAnimation];
        }
        
    });
}

- (void)presentInfoAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.infoImageView isAnimating]) {
            return;
        }
        [self.view addSubview:self.infoImageView];
        NSInteger numSecondsOfAnimation = self.infoImageView.animationImages.count;
        [self.infoImageView startAnimating];
        [self performSelector:@selector(stopInfoAnimation) withObject:nil afterDelay:numSecondsOfAnimation];
    });
}

- (void)stopInfoAnimation {
    [self.infoImageView stopAnimating];
    [self.infoImageView removeFromSuperview];
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
    if (self.infoImageView) {
        [self presentInfoAnimation];
    } else {
        [self setHasRequestedInfoImages:YES];
    }

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
