//
//  TMIAPHelper.h
//  TMTimer
//
//  Created by Derrick Ho on 9/14/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHIAPHelper.h"

extern NSString *const kRemoveAdvertisements;
extern NSString *const kDefaultTimerFlags;
extern NSString *const kWineTimerFlags;

@interface TMIAPHelper : DHIAPHelper

+ (TMIAPHelper *)sharedInstance;

/**
 Checks the NSUserDefaults to see if ads have been paid yet.
 returns Yes if hasn't been paid yet.
 Retuns NO if it has been paid
 */
- (BOOL)canDisplayAds;

- (BOOL)canDefaultFlags;

- (BOOL)canWineFlags;
@end
