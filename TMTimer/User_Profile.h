//
//  User_Profile.h
//  TMTimer
//
//  Created by Derrick Ho on 8/16/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface User_Profile : NSManagedObject

@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * profile_pic_path;
@property (nonatomic, retain) NSNumber * total_speeches;
@property (nonatomic, retain) NSSet *users_speeches;
@end

@interface User_Profile (CoreDataGeneratedAccessors)

- (void)addUsers_speechesObject:(Event *)value;
- (void)removeUsers_speechesObject:(Event *)value;
- (void)addUsers_speeches:(NSSet *)values;
- (void)removeUsers_speeches:(NSSet *)values;

@end
