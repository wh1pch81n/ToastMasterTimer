//
//  Event.h
//  TMTimer
//
//  Created by ryukkusakku on 2/17/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * bgColor;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * maxTime;
@property (nonatomic, retain) NSNumber * minTime;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * totalTime;

@end
