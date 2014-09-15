//
//  TMIAPHelper.m
//  TMTimer
//
//  Created by Derrick Ho on 9/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "TMIAPHelper.h"

NSString *const kRemoveAdvertisements = @"com.dnthome.TMTimer.Remove_Advertisements";
NSString *const kDefaultTimerFlags = @"com.dnthome.TMTimer.Default_Timer_Flag";
NSString *const kWineTimerFlags = @"com.dnthome.TMTimer.Wine_Timer_Flags";

@implementation TMIAPHelper

+ (TMIAPHelper *)sharedInstance {
    static TMIAPHelper *_sharedInstance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSArray *productIdentifiers = @[kRemoveAdvertisements,
                                        kDefaultTimerFlags,
                                        kWineTimerFlags];
        _sharedInstance =
        [self.alloc initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    });
    return _sharedInstance;
}

- (BOOL)canDisplayAds {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRemoveAdvertisements] == NO;
}

- (BOOL)canDefaultFlags {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultTimerFlags];
}

- (BOOL)canWineFlags {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kWineTimerFlags];
}
@end
