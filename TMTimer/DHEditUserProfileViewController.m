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
#import "DHEditUserProfileTableViewCell.h"
#import "DHColorForTime.h"

@interface DHEditUserProfileViewController ()

@property (strong, nonatomic) DHEditUserProfileTableViewCell *prototypeCell;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalNumberOfSpeeches;
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
    [self registerCustomTableViewCell];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setUpViewWithMode];
}

- (void)setUpViewWithMode {
    if (self.EditingMode == UserProfileMode_MODIFY_PROFILE) {
        
    } else if (self.EditingMode == UserProfileMode_NEW_PROFILE) {
        self.tableView.hidden = YES;
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

- (void)registerCustomTableViewCell {
    UINib *dhCustomNib = [UINib nibWithNibName:@"DHEditUserProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:dhCustomNib forCellReuseIdentifier:@"speechCell"];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.prototypeCell) {
        self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"speechCell"];
    }
    [self configureCell:self.prototypeCell atIndexPath:indexPath];
    
    //[self.prototypeCell layoutIfNeeded];
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height +1; //plus 1 for the cell separator
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger total = [[self.fetchedResultsController sections] count];
    return total;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger total = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DHEditUserProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"speechCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:(DHEditUserProfileTableViewCell *)cell atIndexPath:indexPath];
}

- (void)configureCell:(DHEditUserProfileTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Event *obj = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.blurb.text = obj.name;
    
    NSString *timeConstraints = [NSString stringWithFormat:@"%@ ~ %@", obj.minTime, obj.maxTime];
#warning needs implementing
    NSString *timeOffset = @"";// if before green should show negative minute and seconds  if beyond it should be plus
    
    NSString *timeString = [NSString stringWithFormat:@"%@ [%@]", timeConstraints, timeOffset];
    cell.range.text = timeString;
    
    cell.flag.layer.cornerRadius = cell.flag.frame.size.width/2;
    //temp
    NSTimeInterval total = [obj.endDate timeIntervalSinceDate:obj.startDate];
    UIColor *bgColor = [[DHColorForTime shared] colorForSeconds:total
                                                            min:obj.minTime.integerValue
                                                            max:obj.maxTime.integerValue];
    if ([bgColor isEqual:[UIColor blackColor]]) {
        bgColor = [UIColor grayColor];
    }
    [[cell flag] setBackgroundColor:bgColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#warning needs implementing.  Show a little more detail about the speech maybe
    
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textFieldName resignFirstResponder];
    return NO;
}

#pragma mark - fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Event"
                                      inManagedObjectContext:_managedObjectContext];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES]];
    fetchRequest.fetchBatchSize = 20;
    
    User_Profile *up = (User_Profile *)[self.managedObjectContext objectWithID:self.objectID];

    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"ANY speeches_speaker.user_name == %@", up.user_name];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
		[DHError displayValidationError:error];
	}
    
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
