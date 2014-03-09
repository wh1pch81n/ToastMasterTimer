//
//  DHError.h
//  TMTimer
//
//  Created by Derrick Ho on 3/9/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A class that offers support for errors
 */

@interface DHError : NSObject
+ (void)displayValidationError:(NSError *)anError;
@end
