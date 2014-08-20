//
//  DHUserProfileCollectionViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 8/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHUserProfileCollectionViewController.h"
#import "DHUserProfileCollectionViewCell.h"
#import "User_Profile.h"
#import "DHEditUserProfileViewController.h"

@interface DHUserProfileCollectionViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DHUserProfileCollectionViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProfile)];
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

#pragma mark - UICollectionViewDeleages

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // the number of sections should the 26 letters of the alphabet plus a number and misclanious section
#warning temp hard code of 1 section
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DHUserProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"profileCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    User_Profile *up = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (self.customCellTapResponse) {
        self.customCellTapResponse(up,self);
    } else {
        [self editProfileWithObject:up];
    }
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User_Profile" inManagedObjectContext:_managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user_name" ascending:YES];
	NSArray *sortDescriptors = @[sortDescriptor];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
//    NSPredicate *pred = [NSPredicate predicateWithFormat:
//                         @"city contains[cd] $A or"
//                         " state contains[cd] $A or"
//                         " name contains[cd] $A"];
//    pred = [pred predicateWithSubstitutionVariables:@{@"A":self.searchBar.text,
//                                                      @"C":@"contains[c]"}];
//    fetchRequest.predicate = pred;
    
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	aFetchedResultsController.delegate = self;
	_fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
		[DHError displayValidationError:error];
	}
	
	return _fetchedResultsController;
}

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//	[self.collectionView beginUpdates];
//}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            break;
			
		case NSFetchedResultsChangeDelete:
			[self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	UICollectionView *collectionView = self.collectionView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
			break;
			
		case NSFetchedResultsChangeDelete:
			[collectionView deleteItemsAtIndexPaths:@[indexPath]];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[collectionView cellForItemAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
			[collectionView insertItemsAtIndexPaths:@[newIndexPath]];
			break;
	}
}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//	[self.tableView endUpdates];
//}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	DHUserProfileCollectionViewCell *dhCell = (DHUserProfileCollectionViewCell *)cell;
    
	User_Profile *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
    dhCell.labelProfileName.text = object.user_name;
    dhCell.labelProfileSpeechNumber.text = [object.total_speeches stringValue];
    dhCell.ImageProfilePic.image = [UIImage imageWithContentsOfFile:[object.profile_pic_path stringByAppendingPathExtension:@"thumbnail"]];
}

#pragma mark - creation/ editing

- (void)addNewProfile {
    DHEditUserProfileViewController *vc = [DHEditUserProfileViewController new];
    NSManagedObjectContext *tempMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempMoc.parentContext = _managedObjectContext;
    User_Profile *up = [NSEntityDescription insertNewObjectForEntityForName:@"User_Profile"
                                                     inManagedObjectContext:tempMoc];
    vc.objectID = up.objectID;
    vc.managedObjectContext = tempMoc;
    vc.EditingMode = UserProfileMode_NEW_PROFILE;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)editProfileWithObject:(User_Profile *)up {
    NSManagedObjectContext *tempMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempMoc.parentContext = _managedObjectContext;
    
    DHEditUserProfileViewController *vc = [[DHEditUserProfileViewController alloc]
                                           initWithContext:tempMoc
                                           objectID:up.objectID
                                           editingMode:UserProfileMode_MODIFY_PROFILE];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
