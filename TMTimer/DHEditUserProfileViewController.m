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
#import "UIImage+DHScaledImage.h"

@interface DHEditUserProfileViewController ()

@property (strong, nonatomic) DHEditUserProfileTableViewCell *prototypeCell;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalNumberOfSpeeches;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfilePic;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) BOOL didSetImage;
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
    [[self imageViewProfilePic] addGestureRecognizer:
     [[UITapGestureRecognizer alloc] initWithTarget:self
                                             action:@selector(tappedImage:)]];
    [[self imageViewProfilePic] setUserInteractionEnabled:YES];
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
    if ([up.user_name isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Name Required" message:@"Speaker's name can not be blank" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        //[[(DHAppDelegate *)[[UIApplication sharedApplication] delegate] arrOfAlerts] addObject:alert];
        return;// don't let them save
    }
#warning todo.  you need to implement what happens with the image.
    
    [_managedObjectContext performBlock:^{
        if (self.didSetImage) {
            [self saveImageFileToDisk];
        }
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

- (void)saveImageFileToDisk {
    //construct the path to the file in our Documents director.
    NSString *imageDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES) lastObject];
    NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
    NSString *imagePath = [imageDir stringByAppendingPathComponent:uniqueFileName];
    
    
    User_Profile *up = (User_Profile *)[self.managedObjectContext objectWithID:self.objectID];
    //remove old path if any
    [self removeOldImageIfAny:up];
    //Save path
    up.profile_pic_path = imagePath;
        
    //get the image from the uiimageview
    UIImage *image = self.imageViewProfilePic.image;
    UIImage *imageThumb = [image imageScaledToFitInSize:self.imageViewProfilePic.frame.size];
    //    UIImage *imageFull = [image imageScaledToFitInSize:kFullImageSize]; //does not currently save full size images
    
    up.profile_pic_orientation = @(image.imageOrientation);//saving the image orientation
    
    //not currently saving full sized images to disk
    //    __weak typeof(sSelf)wSelf = sSelf;
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    //            //saving full image to disk
    //            NSData *imageAsData = UIImagePNGRepresentation(imageFull);
    //            [imageAsData writeToFile:imagePath atomically:YES];
    //            NSLog(@"done saving full image\n%@", imagePath);
    //        });
    
    
    //saving thumbnail of image to disk.
    NSData *imageThumbAsData = UIImagePNGRepresentation(imageThumb);
    
    NSString *imageThumbPath = [imagePath stringByAppendingPathExtension:@"thumbnail"];
    if(![imageThumbAsData writeToFile:imageThumbPath atomically:YES]){
        NSLog(@"Could not save thumbnail image \n%@", imageThumbPath);
    } else {
        NSLog(@"done saving Thumbnail image\n%@", imageThumbPath);
    }
}

- (void)removeOldImageIfAny:(User_Profile *)userProfile {
    NSString *path = [userProfile.profile_pic_path stringByAppendingPathExtension:@"thumbnail"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //move old image files to volitile space.
        NSString *libCacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
        NSString *newPath = [libCacheDir stringByAppendingPathComponent:uniqueFileName];
        NSError *err;
        [[NSFileManager defaultManager] moveItemAtPath:path toPath:newPath error:&err];
        if(err) {NSLog(@"Error: %@", [err localizedDescription]);}
    }
}

#pragma mark - Image

- (IBAction)tappedImage:(id)sender {
    NSLog(@"Just Tapped Image");
    if ([self.textFieldName isFirstResponder]) {
        [self.textFieldName resignFirstResponder];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"This device has a camera.  Asking the user what they want to use.");
        UIActionSheet *photoSourceSheet = [[UIActionSheet alloc]
                                           initWithTitle:@"Select Photo"
                                           delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                           otherButtonTitles:@"Take new Photo", @"Choose Existing Photo", nil];
        
        //show the action sheet near the add image button.
        [photoSourceSheet showInView:self.view];
    } else { //no camera. Just use the library
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        
        [self presentViewController:picker
                           animated:YES completion:nil];
        
    }
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageViewProfilePic.image = info[UIImagePickerControllerEditedImage];
    self.didSetImage = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"Cancled Action Sheet");
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    [picker setAllowsEditing:NO];
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"user wants to take a new picture");
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
            
        default:
            NSLog(@"user want to get photo from library");
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}


@end
