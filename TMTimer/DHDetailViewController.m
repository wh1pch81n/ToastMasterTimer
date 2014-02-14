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
    kTimeYellow,
    kTimeRed
};

@interface DHDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *timeReading;
@property float timeGreen, timeYellow, timeRed;
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
        self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    //Default values
    self.timeGreen = 4;
    self.timeRed = 6;
    self.timeYellow = (self.timeGreen + self.timeRed)/2;
    
    [[self pickerView] selectRow:self.timeGreen inComponent:0 animated:YES];
    [[self pickerView] selectRow:self.timeYellow inComponent:1 animated:YES];
    [[self pickerView] selectRow:self.timeRed inComponent:2 animated:YES];
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
    return 3; //three columns for green, yellow, then red card
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
        color = [UIColor yellowColor];
    } else if (component == 2) {
        color = [UIColor redColor];
    } else {
        color = [UIColor blackColor];
    }
    label.attributedText = [[NSAttributedString alloc] initWithString:options[row] attributes:@{NSForegroundColorAttributeName:color}];
    [label setBackgroundColor:[UIColor blueColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
//    switch (component) {
//        case kTimeGreen:
//            self.timeGreen = label.text.floatValue;
//            break;
//        case kTimeYellow:
//            self.timeYellow = label.text.floatValue;
//            break;
//        case kTimeRed:
//            self.timeRed = label.text.floatValue;
//            break;
//            
//    }

    float dummy;
    
    ((component == kTimeGreen)? self.timeGreen:
    (component == kTimeYellow)? self.timeYellow:
    (component == kTimeRed)? self.timeRed:
    dummy)
    = label.text.floatValue;
    
    NSLog(@"%@", [pickerView viewForRow:row forComponent:component]);
}

#pragma mark - start and stop

- (IBAction)tappedStartStopButton:(id)sender {
    static BOOL tempBool = 0;
    if (tempBool) {
        [[self detailItem] setEndDate:[NSDate date]];
        
        [self.timer invalidate];
    } else {
        NSDate *date = [NSDate date];
        [[self detailItem] setStartDate:date];
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updates) userInfo:nil repeats:YES]];
        [self.timer fire];
    }
    tempBool = !tempBool;
    NSError *err = nil;
    if(![self.context save:&err]) {
        NSLog(@"Could not save");
        abort();
    }
    
    NSDate *start = self.detailItem.startDate;
    NSDate *end = self.detailItem.endDate;
    NSTimeInterval sec = [end timeIntervalSinceDate:start];
    
    NSLog(@"\n%@\n%@\n%@\n", start, end, [NSString stringWithFormat:@"%f", sec]);
}

- (void)updates {
    [self updateTime];
    [self updateBackground];
}

- (void)updateBackground {
    NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.detailItem.startDate];
    NSInteger minutes = (interval / 60);
    
    UIColor *color;
    if(minutes < self.timeGreen)
        color = [UIColor blackColor];
    else if (minutes < self.timeYellow)
        color = [UIColor greenColor];
    else if (minutes < self.timeRed)
        color = [UIColor yellowColor];
    else
        color = [UIColor redColor];
    
    [self.view setBackgroundColor:color];
}

- (void)updateTime {
    NSTimeInterval interval = [[NSDate new] timeIntervalSinceDate:self.detailItem.startDate];
    [self.timeReading setText:[self stringFromTimeInterval:interval]];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02i:%02i.%02i", hours, minutes, seconds];
}

@end
