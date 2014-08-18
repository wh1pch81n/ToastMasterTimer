//
//  DHEditUserProfileViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 8/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHEditUserProfileViewController.h"
#import "User_Profile.h"
#import "Event.h"
#import "Event+helperMethods.h"
#import "User_Profile+helperMethods.h"

@interface DHEditUserProfileViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalNumberOfSpeeches;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfilePic;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DHEditUserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithContext:(NSManagedObjectContext *)context objectID:(NSManagedObjectID *)objectID editingMode:(enum Mode)mode {
    if (self = [super init]) {
        _managedObjectContext = context;
        _objectID = objectID;
        _EditingMode = mode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.textFieldName.delegate = self;
    self.searchBar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setUpViewWithMode];
}

- (void)setUpViewWithMode {
    if (self.EditingMode == UserProfileMode_MODIFY_PROFILE) {
        
    } else if (self.EditingMode == UserProfileMode_NEW_PROFILE) {
        self.tableView.hidden = YES;
        self.searchBar.hidden = YES;
        self.labelTotalNumberOfSpeeches.hidden = YES;
    }
    
    User_Profile *up = (User_Profile *)[self.managedObjectContext objectWithID:self.objectID];
    self.textFieldName.text = up.user_name;
    self.labelTotalNumberOfSpeeches.text = up.total_speeches.stringValue;
    self.imageViewProfilePic.image = [UIImage imageWithContentsOfFile:up.profile_pic_path];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1;}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *cellIdentifier = @"speechCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Event *obj = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = obj.name;
    
    NSString *timeConstraints = [NSString stringWithFormat:@"%@ ~ %@", obj.minTime, obj.maxTime];
#warning needs implementing
    NSString *timeOffset = @"";// if before green should show negative minute and seconds  if beyond it should be plus
    
    NSString *timeString = [NSString stringWithFormat:@"%@ [%@]", timeConstraints, timeOffset];
    cell.detailTextLabel.text = timeString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#warning needs implementing.  Show a little more detail about the speech maybe
    
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textFieldName resignFirstResponder];
    return NO;
}

#pragma mark - searchbar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Error in search %@, %@", error, [error userInfo]);
    } else {
        [self.tableView reloadData];
        if ([[searchText stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]]
             isEqualToString:@""]) {
            self.labelTotalNumberOfSpeeches.text = [[(User_Profile *)[self.managedObjectContext objectWithID:self.objectID] total_speeches] stringValue];
        } else {
            self.labelTotalNumberOfSpeeches.text = @(_fetchedResultsController.fetchedObjects.count).stringValue;
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

#pragma mark - fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Event"
                                      inManagedObjectContext:_managedObjectContext];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    fetchRequest.fetchBatchSize = 20;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", _searchBar.text];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

#pragma mark - view dismissal

- (void)cancelEdits {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)tappedCancel:(id)sender {
    [self cancelEdits];
}
- (IBAction)tappedSave:(id)sender {
    [self saveEdits];
}

- (void)saveEdits {
    User_Profile *up = (User_Profile *)[_managedObjectContext objectWithID:_objectID];
    up.user_name = [self.textFieldName.text stringByTrimmingCharactersInSet:
                    [NSCharacterSet whitespaceAndNewlineCharacterSet]];
#warning todo.  you need to implement what happens with the image.
    
    [_managedObjectContext performBlock:^{
        NSError *error;
        if(![_managedObjectContext save:&error]) {
            [DHError displayValidationError:error];
        }
        
        [_managedObjectContext.parentContext performBlock:^{
            NSError *error;
            if (![_managedObjectContext.parentContext save:&error]) {
                [DHError displayValidationError:error];
            }
        }];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
