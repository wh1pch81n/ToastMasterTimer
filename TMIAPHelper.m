//
//  TMIAPHelper.m
//  TMTimer
//
//  Created by Derrick Ho on 9/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMIAPHelper.h"

@implementation TMIAPHelper

+ (TMIAPHelper *)sharedInstance {
    static TMIAPHelper *_sharedInstance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSArray *productIdentifiers = @[@"com.dnthome.TMTimer.Remove_Advertisements"];
        _sharedInstance =
        [self.alloc initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    });
    return _sharedInstance;
}

@end
