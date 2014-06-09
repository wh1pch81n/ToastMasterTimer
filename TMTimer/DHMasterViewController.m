//
//  DHMasterViewController.m
//  TMTimer
//
//  Created by ryukkusakku on 2/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHMasterViewController.h"
#import "Event.h"
#import "DHDetailViewController.h"
#import "Event+helperMethods.h"
#import "DHTableViewCell.h"
#import "DHGlobalConstants.h"
#import "DHAppDelegate.h"
#import "DHError.h"
#import "DHColorForTime.h"
#import "UISegmentedControl+extractMinMaxData.h"

NSString *const kMasterViewControllerTitle = @"";
NSString *const kMore = @"More";
NSString *const kMoreViewSegue = @"MoreView";
NSString *const kTableTopics = @"Table Topics";

@interface DHMasterViewController ()

@property (strong, nonatomic) NSDictionary *customStartDict;
@property (assign) BOOL didUnwind;
@property (assign) BOOL didLoad;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation DHMasterViewController

- (void)awakeFromNib
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		self.clearsSelectionOnViewWillAppear = NO;
		self.preferredContentSize = CGSizeMake(320.0, 600.0);
	}
	[super awakeFromNib];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setTopVC:nil];
    
    [self setDidLoad:YES];
    
	UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithTitle:kMore style:UIBarButtonItemStyleBordered target:self action:@selector(moreView:)];
	
	self.navigationItem.leftBarButtonItem = moreButtonItem;
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (DHDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	
	[self.navigationItem setTitle:kMasterViewControllerTitle];
#if DEBUG
    NSLog(@"TMTimer view did load");
#endif
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.customStartDict) {
        [self beginCustomStartTopic];
    }
#if DEBUG
    NSLog(@"TMTimer view did appear");
#endif
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - bar button actions

/**
 launches a view that reveals extra options
 */
- (void)moreView:(id)sender {
#if DEBUG
    NSLog(@"Pressed more view button");
#endif
	[self performSegueWithIdentifier:kMoreViewSegue sender:sender];
}

- (void)insertNewObject:(id)sender
{
	NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
	Event *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	
	// If appropriate, configure the new managed object.
	// Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
	[newManagedObject setTimeStamp:[NSDate date]];
	//[newManagedObject setBgColorDataWithColor:[UIColor clearColor]]; //Default bg color
	
	//get default values
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	[newManagedObject setMinTime:[UD objectForKey:kUserDefaultMinTime]];
	[newManagedObject setMaxTime:[UD objectForKey:kUserDefaultMaxTime]];
  
	// Save the context.
	DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate saveContext];
}

#pragma mark - Table View

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *title = [[UILabel alloc] init];
    [title setBackgroundColor:[UIColor grayColor]];
    [title setMinimumScaleFactor:0.2];
    NSString *text;
    if (section == 0) {
        text = @"Quick Start Panel";
    } else {
        text =@"List of Speakers";
    }
    NSMutableParagraphStyle *para = [NSMutableParagraphStyle new];
    [para setAlignment:NSTextAlignmentCenter];
    
    [title setAttributedText:[[NSAttributedString alloc]
                              initWithString:text
                              attributes:@{
                                           NSParagraphStyleAttributeName: para,
                                           NSForegroundColorAttributeName: [UIColor lightTextColor],
                                           NSFontAttributeName: [UIFont systemFontOfSize:12]
                                           }]];
    return title;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) { //panel section
        return 1;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections].lastObject;
	return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 110;
    }
    return 87;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"quickStartPanel" forIndexPath:indexPath];
    }
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    	[self configureCell:cell atIndexPath:indexPath];
	}
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
    }
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        indexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
		[context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
		
		NSError *error = nil;
		if (![context save:&error]) {
			[DHError displayValidationError:error];		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	// The table view should not be re-orderable.
	return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
        return;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        indexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
		Event *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
		self.detailViewController.detailItem = object;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        indexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
		Event *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
		[[segue destinationViewController] setDetailItem:object];
		NSManagedObjectContext *context = [self managedObjectContext];
		[[segue destinationViewController] setContext:context];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	}
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
	NSArray *sortDescriptors = @[sortDescriptor];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		[DHError displayValidationError:error];
	}
	
	return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
            newIndexPath = [NSIndexPath indexPathForItem:newIndexPath.row inSection:1];
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
            indexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:1];
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
            indexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:1];
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
            indexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:1];
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            newIndexPath = [NSIndexPath indexPathForItem:newIndexPath.row inSection:1];
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	DHTableViewCell *dhCell = (DHTableViewCell *)cell;
    NSIndexPath *ip = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
	Event *object = [self.fetchedResultsController objectAtIndexPath:ip];
	
	//handle J.D.
	[[dhCell contestantName] setText:[object name]];
	if (object.name == Nil || [object.name isEqualToString:@""]) {
		[[dhCell contestantName] setText:kJohnDoe];
	}
	
    NSTimeInterval total = [object.endDate timeIntervalSinceDate:object.startDate];
    UIColor *bgColor = [[DHColorForTime shared] colorForSeconds:total
                                                            min:object.minTime.integerValue
                                                            max:object.maxTime.integerValue];
    if ([bgColor isEqual:[UIColor blackColor]]) {
        bgColor = [UIColor clearColor];
    }
    [[dhCell flag] setBackgroundColor:bgColor];
	
	NSDateFormatter *dateFormat = [NSDateFormatter new];
	[dateFormat setDateFormat:@"MMM dd, yyyy"];
	NSString *creationDate = [dateFormat stringFromDate:[object timeStamp]];
	[[dhCell creationDate] setText:[NSString stringWithFormat:@"%@ %@", @"Created: ", creationDate]];
	
	[[dhCell elapsedTime] setText:[object totalTime]];
	
	NSString *qualifyingTime = [NSString stringWithFormat:@"(%d~%d)", [[object minTime] intValue], [[object maxTime] intValue]];
	[[dhCell timeRange] setText:qualifyingTime];
	
	[dhCell setEntity:object];
}

#pragma mark quickStartPanel

- (void)quickStartBegin:(id)sender {
    [self insertNewObject:sender];
    NSIndexPath *tableViewIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    [self.tableView selectRowAtIndexPath:tableViewIndexPath
                                animated:YES
                          scrollPosition:UITableViewScrollPositionTop];
}

- (void)quickStartEnds:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kQuickStart];
    
    [self performSegueWithIdentifier:@"showDetail" sender:sender];
}

- (void)setupFirstObjectWithName:(NSString *)name minTime:(int)min maxTime:(int)max
{
    [self setupFirstObjectWithName:name minTimeNumber:@(min) maxTimeNumber:@(max)];
}

- (void)setupFirstObjectWithName:(NSString *)name minTimeNumber:(NSNumber *)min maxTimeNumber:(NSNumber *)max {
    NSIndexPath *frc_indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    Event *obj = [self.fetchedResultsController objectAtIndexPath:frc_indexPath];
    [obj setName:name];
    [obj setMinTime:(min)];
    [obj setMaxTime:(max)];
    
    DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate saveContext];
}

- (void)customStartTopic:(NSString *)topic withMinTime:(int)min withMaxTime:(int)max {
#if DEBUG
    NSLog(@"custome startTopic");
#endif
    [self setCustomStartDict:@{kName: topic, kMinValue:@(min), kMaxValue:@(max)}];

    //begin right away if app is already loaded and already in the default view; otherwise, wait until the view did appear method to begin
//    if (self.didLoad && !self.didUnwind) {
//        [self beginCustomStartTopic];
//    }
    
    /**
     Sometimes if we are already in the default view, the above condition will fail In that event, this scheduled timer will call it to start.
     */
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(beginCustomStartTopic:) userInfo:nil repeats:NO];
}

- (void)beginCustomStartTopic:(NSTimer *)aTimer {
    if (self.customStartDict) {
#if DEBUG
        NSLog(@"NSTimer Triggered CustomStartTopic");
#endif
        [self beginCustomStartTopic];
    }
}

- (void)beginCustomStartTopic {
    if (self.customStartDict == nil) {
        return;
    }
    [self quickStartBegin:self];
    [self setupFirstObjectWithName:self.customStartDict[kName]
                     minTimeNumber:self.customStartDict[kMinValue]
                     maxTimeNumber:self.customStartDict[kMaxValue]];
    [self quickStartEnds:self];
    [self setCustomStartDict:nil];
}

- (IBAction)tappedTableTopics:(id)sender {
    [self quickStartBegin:sender];
    
    [self setupFirstObjectWithName:kTableTopics minTime:kTableTopicsMin maxTime:kTableTopicsMax];
    
    [self quickStartEnds:sender];
}

- (IBAction)tappedPresetSpeechTime:(UISegmentedControl *)sender {
    [self quickStartBegin:sender];
    NSNumber *min, *max;
    
    [sender valuesOfTappedSegmentedControlMinValue:&min maxValue:&max];
    [self setupFirstObjectWithName:nil minTime:min.intValue maxTime:max.intValue];
    [self quickStartEnds:sender];
}

- (IBAction)unwindForURLScheme:(UIStoryboardSegue *)sender {
#if DEBUG
    NSLog(@"just unwinded");
#endif
    self.didUnwind = YES;
}

@end
