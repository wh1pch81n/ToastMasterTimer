//
//  User_Profile.h
//  TMTimer
//
//  Created by Derrick Ho on 8/22/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Event;

@interface User_Profile : NSManagedObject

@property (nonatomic, retain) NSNumber * profile_pic_orientation;
@property (nonatomic, retain) NSString * profile_pic_filename;
@property (nonatomic, retain) NSNumber * total_speeches;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSSet *users_speeches;
@end

@interface User_Profile (CoreDataGeneratedAccessors)

- (void)addUsers_speechesObject:(Event *)value;
- (void)removeUsers_speechesObject:(Event *)value;
- (void)addUsers_speeches:(NSSet *)values;
- (void)removeUsers_speeches:(NSSet *)values;

@end
