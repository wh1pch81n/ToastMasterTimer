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

NSString *const kMasterViewControllerTitle = @"Speakers";
NSString *const kMore = @"More";
NSString *const kMoreViewSegue = @"MoreView";

@interface DHMasterViewController ()

@property (strong, nonatomic) ADBannerView *bannerView;
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
	
	UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithTitle:kMore style:UIBarButtonItemStyleBordered target:self action:@selector(moreView:)];
	
	self.navigationItem.leftBarButtonItem = moreButtonItem;
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.detailViewController = (DHDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
	
	[self.navigationItem setTitle:kMasterViewControllerTitle];
	
	
	//enable ads
	float version = [[UIDevice currentDevice] systemVersion].floatValue;
	if (version >= 7) {
		[self canDisplayBannerAds];
	}
	
	[self createAdForBanner];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.tableView setTableHeaderView:nil];
	[super viewWillDisappear:animated];
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
	NSLog(@"Pressed more view button");
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
	[newManagedObject setBgColorDataWithColor:[UIColor clearColor]]; //Default bg color
	
	//get default values
	NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
	[newManagedObject setMinTime:[UD objectForKey:kUserDefaultMinTime]];
	[newManagedObject setMaxTime:[UD objectForKey:kUserDefaultMaxTime]];
  
	// Save the context.
	DHAppDelegate *appDelegate = (DHAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate saveContext];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	[self configureCell:cell atIndexPath:indexPath];
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return NO if you do not want the specified item to be editable.
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
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
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		Event *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
		self.detailViewController.detailItem = object;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		Event *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
		[[segue destinationViewController] setDetailItem:object];
		NSManagedObjectContext *context = [self managedObjectContext];
		[[segue destinationViewController] setContext:context];
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
			[tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	Event *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	//handle J.D.
	[[dhCell contestantName] setText:[object name]];
	if (object.name == Nil || [object.name isEqualToString:@""]) {
		[[dhCell contestantName] setText:kJohnDoe];
	}
	
	[[dhCell flag] setBackgroundColor:[object bgColorFromData]];
	
	NSDateFormatter *dateFormat = [NSDateFormatter new];
	[dateFormat setDateFormat:@"MMM dd, yyyy"];
	NSString *creationDate = [dateFormat stringFromDate:[object timeStamp]];
	[[dhCell creationDate] setText:[NSString stringWithFormat:@"%@ %@", @"Created: ", creationDate]];
	
	[[dhCell elapsedTime] setText:[object totalTime]];
	
	NSString *qualifyingTime = [NSString stringWithFormat:@"(%d~%d)", [[object minTime] intValue], [[object maxTime] intValue]];
	[[dhCell timeRange] setText:qualifyingTime];
	
	[dhCell setEntity:object];
}

#pragma mark - iAd's delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	NSLog(@"tableview banner 1");
	[banner setAlpha:YES];
	[self.tableView setTableHeaderView:banner];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	NSLog(@"TableView banner 0");
	[banner setAlpha:NO];
	[self.tableView setTableHeaderView:Nil];
}

- (void)createAdForBanner {
	self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
	[self.bannerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[self.bannerView setDelegate:self];
}

- (void)removeAdForBanner {
	[self.bannerView removeFromSuperview];
	[self setBannerView:nil];
}

@end
