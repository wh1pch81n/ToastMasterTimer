//
//  DHDetailViewController.m
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHDetailViewController.h"
#import "Event.h"

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

@interface DHDetailViewController ()

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UIButton *timer1_2;
@property (weak, nonatomic) IBOutlet UIButton *timer2_3;
@property (weak, nonatomic) IBOutlet UIButton *timer3_4;
@property (weak, nonatomic) IBOutlet UIButton *timer4_6;
@property (weak, nonatomic) IBOutlet UIButton *timer5_7;
@property (weak, nonatomic) IBOutlet UIButton *timer8_10;

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
        [self.navigationItem setTitle:self.detailItem.totalTime];
        [self.tapGesture setEnabled:NO];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    //Default values
    [self updateMin:@(self.detailItem.minTime.floatValue) max:@(self.detailItem.maxTime.floatValue)];
}

- (void)didReceiveMemoryWarning
{
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
    return 59; //pick a number from 0 to 9
}

#pragma mark - picker delegate

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.frame.size.width/3 -10;
}

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", row];
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    NSString *text = [NSString stringWithFormat:@"%d", row];
    UILabel *label = [[UILabel alloc] init];
    UIColor *color;
    if (component == 0) {
        color = [UIColor greenColor];
    } else if (component == 1) {
        color = [UIColor redColor];
    } else {
        color = [UIColor blackColor];
    }
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [label setBackgroundColor:color];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
    
    if (component == kTimeGreen) {
        [self updateMin:@(label.text.integerValue) max:self.detailItem.maxTime];
    } else if (component == kTimeRed) {
        [self updateMin:self.detailItem.minTime max:@(label.text.integerValue)];
    }
}

#pragma mark - start and stop

/**
 Formates the ui for set up  or for running the timer.
 @param b if this is YES it will hide most things.  If No it will show all the set up gear
 */
- (void)formatForRunningTimer:(BOOL)b {
    [self.nameTextField setHidden:b];
    [self.pickerView setHidden:b];
    [self.navigationItem setHidesBackButton:b];
    [[UIApplication sharedApplication] setIdleTimerDisabled:b]; //toggle sleep
    [self.tapGesture setEnabled:b]; //toggle double 2 finger tap
    
    [self.timer1_2 setHidden:b];
    [self.timer2_3 setHidden:b];
    [self.timer3_4 setHidden:b];
    [self.timer4_6 setHidden:b];
    [self.timer5_7 setHidden:b];
    [self.timer8_10 setHidden:b];
}

- (IBAction)tappedStartStopButton:(id)sender {
    static BOOL tempBool = NO;
    if (!(tempBool = !tempBool)) { //end timer
        [self formatForRunningTimer:NO];
        
        [[self detailItem] setEndDate:[NSDate date]];
        [self.timer invalidate];
        [self.navigationItem.rightBarButtonItem setTitle:@"Start"];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.detailItem.startDate];
        self.detailItem.totalTime = [self stringFromTimeInterval:interval];
    } else { //start timer
        [self formatForRunningTimer:YES];
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Stop"];
        NSDate *date = [NSDate date];
        [[self detailItem] setStartDate:date];
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updates) userInfo:nil repeats:YES]];
        [self.timer fire];
    }
    
    NSError *err = nil;
    if(![self.context save:&err]) {
        NSLog(@"Could not save");
        abort();
    }
}

- (void)updates {
    [self updateTime];
    [self updateBackground];
}

- (void)updateBackground {
    NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.detailItem.startDate];
    float minutes = (interval / 60.0);
    
    NSInteger min = self.detailItem.minTime.integerValue;
    NSInteger max = self.detailItem.maxTime.integerValue;
    
    UIColor *color;
    if(minutes < min)
        color = [UIColor blackColor];
    else if (minutes < ((min + max)/2.0))
        color = [UIColor greenColor];
    else if (minutes < max)
        color = [UIColor yellowColor];
    else
        color = [UIColor redColor];
    
    [self.view setBackgroundColor:color];
}

- (void)updateTime {
    NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.detailItem.startDate];
    [self.navigationItem setTitle:[self stringFromTimeInterval:interval]];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02d:%02d.%02d", hours, minutes, seconds];
}

#pragma mark - Textfield Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameTextField resignFirstResponder];
    self.detailItem.name = self.nameTextField.text;
    NSError *err;
    if (![self.context save:&err]) {
        NSLog(@"Could not save");
        abort();
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

#pragma mark - preset Buttons

- (IBAction)tappedPresetButton:(id)sender {
    int min, max;
    switch ([sender tag]) {
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
        case kPresetButton8_10:
            min = 8;
            max = 10;
            break;
        default:
            return;
            break;
    }
    
    [self updateMin:@(min) max:@(max)];
}

/**
 Sets the picker view to the right places, then updates the context
 */
- (void)updateMin:(NSNumber *)min max:(NSNumber *)max {
    [[self pickerView] selectRow:min.integerValue inComponent:kTimeGreen animated:YES];
    [[self pickerView] selectRow:max.integerValue inComponent:kTimeRed animated:YES];
    
    [[self detailItem] setMinTime:min];
    [[self detailItem] setMaxTime:max];
    
    NSError *err;
    if (![self.context save:&err]) {
        NSLog(@"Can't save!");
        abort();
    }
}

@end
