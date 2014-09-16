//
//  TMChangeFlagGraphicTableViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 9/15/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMChangeFlagGraphicTableViewController.h"
#import "TMChangeFlagTableViewCell.h"
#import "TMIAPHelper.h"
#import "TMPurchasesViewController.h"

NSString *const kFlagSelectionPlain = @"kFlagSelectionPlain";
NSString *const kFlagSelectionGauge = @"kFlagSelectionGauge";
NSString *const kFlagSelectionWine = @"kFlagSelectionWine";

NSString *const kChangedFlagGraphicNotification = @"kChangedFlagGraphicNotification";

@interface TMChangeFlagGraphicTableViewController ()
@property (weak, nonatomic) IBOutlet TMChangeFlagTableViewCell *plainCell;
@property (weak, nonatomic) IBOutlet UIImageView *plainGreenFlag;
@property (weak, nonatomic) IBOutlet UIImageView *plainYellowFlag;
@property (weak, nonatomic) IBOutlet UIImageView *plainRedFlag;

@property (weak, nonatomic) IBOutlet TMChangeFlagTableViewCell *gaugeCell;
@property (weak, nonatomic) IBOutlet UIImageView *gaugeGreenFlag;
@property (weak, nonatomic) IBOutlet UIImageView *gaugeYellowFlag;
@property (weak, nonatomic) IBOutlet UIImageView *gaugeRedFlag;

@property (weak, nonatomic) IBOutlet TMChangeFlagTableViewCell *wineCell;
@property (weak, nonatomic) IBOutlet UIImageView *wineGreenFlag;
@property (weak, nonatomic) IBOutlet UIImageView *wineYellowFlag;
@property (weak, nonatomic) IBOutlet UIImageView *wineRedFlag;

@end

@implementation TMChangeFlagGraphicTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.plainGreenFlag.image = [TMTimerStyleKit imageOfPlainGauge50_WithG_minSeconds:1
                                                                         g_maxSeconds:3
                                                                     g_elapsedSeconds:1];
    self.plainYellowFlag.image = [TMTimerStyleKit imageOfPlainGauge50_WithG_minSeconds:1
                                                                         g_maxSeconds:3
                                                                     g_elapsedSeconds:2];
    self.plainRedFlag.image = [TMTimerStyleKit imageOfPlainGauge50_WithG_minSeconds:1
                                                                       g_maxSeconds:3
                                                                   g_elapsedSeconds:3];
    
    self.gaugeGreenFlag.image = [TMTimerStyleKit imageOfGauge50WithG_minSeconds:1 g_maxSeconds:3
                                                               g_elapsedSeconds:1];
    self.gaugeYellowFlag.image = [TMTimerStyleKit imageOfGauge50WithG_minSeconds:1 g_maxSeconds:3
                                                                g_elapsedSeconds:2];
    self.gaugeRedFlag.image = [TMTimerStyleKit imageOfGauge50WithG_minSeconds:1 g_maxSeconds:3
                                                             g_elapsedSeconds:3];
    
    self.wineGreenFlag.image = [TMTimerStyleKit imageOfWineGauge50WithG_minSeconds:1
                                                                      g_maxSeconds:3 g_elapsedSeconds:1];
    self.wineYellowFlag.image = [TMTimerStyleKit imageOfWineGauge50WithG_minSeconds:1
                                                                      g_maxSeconds:3
                                                                  g_elapsedSeconds:2];
    self.wineRedFlag.image = [TMTimerStyleKit imageOfWineGauge50WithG_minSeconds:1
                                                                    g_maxSeconds:3
                                                                g_elapsedSeconds:40];
    
    self.plainCell.cellName = kFlagSelectionPlain;
    self.gaugeCell.cellName = kFlagSelectionGauge;
    self.wineCell.cellName = kFlagSelectionWine;
    
    if ([TMIAPHelper sharedInstance].canPlainFlags == NO) {
        self.plainGreenFlag.alpha = 0.1;
        self.plainYellowFlag.alpha = 0.1;
        self.plainRedFlag.alpha = 0.1;
    }
    if ([TMIAPHelper sharedInstance].canWineFlags == NO) {
        self.wineGreenFlag.alpha = 0.1;
        self.wineYellowFlag.alpha = 0.1;
        self.wineRedFlag.alpha = 0.1;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshCells];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *rowName =  ((TMChangeFlagTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).cellName;
    if ([rowName isEqualToString:kFlagSelectionPlain]) {
        if ([[TMIAPHelper sharedInstance] canPlainFlags]) {
            [[NSUserDefaults standardUserDefaults] setObject:rowName forKey:kUserDefaultsCurrentTimerFlagName];
        } else {
            [self goToIAPStore];
        }
    } else if ([rowName isEqualToString:kFlagSelectionWine]) {
        if ([[TMIAPHelper sharedInstance] canWineFlags]) {
            [[NSUserDefaults standardUserDefaults] setObject:rowName forKey:kUserDefaultsCurrentTimerFlagName];
        } else {
            [self goToIAPStore];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:rowName forKey:kUserDefaultsCurrentTimerFlagName];
    }
    
    [self refreshCells];
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangedFlagGraphicNotification object:nil userInfo:nil];
}

- (void)refreshCells {
    [self.plainCell setUserInteractionEnabled:YES];
    [self.wineCell setUserInteractionEnabled:YES];
    [self.gaugeCell setUserInteractionEnabled:YES];
    
    [self.plainCell setAccessoryType:UITableViewCellAccessoryNone];
    [self.wineCell setAccessoryType:UITableViewCellAccessoryNone];
    [self.gaugeCell setAccessoryType:UITableViewCellAccessoryNone];
    
    NSString *flagName = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsCurrentTimerFlagName];
    if ([flagName isEqualToString:kFlagSelectionPlain]) {
        [self.plainCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.plainCell setUserInteractionEnabled:NO];
    } else if ([flagName isEqualToString:kFlagSelectionWine]) {
        [self.wineCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.wineCell setUserInteractionEnabled:NO];
    } else { //it is either blank or in gauge
        [self.gaugeCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self.gaugeCell setUserInteractionEnabled:NO];
    }
}

- (void) goToIAPStore {
    [[UIAlertView.alloc initWithTitle:@"Currently Locked"
                             message:@"Would you like to unlock this?"
                            delegate:self
                   cancelButtonTitle:@"No Thanks"
                   otherButtonTitles:@"Sure", nil] show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    TMPurchasesViewController *pvc = [TMPurchasesViewController.alloc initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:pvc animated:YES];

}

@end
