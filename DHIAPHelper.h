//
//  DHIAPHelper.h
//  TMTimer
//
//  Created by Derrick Ho on 9/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

/**
 subscribe to this notification to be notified of when a purchase or restoration has completed.
 
 Observers should implement a method with void return type, and the first argument will be an NSString that will contain the productIdentifier
 */
extern NSString *const DHIAPHelperProductPurchaseNotification;

@interface DHIAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductWithCompletionHandler:(void (^)(BOOL success, NSArray *products))completionHandler;
-(void)buyProduct:(SKProduct *)product;
-(BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
