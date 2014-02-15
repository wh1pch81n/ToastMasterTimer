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
    kTimeGreen,
    kTimeRed,
    kNumElementsInTimeEnum
};

@interface DHDetailViewController () {
    float timeColorArr[2];
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSTimer *timer;

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
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    //Default values
    timeColorArr[kTimeGreen] = self.detailItem.minTime.floatValue;
    timeColorArr[kTimeRed] = self.detailItem.maxTime.floatValue;
    
    [[self pickerView] selectRow:timeColorArr[kTimeGreen] inComponent:kTimeGreen animated:YES];
    [[self pickerView] selectRow:timeColorArr[kTimeRed] inComponent:kTimeRed animated:YES];
    
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
    return 10; //pick a number from 0 to 9
}

#pragma mark - picker delegate

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.frame.size.width/3 -10;
}

//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
//    return pickerView.frame.size.height;
//}

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *options = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    return options[row];
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    NSArray *options = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    UILabel *label = [[UILabel alloc] init];
    UIColor *color;
    if (component == 0) {
        color = [UIColor greenColor];
    } else if (component == 1) {
        color = [UIColor redColor];
    } else {
        color = [UIColor blackColor];
    }
    label.attributedText = [[NSAttributedString alloc] initWithString:options[row] attributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    [label setBackgroundColor:color];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
    timeColorArr[component] = label.text.floatValue;
    
    [self.detailItem setMinTime:@(timeColorArr[kTimeGreen])];
    [self.detailItem setMaxTime:@(timeColorArr[kTimeRed])];
    
    NSError *err;
    if (![self.context save:&err]) {
        NSLog(@"Can't save!");
        abort();
    }
}

#pragma mark - start and stop

- (IBAction)tappedStartStopButton:(id)sender {
    static BOOL tempBool = NO;
    if (!(tempBool = !tempBool)) { //end timer
        [self.nameTextField setHidden:NO];
        [self.pickerView setHidden:NO];
        [[self detailItem] setEndDate:[NSDate date]];
        
        [self.timer invalidate];
        [self.navigationItem setHidesBackButton:NO];
        [self.navigationItem.rightBarButtonItem setTitle:@"Restart"];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.detailItem.startDate];
        self.detailItem.totalTime = [self stringFromTimeInterval:interval];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];// re-enable sleep
    } else { //start timer
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //prevent sleep when running
        [self.nameTextField setHidden:YES];
        [self.pickerView setHidden:YES];
        [self.navigationItem setHidesBackButton:YES];
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
    NSInteger minutes = (interval / 60);
    
    UIColor *color;
    if(minutes < timeColorArr[kTimeGreen])
        color = [UIColor blackColor];
    else if (minutes < ((timeColorArr[kTimeGreen] + timeColorArr[kTimeRed])/2.0))
        color = [UIColor greenColor];
    else if (minutes < timeColorArr[kTimeRed])
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

@end
