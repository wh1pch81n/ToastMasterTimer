//
//  DHDetailViewController.m
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHDetailViewController.h"
#import "Event.h"
#import "Event+helperMethods.h"
#import "DHGlobalConstants.h"
#import "DHAppDelegate.h"
#import "DHNavigationItem.h"
#import "DHColorForTime.h"
#import "UISegmentedControl+extractMinMaxData.h"

enum {
	kdummy0,
	kPresetButton1_2,
	kPresetButton2_3,
	kPresetButton3_4,
	kPresetButton4_6,
	kPresetButton5_7,
	kdummy6,
	kdummy7,
	kPresetButton8_10
};

enum {
	kTimeGreen,
	kTimeRed,
	kNumElementsInTimeEnum
};

const int kNumUpdatesPerSecond = 1;
const int kOnTheFlyEditingTimeOUt = 3;
NSString *const kDelayTitle = @"3-2-1 Delay";

@interface DHDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelTapToEdit;
@property (weak, nonatomic) IBOutlet UILabel *labelSwipeRightToStop;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture2f2t;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture1f1t;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGesture;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *presetTimesSegment;
@property (weak, nonatomic) IBOutlet UIView *timeChooserParentView;

@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet DHNavigationItem *navItem;

@property (strong, nonatomic) DHCountDownView *countDownView;

@property BOOL canUpdate;

@property int secondsUntilOnTheFlyEditingEnds;
@property BOOL isOnTheFlyEditing;

//---
@property (strong, nonatomic) NSDate *endDate, *startDate;
@property (strong, nonatomic) NSNumber *minTime, *maxTime;
@property (strong, nonatomic) NSString *name, *totalTime;

- (void)configureView;

@end

@implementation DHDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
	if (_detailItem != newDetailItem) {
		_detailItem = newDetailItem;
		
		// Update the view.
		[self configureView];
	}
	
	if (self.masterPopoverController != nil) {
		[self.masterPopoverController dismissPopoverAnimated:YES];
	}
}

- (void)configureView
{
	// Update the user interface for the detail item.
	if (self.detailItem) {
		self.nameTextField.text = _name;
		
		BOOL titleIsVisible = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultShowRunningTimer] boolValue];
		if (titleIsVisible) {
			[[self navItem] setTitle:_totalTime];
		} else {
			[[self navItem] setTitle:@""];
		}
		
	}
}

- (void)setLocalDetailPropertiesWithDetail:(Event *)detail {
    _endDate = detail.endDate;
    _startDate = detail.startDate;
    _maxTime = detail.maxTime;
    _minTime = detail.minTime;
    _name = detail.name;
    _totalTime = detail.totalTime;
}

- (void)setDetailItemWithEndDate:(NSDate *)endDate
                       startDate:(NSDate *)startDate
                         maxTime:(NSNumber *)maxTime
                         minTime:(NSNumber *)minTime
                            name:(NSString *)name
                       totalTime:(NSString *)totalTime
{
    self.detailItem.endDate = endDate;
    self.detailItem.startDate = startDate;
    self.detailItem.maxTime = maxTime;
    self.detailItem.minTime = minTime;
    self.detailItem.name = name;
    self.detailItem.totalTime = totalTime;
    
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate saveContext];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTopVC:self];
    
    
    [self setLocalDetailPropertiesWithDetail:self.detailItem];
	[self configureView];
	[self FSM_idle];
	
	//Default values
	[self updateMin:_minTime max:_maxTime];
    [self.bannerView setHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	//Save context before leaving
	[self setDetailItemWithEndDate:_endDate
                         startDate:_startDate
                           maxTime:_maxTime
                           minTime:_minTime
                              name:_name
                         totalTime:_totalTime];
	
	[super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *shouldQuickStart = [[NSUserDefaults standardUserDefaults] objectForKey:kQuickStart];
#if DEBUG
    NSLog(@"should quick start %@", shouldQuickStart);
#endif
    if (shouldQuickStart.boolValue == YES) {
        [self tappedStartStopButton:self];
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:kQuickStart];
    }
    
    NSNumber *showUserHints =(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultShowUserHints];
    
    [[self labelSwipeRightToStop] setHidden:!showUserHints.boolValue];
    [[self labelTapToEdit] setHidden:!showUserHints.boolValue];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
	barButtonItem.title = NSLocalizedString(@"Master", @"Master");
	[self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
	self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
	// Called when the view is shown again in the split view, invalidating the button and popover controller.
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	self.masterPopoverController = nil;
}

#pragma mark - picker datasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2; //2 columns for green and red card
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 60; //pick a number from 0 to 59
}

#pragma mark - picker delegate

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return pickerView.frame.size.width/3 -10;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 30;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	//component 0 goes from 0-59 but component 1 goes from 1-60
	return [NSString stringWithFormat:@"%ld", (long)(row + component)];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	NSString *text = [NSString stringWithFormat:@"%ld", (long)(row + component)];
	UILabel *label;
    if (view) {
        label = (UILabel *)view;
        
        label.attributedText = [[NSAttributedString alloc]
                                initWithString:text
                                attributes:@{
                                             NSForegroundColorAttributeName: kPickerViewTextColor,
                                             NSFontAttributeName: [UIFont
                                                                   systemFontOfSize:kNavBarFontSize]
                                             }];
        return label;
    } else {
        label = [[UILabel alloc] init];
    }
	UIColor *color;
	if (component == kTimeGreen) {
		color = kPickerViewMinColumnColor;
	} else if (component == kTimeRed) {
		color = kPickerViewMaxColumnColor;
	} else {
		color = [UIColor blackColor];
	}
	
	NSDictionary *attr = @{
                           NSForegroundColorAttributeName: kPickerViewTextColor,
                           NSFontAttributeName: [UIFont systemFontOfSize:kNavBarFontSize]
                           };
	
	label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attr];
	[label setBackgroundColor:color];
	[label setTextAlignment:NSTextAlignmentCenter];
	return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
	
	NSInteger greenVal = 0;
	NSInteger redVal =0;
	if (component == kTimeGreen) {
		greenVal = label.text.integerValue;
		redVal = _maxTime.integerValue;
		if (greenVal >= redVal) {
			redVal = greenVal + 1;
		}
	} else if (component == kTimeRed) {
		greenVal = _minTime.integerValue;
		redVal = label.text.integerValue;
		if (greenVal >= redVal) {
			greenVal = redVal - 1;
		}
	}
	[self updateMin:@(greenVal) max:@(redVal)];
}

#pragma mark - start and stop

- (IBAction)tappedStartStopButton:(id)sender {
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
	if ([self.navigationItem.rightBarButtonItem.title isEqualToString:kStop]) { //end timer
        self.canUpdate = NO;
		[self setEndDate:[NSDate date]];
		
		NSTimeInterval interval = [_endDate timeIntervalSinceDate:_startDate];
		_totalTime = [self stringFromTimeInterval:interval];
		[self FSM_idle];
	} else { //start timer
        self.canUpdate = YES;
		[self FSM_startTimer];
	}
}

- (void)updates:(NSTimer *)aTimer {
    if(self.canUpdate) {
        [self updateBackground];
        [self updateTime];
        [self disableOnTheFlyEditingOnTimesUp];
    } else {
        [aTimer invalidate];
        [self.nameTextField setAlpha:1];
        [self.timeChooserParentView setAlpha:1];
    }
}

/**
 Updates the bdColor property of the Model
 */
- (void)updateBackground {
    NSTimeInterval total = [[NSDate new] timeIntervalSinceDate:_startDate];
    UIColor *bgColor = [[DHColorForTime shared] colorForSeconds:total
                                                            min:_minTime.integerValue
                                                            max:_maxTime.integerValue];
    [self.view setBackgroundColor:bgColor];
}

/**
 Updates the TotalTime property of the model
 */
- (void)updateTime {
	NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:_startDate];
	[self setTotalTime:[self stringFromTimeInterval:interval]];
    
    BOOL titleIsVisible = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultShowRunningTimer] boolValue];
    if (titleIsVisible) {
        [[self navItem] setTitle:_totalTime];
    } else {
        [[self navItem] setTitle:@""];
    }
    
}

/**
 Converts a timeinterval into hours:minutes:seconds
 */
- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
	NSInteger ti = (NSInteger)interval;
	NSInteger seconds = ti % 60;
	NSInteger minutes = (ti / 60) % 60;
	NSInteger hours = (ti / 3600);
	return [NSString stringWithFormat:@"%02d:%02d.%02d", (int)hours, (int)minutes, (int)seconds];
}

/**
 A combination of two actions.  Stopping the timer and pressing back button of the navigationBar
 */
- (void)quickStop:(id)sender {
	[self tappedStartStopButton:sender];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Finite State Machine

- (IBAction)tappedOnceWithOneFinger:(id)sender {
	[self FSM_editingOnTheFly];
}

- (IBAction)tappedTwiceWithTwoFingers:(id)sender {
	[self quickStop:sender];
}

- (IBAction)swipedRight:(id)sender {
	[self quickStop:sender];
}

- (void)FSM_idle {
	[self enableNavItemButtons:YES];
	[self.nameTextField setHidden:NO];
	[self.timeChooserParentView setHidden:NO];
	[UIView animateWithDuration:0.5 animations:^{//TODO: consider removing the animations
		[self.view setBackgroundColor:[UIColor whiteColor]]; //reset to default color
		[self.nameTextField setAlpha:1];
        [self.timeChooserParentView setAlpha:1];
	}];
	[self.navigationItem setHidesBackButton:NO];
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO]; //toggle sleep
	[self.tapGesture2f2t setEnabled:NO]; //toggle double 2 finger tap
	[self.tapGesture1f1t setEnabled:NO];
    [self.swipeGesture setEnabled:NO];
	[self.navigationItem.rightBarButtonItem setTitle:kStart];
	[self.navItem setTitle:_totalTime];
}

- (void)FSM_startTimer {
    self.navigationItem.title = kDelayTitle;
    [self enableNavItemButtons:NO];
    [self FSM_runTimerWithAnimations:NO];
    [[self swipeGesture] setEnabled:NO];
    [[self tapGesture1f1t] setEnabled:NO];
    [[self tapGesture2f2t] setEnabled:NO];
    
    BOOL delayIsEnabled = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefault3SecondDelay] boolValue];
    
    if (delayIsEnabled) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        
        self.countDownView = [[DHCountDownView alloc] initWithFrame:rect
                                                           delegate:self
                                                     characterDelay:1.0
                                      stringOfCharactersToCountDown:@" 321"
                                                 completedCountDown:^{
                                                      [self FSM_startTimerBegin];
                                                     [[self countDownView] removeFromSuperview];
                                                 }];
        [[self view] addSubview:self.countDownView];
        [[self countDownView] runCountDown:delayIsEnabled];
        
    } else {
        [self FSM_startTimerBegin];
    }
}

- (void)FSM_startTimerBegin {
    [self enableNavItemButtons:YES];
    [self setStartDate:[NSDate date]];
    [self setEndDate:nil];
    [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updates:) userInfo:nil repeats:YES] fire];
    [[self swipeGesture] setEnabled:YES];
    [[self tapGesture1f1t] setEnabled:YES];
    [[self tapGesture2f2t] setEnabled:YES];
}

- (void)FSM_runTimerWithAnimations:(BOOL)b {
	[UIView animateWithDuration:b?0.5:0 animations:^{//TODO: consider removing animations
		[self.nameTextField setAlpha:0];
		[self.timeChooserParentView setAlpha:0];
	} completion:^(BOOL finished) {
		[self.nameTextField setHidden:YES];
		[self.nameTextField resignFirstResponder];
		[self.timeChooserParentView setHidden:YES];
	}];
	[self.navigationItem setHidesBackButton:YES];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //toggle sleep
	[self.tapGesture2f2t setEnabled:YES]; //toggle double 2 finger tap
	[self.tapGesture1f1t setEnabled:YES];
    [self.swipeGesture setEnabled:YES];
	[self.navigationItem.rightBarButtonItem setTitle:kStop];
}

- (void)FSM_editingOnTheFly {
    [self setIsOnTheFlyEditing:YES];
	[self.timeChooserParentView setAlpha:1];
	[self.timeChooserParentView setHidden:NO];
	[self.nameTextField setHidden:NO];
	[self.nameTextField setAlpha:1];
}

#pragma mark - On the fly edit

/**
Gets called on:
 1) tap view                  - (7.1/2x)   - (6.1/2x)
 2) start edit text field     - (7.1/82x)  - (6.1/11x)
 3) typing keys in text field - (7.1/13 per letter) - (6.1/1 per letter)
 4) scrolling pin wheel       - (7.1/256x) - ()
 5) pressing preset buttons   - (7.1/2x)   - ()
 6) starting timer            - (7.1/2x)   - ()
 7) master segue to detail    - (7.1/17x)  - (6.1/6x)
 8) detail segue to master    - (7.1/138x) - (6.1/2x)
 */
- (UIResponder *)nextResponder {
#if DEBUG
    NSLog(@"next responder was called");
#endif
    if(self.isOnTheFlyEditing) {
        [self setSecondsUntilOnTheFlyEditingEnds:kOnTheFlyEditingTimeOUt];
    }
	return [super nextResponder];
}

- (void)disableOnTheFlyEditingOnTimesUp {
    if (self.secondsUntilOnTheFlyEditingEnds) {
        _secondsUntilOnTheFlyEditingEnds--;
    } else {
        [self FSM_runTimerWithAnimations:YES];
        [self setIsOnTheFlyEditing:NO];
    }
}


#pragma mark - Textfield Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.nameTextField resignFirstResponder];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self enableNavItemButtons:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	_name = self.nameTextField.text;
	[self enableNavItemButtons:YES];
}

/**
 enables or disables the navigation buttons
 @param b if yes, the left and right buttons are enabled.  otherwise they are disabled
 
 */
- (void)enableNavItemButtons:(BOOL)b {//TODO: consider removing the uiview animations
	static const float kSec0_5 = 0.5;
	static const float kSec0_25 = 0.25;
	static const float kMiddleAlpha = 0.5;
	UINavigationBar *navBar = self.navigationController.navigationBar;
	
	[navBar setUserInteractionEnabled:b];
	if (!b) {
		[UIView animateWithDuration:kSec0_5 animations:^{
			//[self.presetTimesSegment setAlpha:b];
			//[self.pickerView setAlpha:b];
			[navBar setAlpha:kMiddleAlpha];
		}];
	} else {
		[UIView animateWithDuration:kSec0_25 animations:^{
			[navBar setAlpha:b];
			//[self.pickerView setAlpha:b];
			//[self.presetTimesSegment setAlpha:b];
		}];
	}
}

#pragma mark - preset Buttons

- (IBAction)tappedSegmentedPresetButton:(UISegmentedControl *)sender {
    NSNumber *min;
    NSNumber *max;
    [sender valuesOfTappedSegmentedControlMinValue:&min maxValue:&max];
    [self updateMin:min max:max];
}

/**
 Sets the picker view to the right places, then updates the context
 */
- (void)updateMin:(NSNumber *)min max:(NSNumber *)max {
#if DEBUG
	NSLog(@"%@   %@", min, max);
#endif
    
	[[self pickerView] selectRow:min.integerValue inComponent:kTimeGreen animated:YES];
	[[self pickerView] selectRow:max.integerValue-kPickerViewRedReelOffset inComponent:kTimeRed animated:YES];
	
	[self setMinTime:min];
	[self setMaxTime:max];
	
	[[NSUserDefaults standardUserDefaults] setObject:min forKey:kUserDefaultMinTime];
	[[NSUserDefaults standardUserDefaults] setObject:max forKey:kUserDefaultMaxTime];
	
	if (self.isOnTheFlyEditing) {
		[self setSecondsUntilOnTheFlyEditingEnds:kOnTheFlyEditingTimeOUt];
	}
}

#pragma mark - iAd's delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
#if DEBUG
    NSLog(@"timmerview banner 1");
#endif
	[banner setHidden:NO];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    if ([[[UIDevice currentDevice] systemVersion] intValue] < 7) { return NO;}
    
    //Stop timer
	_canUpdate = NO;
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
	//resume timer
    _canUpdate = YES;
    [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updates:) userInfo:nil repeats:YES] fire];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
#if DEBUG
    NSLog(@"timerview banner 0");
#endif
	[banner setHidden:YES];
}


#pragma mark - prepareforseque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.canUpdate = NO;
}

@end
