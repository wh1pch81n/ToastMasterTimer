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
#import "User_Profile.h"
#import "User_Profile+helperMethods.h"
#import "DHGlobalConstants.h"
#import "DHAppDelegate.h"
#import "DHNavigationItem.h"
#import "DHColorForTime.h"
#import "UISegmentedControl+extractMinMaxData.h"
#import "DHUserProfileCollectionViewCell.h"
#import "DHUserProfileCollectionViewController.h"

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

@property (weak, nonatomic) IBOutlet UIView *extraButtonsView;

@property (strong, nonatomic) DHUserProfileCollectionViewController *userProfileCollectionViewController;

@property (weak, nonatomic) IBOutlet UIView *containerUP;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *buttonChooseName;

@property (weak, nonatomic) IBOutlet UILabel *labelTapToEdit;
@property (weak, nonatomic) IBOutlet UILabel *labelSwipeRightToStop;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture2f2t;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture1f1t;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGesture;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *presetTimesSegment;
@property (weak, nonatomic) IBOutlet UIView *timeChooserParentView;

@property (weak, nonatomic) IBOutlet DHNavigationItem *navItem;

@property (strong, nonatomic) DHCountDownView *countDownView;

@property BOOL canUpdate;

@property int secondsUntilOnTheFlyEditingEnds;
@property BOOL isOnTheFlyEditing;

//---
@property (strong, nonatomic) NSDate *endDate, *startDate;
@property (strong, nonatomic) NSNumber *minTime, *maxTime;
@property (strong, nonatomic) NSString *blurb, *totalTime;

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
		self.nameTextField.text = _blurb;
		
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
    _blurb = detail.blurb;
    _totalTime = detail.totalTime;
}

- (void)setDetailItemWithEndDate:(NSDate *)endDate
                       startDate:(NSDate *)startDate
                         maxTime:(NSNumber *)maxTime
                         minTime:(NSNumber *)minTime
                           blurb:(NSString *)blurb
                       totalTime:(NSString *)totalTime
{
    self.detailItem.endDate = endDate;
    self.detailItem.startDate = startDate;
    self.detailItem.maxTime = maxTime;
    self.detailItem.minTime = minTime;
    self.detailItem.blurb = blurb;
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
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self moveOutExtraButtonsView:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:kStop]) {//should stop the timer before leaving this view.
        [self tappedStartStopButton:self];
    }
    if ([self.nameTextField isFirstResponder]) {[self.nameTextField resignFirstResponder];}
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	//Save context before leaving
	[self setDetailItemWithEndDate:_endDate
                         startDate:_startDate
                           maxTime:_maxTime
                           minTime:_minTime
                              blurb:_blurb
                         totalTime:_totalTime];

	[super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
    [self enableNavItemButtons:NO];
	if ([self.navigationItem.rightBarButtonItem.title isEqualToString:kStop]) { //end timer
        self.canUpdate = NO;
		[self setEndDate:[NSDate date]];
		
		NSTimeInterval interval = [_endDate timeIntervalSinceDate:_startDate];
		_totalTime = [self stringFromTimeInterval:interval];
		[self FSM_idle];
        [self setDetailItemWithEndDate:_endDate
                             startDate:_startDate
                               maxTime:_maxTime
                               minTime:_minTime
                                 blurb:_blurb
                             totalTime:_totalTime];//set the MO then save to disk
	} else { //start timer
        self.canUpdate = YES;
        if (self.detailItem.startDate) {
            [self.navigationItem.rightBarButtonItem setTitle:@""];
            [self moveInExtraButtonsView:YES];
        } else {
            [self FSM_startTimer];
        }
	}
}

- (void)updates:(NSTimer *)aTimer {
    if(self.canUpdate) {
        NSTimeInterval timeInterval = [[NSDate new] timeIntervalSinceDate:_startDate];
        [self updateBackground:timeInterval];
        [self updateTime:timeInterval];
        [self updateVibrate:timeInterval];
        [self disableOnTheFlyEditingOnTimesUp];
    } else {
        [aTimer invalidate];
        [self.nameTextField setAlpha:1];
        [self.timeChooserParentView setAlpha:1];
    }
}

/**
 Vibrates when appropriate
 */
- (void)updateVibrate:(NSTimeInterval)timeInterval {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL canVibrate = [(NSNumber *)[ud objectForKey:kUserDefaultsVibrateOnFlagChange] boolValue];
    if (!canVibrate) {
        return;
    }
    int min = _minTime.intValue;
    int max = _maxTime.intValue;
    const int k60Seconds = 60;
#if DEBUG
#else
    min *= k60Seconds;
    max *= k60Seconds;
#endif
    if ((int)timeInterval == min ||
        (int)timeInterval == max ||
        (int)timeInterval == (int)((min+max)/2)){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

/**
 Updates the bdColor property of the Model
 */
- (void)updateBackground:(NSTimeInterval)timeInterval {
    NSTimeInterval total = timeInterval;
    UIColor *bgColor = [[DHColorForTime shared] colorForSeconds:total
                                                            min:_minTime.integerValue
                                                            max:_maxTime.integerValue];
    [self.originalContentView setBackgroundColor:bgColor];
}

/**
 Updates the TotalTime property of the model
 */
- (void)updateTime:(NSTimeInterval)timeInterval {
	NSTimeInterval interval = timeInterval;
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
    self.canDisplayBannerAds = NO;
	[self enableNavItemButtons:YES];
	[self.nameTextField setHidden:NO];
	[self.timeChooserParentView setHidden:NO];
    [self.collectionView setHidden:NO];
    [self.buttonChooseName setHidden:NO];
    __weak typeof(self)wSelf = self;
	[UIView animateWithDuration:0.5 animations:^{
        __strong typeof(wSelf)sSelf = wSelf;
		[sSelf.originalContentView setBackgroundColor:[UIColor whiteColor]]; //reset to default color
		[sSelf.nameTextField setAlpha:1];
        [sSelf.timeChooserParentView setAlpha:1];
        [sSelf.collectionView setAlpha:1];
        [sSelf.buttonChooseName setAlpha:1];
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
    [self.collectionView setAlpha:0];
    [self.collectionView setHidden:YES];
    [self.buttonChooseName setAlpha:0];
    [self.buttonChooseName setHidden:YES];
    [self FSM_runTimerWithAnimations:NO];
    [[self swipeGesture] setEnabled:NO];
    [[self tapGesture1f1t] setEnabled:NO];
    [[self tapGesture2f2t] setEnabled:NO];
    
    BOOL delayIsEnabled = [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefault3SecondDelay] boolValue];
    
    if (delayIsEnabled) {
        self.canDisplayBannerAds = NO;
        CGRect rect = CGRectMake(0, 0,
                                 CGRectGetWidth(self.originalContentView.frame),
                                 CGRectGetHeight(self.originalContentView.frame));
        
        __weak typeof(self)wSelf = self;
        self.countDownView = [[DHCountDownView alloc] initWithFrame:rect
                                                           delegate:self
                                                     characterDelay:1.0
                                      stringOfCharactersToCountDown:@" 321"
                                                 completedCountDown:^{
                                                     __strong typeof(wSelf)sSelf = wSelf;
                                                     sSelf.canDisplayBannerAds = YES;
                                                     [sSelf FSM_startTimerBegin];
                                                     [[sSelf countDownView] removeFromSuperview];
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
    __weak typeof(self)wSelf = self;
	[UIView animateWithDuration:b?0.5:0 animations:^{
        __strong typeof(wSelf)sSelf = wSelf;
		[sSelf.nameTextField setAlpha:0];
		[sSelf.timeChooserParentView setAlpha:0];
        [sSelf.collectionView setAlpha:0];
	} completion:^(BOOL finished) {
        __strong typeof(wSelf)sSelf = wSelf;
		[sSelf.nameTextField setHidden:YES];
		[sSelf.nameTextField resignFirstResponder];
		[sSelf.timeChooserParentView setHidden:YES];
        [sSelf.collectionView setHidden:YES];
	}];
	//[self.navigationItem setHidesBackButton:YES];
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
    //    [self.collectionView setHidden:NO]; //not sure why this remains unclickable
//    [self.collectionView setAlpha:1];
    
//    [self.containerUP setHidden:NO];
//    [self.containerUP setAlpha:1];
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
    self.canDisplayBannerAds = NO;
    [self tappedCancelButton:textField];
	[self enableNavItemButtons:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.navItem.rightBarButtonItem.title isEqualToString:kStop]) {
        self.canDisplayBannerAds = YES;
    }
	_blurb = self.nameTextField.text;
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
			[navBar setAlpha:kMiddleAlpha];
		}];
	} else {
		[UIView animateWithDuration:kSec0_25 animations:^{
			[navBar setAlpha:b];
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

#pragma mark - prepareforseque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.canUpdate = NO;
    [self FSM_idle];
    [self moveOutExtraButtonsView:NO];
    if (self.nameTextField.isFirstResponder){
        [self.nameTextField resignFirstResponder];
    }
    
#warning Also it seems that leaving the detail view will cause the timer to stop.  You should not segue, but insead put the view inside a sub view and present it above type able area
    if ([segue.identifier isEqualToString:@"selectAndCreateUP"]) {
        DHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *moc = appDelegate.managedObjectContext;
        DHUserProfileCollectionViewController *cvc = [segue destinationViewController];
        cvc.speechEvent = self.detailItem;
        [cvc setManagedObjectContext:moc];
        [cvc setCustomCellTapResponse:^(User_Profile *up, DHUserProfileCollectionViewController *upcvc) {
            [upcvc.navigationController popViewControllerAnimated:YES];
            self.detailItem.speeches_speaker = up;
            [self.collectionView reloadData];
        }];
    } else if ([segue.identifier isEqualToString:@"selectOrCreateNewSpeechesUP"]) {
        DHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *moc = appDelegate.managedObjectContext;
        DHUserProfileCollectionViewController *cvc = [segue destinationViewController];
        cvc.speechEvent = self.detailItem;
        [cvc setManagedObjectContext:moc];
        [cvc setCustomCellTapResponse:^(User_Profile *up, DHUserProfileCollectionViewController *vc) {
            [vc.navigationController popViewControllerAnimated:YES];
            self.detailItem.speeches_speaker = up;
            [self.collectionView reloadData];
            [self configureView];

            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kQuickStart];
        }];
    } else if ([segue.identifier isEqualToString:@"containerUP"]) {
        DHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *moc = appDelegate.managedObjectContext;
        DHUserProfileCollectionViewController *cvc = [segue destinationViewController];
        cvc.speechEvent = self.detailItem;
        [cvc setManagedObjectContext:moc];
        [cvc setCustomCellTapResponse:^(User_Profile *up, DHUserProfileCollectionViewController *upcvc) {
            self.containerUP.hidden = YES;
            self.containerUP.alpha = 0;
            self.detailItem.speeches_speaker = up;
            [self.collectionView reloadData];
            
        }];
    }
}

#pragma mark - uicollectionview delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.detailItem.speeches_speaker != nil;//since a speech may only have one speeker, hard code it to one for now
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DHUserProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    User_Profile *up = (User_Profile *)self.detailItem.speeches_speaker;
    cell.labelProfileName.text = up.user_name;
    cell.ImageProfilePic.image = [UIImage imageWithContentsOfFile:[up.profile_pic_path stringByAppendingPathExtension:@"thumbnail"]];
    
    return cell;
}

//doesn't seem to work when the timer is running.
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self.containerUP setHidden:NO];
//    [self.containerUP setAlpha:1];
//}

#pragma mark - Extra panel

/**
 called when Event duplication has been pressed.
 duplicates the Old event saving things like the user, the min max time, description, and giving a new nsdate of creation.
 the designated Event will be set as the newly created event
 */
- (IBAction)tappedDuplicateButton:(id)sender {
    [self setDetailItemWithEndDate:_endDate
                         startDate:_startDate
                           maxTime:_maxTime
                           minTime:_minTime
                             blurb:_blurb
                         totalTime:_totalTime];//set the MO then save to disk
    [self FSM_idle];
    [self moveOutExtraButtonsView:YES];
    NSManagedObjectContext *moc = [(DHAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    Event *ev = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                              inManagedObjectContext:moc];
    ev.timeStamp = [NSDate new];
    ev.minTime = _minTime;
    ev.maxTime = _maxTime;
    ev.blurb = _blurb;
    ev.speeches_speaker = self.detailItem.speeches_speaker;
    
    self.detailItem = ev;
    [self setLocalDetailPropertiesWithDetail:self.detailItem];
    
    [self configureView];
    [self FSM_startTimer];
}

/**
 called when the new button is pressed.
 It will create a brand new Event.
 designated Event will be set with the newly created event
 */
- (IBAction)tappedNewButton:(id)sender {
    [self setDetailItemWithEndDate:_endDate
                         startDate:_startDate
                           maxTime:_maxTime
                           minTime:_minTime
                             blurb:_blurb
                         totalTime:_totalTime];//set the MO then save to disk
    [self FSM_idle];
    [self moveOutExtraButtonsView:YES];
    NSManagedObjectContext *moc = [(DHAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    Event *ev = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                              inManagedObjectContext:moc];
    ev.timeStamp = [NSDate new];
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	[ev setMinTime:[UD objectForKey:kUserDefaultMinTime]];
	[ev setMaxTime:[UD objectForKey:kUserDefaultMaxTime]];
    
    self.detailItem = ev;
    [self setLocalDetailPropertiesWithDetail:ev];
    
    [self performSegueWithIdentifier:@"selectOrCreateNewSpeechesUP" sender:self];
}

/**
 Called when the overwrite button has been pressed.
 Does not change the designated Event.
 */
- (IBAction)tappedOverwriteButton:(id)sender {
    [self FSM_idle];
    [self moveOutExtraButtonsView:YES];
    [self FSM_startTimer];
}

/**
 Hides the extra buttons
 */
- (IBAction)tappedCancelButton:(id)sender {
    [self FSM_idle];
    [self moveOutExtraButtonsView:YES];
}

/**
 moves the extrabuttonsview to the visible part of the view
 */
- (void)moveInExtraButtonsView:(BOOL)animated {
    CGRect destinationFrame0 = CGRectMake(CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.extraButtonsView.frame) - 20, 0, CGRectGetWidth(self.extraButtonsView.frame), CGRectGetHeight(self.extraButtonsView.frame));
    CGRect destinationFrame1 = CGRectOffset(destinationFrame0, 20, 0);
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.extraButtonsView.frame = destinationFrame0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.extraButtonsView.frame = destinationFrame1;
            }];
        }];
    } else {
        self.extraButtonsView.frame = destinationFrame1;
    }
}

/**
 moves the extrabuttonsview off screen.
 */
- (void)moveOutExtraButtonsView:(BOOL)animated {
    CGRect destinationFrame = CGRectMake(CGRectGetWidth(self.view.frame), 0,
                                         CGRectGetWidth(self.extraButtonsView.frame),
                                         CGRectGetHeight(self.extraButtonsView.frame));
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            self.extraButtonsView.frame = destinationFrame;
        }];
    } else {
        self.extraButtonsView.frame = destinationFrame;
    }
}

@end
