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

/**
 prepends the file name with the directory.
 Appends it with the "thumbnail" extension
 */
- (NSString *)profile_pic_path {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *extension = @"thumbnail";
    return [NSString stringWithFormat:@"%@/%@.%@",
            directory,
            self.profile_pic_filename,
            extension];
}

@end
