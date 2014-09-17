//
//  DHIAPHelper.m
//  TMTimer
//
//  Created by Derrick Ho on 9/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHIAPHelper.h"

NSString *const DHIAPHelperProductPurchaseNotification = @"DHIAPHelperProductPurchaseNotification";

@implementation DHIAPHelper {
    SKProductsRequest *_productsRequest;
    void (^_completionHandler)(BOOL success, NSArray *products);
    NSSet *_productIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    _productIdentifiers = productIdentifiers;
    
    //Check for previously purchased Products
    _purchasedProductIdentifiers = NSMutableSet.set;
    for (NSString *productIdentifier in _productIdentifiers) {
        BOOL productPurchased = [NSUserDefaults.standardUserDefaults boolForKey:productIdentifier];
        if (productPurchased) {
            [_purchasedProductIdentifiers addObject:productIdentifier];
            DHDLog(nil, @"Previously purchased: %@", productIdentifier);
        } else {
            DHDLog(nil, @"Not purchased: %@", productIdentifier);
        }
    }
    //add self as transaction Observer
    [SKPaymentQueue.defaultQueue addTransactionObserver:self];
    return self;
}

- (void)requestProductWithCompletionHandler:(void (^)(BOOL, NSArray *))completionHandler {
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [SKProductsRequest.alloc initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    DHDLog(nil, @"Buying %@...", product.productIdentifier);
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [SKPaymentQueue.defaultQueue addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    DHDLog(nil, @"Loaded list of Products");
    _productsRequest = nil;
    
    for (SKProduct *product in response.products) {
        DHDLog(nil, @"Found Product: %@, %@, %0.2f",
               product.productIdentifier,
               product.localizedTitle,
               product.price.floatValue);
    }
    if (_completionHandler) {
        _completionHandler(YES, response.products);
        _completionHandler = nil;
    }
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        if (SKPaymentTransactionStatePurchased == transaction.transactionState) {
            [self completeTransaction:transaction];
        } else if (SKPaymentTransactionStateFailed == transaction.transactionState) {
            [self failedTransaction:transaction];
        } else if (SKPaymentTransactionStateRestored == transaction.transactionState) {
            [self restoreTransaction:transaction];
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    DHDLog(nil, @"completeTransaction:");
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [SKPaymentQueue.defaultQueue finishTransaction:transaction];
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    DHDLog(nil, @"restoreTransaction:");
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [SKPaymentQueue.defaultQueue finishTransaction:transaction];
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    DHDLog(nil, @"failedTransaction:");
    if (transaction.error.code != SKErrorPaymentCancelled &&
        transaction.error.code != SKErrorPaymentNotAllowed)
      {
        DHDLog(nil, @"Transaction Error: %@", transaction.error.localizedDescription);
        [[UIAlertView.alloc initWithTitle:@"Transaction Error"
                                  message:@"Transaction could not be completed at this time.  Wait a bit and try again later"
                                 delegate:nil
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil]
         show];
      }
    [SKPaymentQueue.defaultQueue finishTransaction:transaction];
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:productIdentifier];
    [NSUserDefaults.standardUserDefaults synchronize];
    [NSNotificationCenter.defaultCenter postNotificationName:DHIAPHelperProductPurchaseNotification
                                                      object:productIdentifier
                                                    userInfo:nil];
}

- (void)restoreCompletedTransactions {
    [SKPaymentQueue.defaultQueue restoreCompletedTransactions];
}

@end
