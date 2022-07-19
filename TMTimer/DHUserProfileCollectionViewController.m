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
#import "User_Profile+helperMethods.h"
#import "Event.h"
#import "DHEditUserProfileViewController.h"

@interface DHUserProfileCollectionViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSCache *imageCache;

@property (strong, nonatomic) dispatch_queue_t dispatchQueue_profileImages;

@end

@implementation DHUserProfileCollectionViewController

- (dispatch_queue_t)dispatchQueue_profileImages {
    if (_dispatchQueue_profileImages) return _dispatchQueue_profileImages;
    const char *name = [NSStringFromSelector(@selector(dispatchQueue_profileImages)) UTF8String];
    _dispatchQueue_profileImages = dispatch_queue_create(name, DISPATCH_QUEUE_CONCURRENT);
    return _dispatchQueue_profileImages;
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
    
    UIImage *addProfile = [TMTimerStyleKit imageOfAddProfileButton];
    if ([addProfile respondsToSelector:@selector(imageWithRenderingMode:)]) {
        addProfile = [addProfile imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    UIButton *_addProfile = [UIButton buttonWithType:UIButtonTypeCustom];
    _addProfile.frame = CGRectMake(0, 0, 50, 50);
    [_addProfile setBackgroundImage:addProfile forState:UIControlStateNormal];
    [_addProfile addTarget:self action:@selector(addNewProfile) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem
    .rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_addProfile];
    
    self.imageCache = [[NSCache alloc] init];
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
    
    return 1;//hard code of 1 section
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
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"user_name" ascending:YES];
	NSArray *sortDescriptors = @[sortDescriptor];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"SELF != %@", self.speechEvent.speeches_speaker.objectID]; //causing core data crash for some reason
    
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

//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//	switch(type) {
//		case NSFetchedResultsChangeInsert:
//            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
//            break;
//			
//		case NSFetchedResultsChangeDelete:
//			[self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
//			break;
//	}
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//	UICollectionView *collectionView = self.collectionView;
//	
//	switch(type) {
//		case NSFetchedResultsChangeInsert:
//            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//			break;
//			
//		case NSFetchedResultsChangeDelete:
//			[collectionView deleteItemsAtIndexPaths:@[indexPath]];
//			break;
//			
//		case NSFetchedResultsChangeUpdate:
//			[self configureCell:[collectionView cellForItemAtIndexPath:indexPath] atIndexPath:indexPath];
//			break;
//			
//		case NSFetchedResultsChangeMove:
//            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
//			[collectionView insertItemsAtIndexPaths:@[newIndexPath]];
//			break;
//	}
//}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//	[self.tableView endUpdates];
//}


// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    self.imageCache = [NSCache new];
    [self.collectionView reloadData];
}


- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	DHUserProfileCollectionViewCell *dhCell = (DHUserProfileCollectionViewCell *)cell;
    
	User_Profile *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
    dhCell.labelProfileName.text = object.user_name;
    dhCell.labelProfileSpeechNumber.text = [object.total_speeches stringValue];
    dhCell.ImageProfilePic.image = [UIImage imageWithContentsOfFile:object.profile_pic_path];
    
    if ((dhCell.ImageProfilePic.image = [self.imageCache objectForKey:indexPath]) == nil) {
        dispatch_async(self.dispatchQueue_profileImages, ^{
            UIImage * img= [UIImage imageWithContentsOfFile:object.profile_pic_path];
            dispatch_async(dispatch_get_main_queue(), ^{
                DHUserProfileCollectionViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
                if (cell) {
                    cell.ImageProfilePic.image = img;
                }
            });
        });
    }
}

#pragma mark - creation/ editing

- (void)addNewProfile {
    DHEditUserProfileViewController *vc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"DHEditUserProfileViewController"];
    NSManagedObjectContext *tempMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempMoc.parentContext = _managedObjectContext;
    User_Profile *up = [NSEntityDescription insertNewObjectForEntityForName:@"User_Profile"
                                                     inManagedObjectContext:tempMoc];
    vc.objectID = up.objectID;
    vc.managedObjectContext = tempMoc;
    vc.EditingMode = UserProfileMode_NEW_PROFILE;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)editProfileWithObject:(User_Profile *)up {
    NSManagedObjectContext *tempMoc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    tempMoc.parentContext = _managedObjectContext;
    
    DHEditUserProfileViewController *vc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"DHEditUserProfileViewController"];
    vc.managedObjectContext = tempMoc;
    vc.objectID = up.objectID;
    vc.EditingMode = UserProfileMode_MODIFY_PROFILE;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
