//
//  User_Profile+helperMethods.m
//  TMTimer
//
//  Created by Derrick Ho on 8/18/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "User_Profile+helperMethods.h"

@implementation User_Profile (helperMethods)

- (NSNumber *)total_speeches {
    return @(self.users_speeches.count);
}

@end
