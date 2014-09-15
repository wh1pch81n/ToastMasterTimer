//
//  TMPurchasesViewController.m
//  TMTimer
//
//  Created by Derrick Ho on 9/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMPurchasesViewController.h"
#import "TMPurchasesTableViewCell.h"
#import "TMIAPHelper.h"

@interface TMPurchasesViewController ()

@property NSArray *products;
@property NSNumberFormatter *priceFormatter;

@end

@implementation TMPurchasesViewController

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
    // Do any additional setup after loading the view from its nib.
    [self registerCustomTableViewCell];
    self.title = @"Store";
    self.refreshControl = UIRefreshControl.new;
    [self.refreshControl addTarget:self action:@selector(reload)
                  forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    self.priceFormatter = NSNumberFormatter.new;
    self.priceFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    self.priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:TMIAPHelper.sharedInstance action:@selector(restoreCompletedTransactions:)];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(productPurchased:)
                                               name:DHIAPHelperProductPurchaseNotification
                                             object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:DHIAPHelperProductPurchaseNotification
                                                object:nil];
}

- (void)productPurchased:(NSNotification *)notification {
    NSString *productIdentifier = notification.object;
    [self.products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            *stop = YES;
        }
    }];
}

- (void)reload {
    _products = nil;
    [self.tableView reloadData];
    [TMIAPHelper.sharedInstance requestProductWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
        
            NSMutableArray *arr = [NSMutableArray new];
            [arr addObjectsFromArray:[products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.productIdentifier = %@", kRemoveAdvertisements]]];
            [arr addObjectsFromArray:[products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.productIdentifier = %@", kDefaultTimerFlags]]];
            [arr addObjectsFromArray:[products filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.productIdentifier = %@", kWineTimerFlags]]];
            
            _products = arr;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - TableView Delegate Datasource

- (void)registerCustomTableViewCell {
    UINib *dhCustomNib = [UINib nibWithNibName:@"TMPurchasesTableViewCell" bundle:nil];
    [self.tableView registerNib:dhCustomNib forCellReuseIdentifier:@"IAPCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPurchasesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"IAPCell"
                                                                          forIndexPath:indexPath];
    SKProduct *product = (id)self.products[indexPath.row];
    {//Set label
        cell.productNameLabel.text = product.localizedTitle;
    }
    {//set graphic
#warning needs implementing.  Creating StyleKit for this
    }
    {//set Button
        
        self.priceFormatter.locale = product.priceLocale;
        
        NSString *priceString = [self.priceFormatter stringFromNumber:product.price];
        [cell.productPriceButton setTitle:priceString
                                 forState:UIControlStateNormal];
        [cell.productPriceButton removeTarget:self
                                       action:NULL
                             forControlEvents:UIControlEventTouchUpInside];
        cell.productPriceButton.tag = indexPath.row;
        if ([TMIAPHelper.sharedInstance productPurchased:product.productIdentifier]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.accessoryView = nil;
            cell.productPriceButton.hidden = YES;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
            cell.productPriceButton.hidden = NO;
            [cell.productPriceButton addTarget:self
                                        action:@selector(buyButtonTapped:)
                              forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return cell;
}

- (void)buyButtonTapped:(UIButton *)buyButton {
    SKProduct *product = self.products[buyButton.tag];
    [TMIAPHelper.sharedInstance buyProduct:product];
}

@end