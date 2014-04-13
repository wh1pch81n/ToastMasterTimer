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

NSString *const kDelayTitle = @"3-2-1 Delay";

@interface DHDetailViewController ()
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture2f2t;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture1f1t;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGesture;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *timeout;
@property (weak, nonatomic) IBOutlet UISegmentedControl *presetTimesSegment;
@property (weak, nonatomic) IBOutlet UIView *timeChooserParentView;

@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet DHNavigationItem *navItem;
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
		self.nameTextField.text = self.detailItem.name;
		
		BOOL titleIsVisible = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultShowRunningTimer] boolValue];
		if (titleIsVisible) {
			[[self navItem] setTitle:self.detailItem.totalTime];
		} else {
			[[self navItem] setTitle:@""];
		}
		
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self configureView];
	[self FSM_idle];
	
	//Default values
	[self updateMin:@(self.detailItem.minTime.floatValue) max:@(self.detailItem.maxTime.floatValue)];
	
	//enable KVO
	[[self detailItem] addObserver:self forKeyPath:kTotalTime options:NSKeyValueObservingOptionNew context:nil];
	[[self detailItem] addObserver:self forKeyPath:kbgColor options:NSKeyValueObservingOptionNew context:nil];
	
	//enable adds
	float version = [[UIDevice currentDevice] systemVersion].floatValue;
	if (version >= 7) {
		[self canDisplayBannerAds];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	//disable KVO
	[[self detailItem] removeObserver:self forKeyPath:kTotalTime context:nil];
	//[[self detailItem] removeObserver:self forKeyPath:kbgColor context:nil];
	
  //[[self detailItem] setBgColorDataWithColor:[self realignBackgroundWithMinAndMax]];
	
	//Save context before leaving
	DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate saveContext];
	
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - KVO delegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	Event *event = (Event *)object;
	
	if ([keyPath isEqualToString:kTotalTime]) {
		BOOL titleIsVisible = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultShowRunningTimer] boolValue];
		if (titleIsVisible) {
			[[self navItem] setTitle:event.totalTime];
		} else {
			[[self navItem] setTitle:@""];
		}
        NSTimeInterval total = [event.endDate timeIntervalSinceDate:event.startDate];
        UIColor *bgColor = [[DHColorForTime shared] colorForSeconds:total
                                                                min:event.minTime.integerValue
                                                                max:event.maxTime.integerValue];
        [self.view setBackgroundColor:bgColor];
	}
    //else if ([keyPath isEqualToString:kbgColor]) {
	//	[self.view setBackgroundColor:event.bgColorFromData];
	//}
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
	UILabel *label = [[UILabel alloc] init];
	UIColor *color;
	if (component == kTimeGreen) {
		color = kPickerViewMinColumnColor;
	} else if (component == kTimeRed) {
		color = kPickerViewMaxColumnColor;
	} else {
		color = [UIColor blackColor];
	}
	
	NSDictionary *attr = @{
												 //NSStrokeWidthAttributeName: @(kPickerViewTextOutlineSize),
												 //NSStrokeColorAttributeName: kPickerViewTextOutlineColor,
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
		redVal = self.detailItem.maxTime.integerValue;
		if (greenVal >= redVal) {
			redVal = greenVal + 1;
		}
	} else if (component == kTimeRed) {
		greenVal = self.detailItem.minTime.integerValue;
		redVal = label.text.integerValue;
		if (greenVal >= redVal) {
			greenVal = redVal - 1;
		}
	}
	[self updateMin:@(greenVal) max:@(redVal)];
}

#pragma mark - start and stop

- (IBAction)tappedStartStopButton:(id)sender {
	if ([self.navigationItem.rightBarButtonItem.title isEqualToString:kStop]) { //end timer
		[[self detailItem] setEndDate:[NSDate date]];
		
		NSTimeInterval interval = [self.detailItem.endDate timeIntervalSinceDate:self.detailItem.startDate];
		self.detailItem.totalTime = [self stringFromTimeInterval:interval];
		[self FSM_idle];
	} else { //start timer
		[self FSM_startTimer];
	}
}

- (void)updates {
	[self updateBackground];
	[self updateTime];
}

/**
 Updates the bdColor property of the Model
 */
- (void)updateBackground {
	[self realignBackgroundWithMinAndMax];
}

/**
 Updates the TotalTime property of the model
 */
- (void)updateTime {
	NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.detailItem.startDate];
	[self.detailItem setTotalTime:[self stringFromTimeInterval:interval]];
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
	[self FSM_idle];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Finite State Machine

- (IBAction)tappedOnceWithOneFinger:(id)sender {
	[self invalidateTimeOutTimerThenSetItWithNewlyCreatedOne];
	[self FSM_editingOnTheFly];
}

- (IBAction)tappedTwiceWithTwoFingers:(id)sender {
	[self quickStop:sender];
}

- (IBAction)swipedRight:(id)sender {
	[self quickStop:sender];
}

- (void)FSM_idle {
	[self.timer invalidate];
	self.timer = nil;
	
	[self.timeout invalidate];
	self.timeout = nil;
	
	[self.bannerView setHidden:YES];
	[self enableNavItemButtons:YES];
	[self.nameTextField setHidden:NO];
	[self.timeChooserParentView setHidden:NO];
	[UIView animateWithDuration:0.5 animations:^{
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
	[self.navItem setTitle:self.detailItem.totalTime];
}

- (void)FSM_startTimer {
    self.navigationItem.title = kDelayTitle;
    [self enableNavItemButtons:NO];
    
    BOOL delayIsEnabled = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefault3SecondDelay] boolValue];

    CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    DHCountDownView *countDownView = [[DHCountDownView alloc] initWithFrame:rect];
    [self.view addSubview:countDownView];
    countDownView.delegate = self;
    [countDownView runCountDown:delayIsEnabled ThenDoThisWhenComplete:^{
       [self FSM_runTimerWithAnimations:NO];
        [self enableNavItemButtons:YES];
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updates) userInfo:nil repeats:YES]];
        [[self detailItem] setStartDate:[NSDate date]];
        [[self detailItem] setEndDate:nil];
        [self.timer fire];
        [countDownView removeFromSuperview];
    }];
}

- (void)FSM_runTimerWithAnimations:(BOOL)b {
	[UIView animateWithDuration:b?0.5:0 animations:^{
		[self.nameTextField setAlpha:0];
		[self.timeChooserParentView setAlpha:0];
	} completion:^(BOOL finished) {
		[self.nameTextField setHidden:YES];
		[self.nameTextField resignFirstResponder];
		[self.timeChooserParentView setHidden:YES];
		[self.bannerView setHidden:NO];
	}];
	[self.navigationItem setHidesBackButton:YES];
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //toggle sleep
	[self.tapGesture2f2t setEnabled:YES]; //toggle double 2 finger tap
	[self.tapGesture1f1t setEnabled:YES];
    [self.swipeGesture setEnabled:YES];
	[self.navigationItem.rightBarButtonItem setTitle:kStop];
}

- (void)FSM_editingOnTheFly {
	[self.bannerView setHidden:YES];
	[self.timeChooserParentView setAlpha:1];
	[self.timeChooserParentView setHidden:NO];
	[self.nameTextField setHidden:NO];
	[self.nameTextField setAlpha:1];
}

#pragma mark - timers

/**
 Called whenever interaction is detected.
 Not used when pickerview is being pressed.
 Not used when presettimesSegment Buttons are pressed
 Called for events that end up being recieved by the viewcontroller
 */
- (UIResponder *)nextResponder {
	if (self.timeout != nil) {
		[self invalidateTimeOutTimerThenSetItWithNewlyCreatedOne];
	}
	return [super nextResponder];
}

- (NSTimer *)createTimeOutTimer {
	const NSTimeInterval kTimeOutInterval = 5.0;
	return [NSTimer scheduledTimerWithTimeInterval:kTimeOutInterval target:self selector:@selector(exceededTimeOut) userInfo:nil repeats:NO];
}

/**
 invalidates the timeout then goes to the runTimer State
 */
- (void)exceededTimeOut {
	[self.timeout invalidate];
	self.timeout = nil;
	[self FSM_runTimerWithAnimations:YES];
}

/**
 invalidates the currect timeout timer.  Sets it to point to a new one.
 It will fire on its own after a certain time interval as passed.
 */
- (void)invalidateTimeOutTimerThenSetItWithNewlyCreatedOne {
	[[self timeout] invalidate];
	[self setTimeout:[self createTimeOutTimer]];
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
	self.detailItem.name = self.nameTextField.text;
	[self enableNavItemButtons:YES];
}

/**
 enables or disables the navigation buttons
 @param b if yes, the left and right buttons are enabled.  otherwise they are disabled
 
 */
- (void)enableNavItemButtons:(BOOL)b {
	static const float kSec0_5 = 0.5;
	static const float kSec0_25 = 0.25;
	static const float kMiddleAlpha = 0.5;
	UINavigationBar *navBar = self.navigationController.navigationBar;
	
	[navBar setUserInteractionEnabled:b];
	if (!b) {
		[UIView animateWithDuration:kSec0_5 animations:^{
			[self.presetTimesSegment setAlpha:b];
			[self.pickerView setAlpha:b];
			[navBar setAlpha:kMiddleAlpha];
		}];
	} else {
		[UIView animateWithDuration:kSec0_25 animations:^{
			[navBar setAlpha:b];
			[self.pickerView setAlpha:b];
			[self.presetTimesSegment setAlpha:b];
		}];
	}
}

#pragma mark - preset Buttons

- (IBAction)tappedSegmentedPresetButton:(UISegmentedControl *)sender {
    NSString *str = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    NSArray *arr = [str componentsSeparatedByString:@"~"];
	int min, max;
    min = [[arr firstObject] intValue];
    max = [[arr lastObject] intValue];
/*	switch ([sender selectedSegmentIndex]+1) {
		case kPresetButton1_2:
			min = 1;
			max = 2;
			break;
		case kPresetButton2_3:
			min = 2;
			max = 3;
			break;
		case kPresetButton3_4:
			min = 3;
			max = 4;
			break;
		case kPresetButton4_6:
			min = 4;
			max = 6;
			break;
		case kPresetButton5_7:
			min = 5;
			max = 7;
			break;
		case kdummy6:
		case kdummy7:
		case kPresetButton8_10:
			min = 8;
			max = 10;
			break;
		default:
			return;
			break;
	}
	*/
	[self updateMin:@(min) max:@(max)];
}

/**
 Sets the picker view to the right places, then updates the context
 */
- (void)updateMin:(NSNumber *)min max:(NSNumber *)max {
	NSLog(@"%@   %@", min, max);
	[[self pickerView] selectRow:min.integerValue inComponent:kTimeGreen animated:YES];
	[[self pickerView] selectRow:max.integerValue-kPickerViewRedReelOffset inComponent:kTimeRed animated:YES];
	
	[[self detailItem] setMinTime:min];
	[[self detailItem] setMaxTime:max];
	
	[[NSUserDefaults standardUserDefaults] setObject:min forKey:kUserDefaultMinTime];
	[[NSUserDefaults standardUserDefaults] setObject:max forKey:kUserDefaultMaxTime];
	
	if (self.timeout != nil) {
		[self invalidateTimeOutTimerThenSetItWithNewlyCreatedOne];
	}
}

/**
 Updates the model to have the correct color given the min and max values.
 Can be inefficient if called many times, back to back.
 
 @returns the color that was used to set the bg property
 */
- (UIColor *)realignBackgroundWithMinAndMax {
	Event *detail = self.detailItem;
	NSTimeInterval interval;
	if (detail.endDate != nil)
		interval = [detail.endDate timeIntervalSinceDate:detail.startDate];
	else
		interval = [[NSDate new] timeIntervalSinceDate:detail.startDate];
	
	NSInteger seconds = interval;
	
	static const int k60Seconds = 60;
	NSInteger min = self.detailItem.minTime.integerValue *k60Seconds;
	NSInteger max = self.detailItem.maxTime.integerValue *k60Seconds;
	
	UIColor *color = [[DHColorForTime shared] colorForSeconds:seconds min:min max:max];
		
	return color;
}

#pragma mark - iAd's delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	NSLog(@"timmerview banner 1");
	[banner setAlpha:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	//Stop timer
	//return YES;
	return NO;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
	//resume timer
	
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	NSLog(@"timerview banner 0");
	[banner setAlpha:NO];
}

#pragma mark - Count down Delegate

- (float)characterDelay {
	return 1.0;
}

- (NSString *)stringOfCharactersToCountDown {
	return @"321";
}

@end
