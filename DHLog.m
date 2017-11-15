//
//  DHLog.m
//  TMTimer
//
//  Created by Derrick Ho on 8/26/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHLog.h"

void DHRLog(void(^action)(void), NSString *format, ...) {
#if RELEASE
    if (action) {
        action();
    }
    if (format) {
        va_list argumentList;
        va_start(argumentList, format);
        NSMutableString * message = [[NSMutableString alloc] initWithFormat:format
                                                                  arguments:argumentList];
        
        [message appendString:@"Our Logger!"]; // Our custom Message!
        NSLogv(format, argumentList); // Originally NSLog is a wrapper around NSLogv.
        va_end(argumentList);
    }
#endif
}

void DHDLog(void(^action)(void), NSString *format, ...) {
#if DEBUG
    if (action) {
        action();
    }
    if (format) {
        va_list argumentList;
        va_start(argumentList, format);
        NSMutableString * message = [[NSMutableString alloc] initWithFormat:format
                                                                  arguments:argumentList];
        
        [message appendString:@"Our Logger!"]; // Our custom Message!
        NSLogv(format, argumentList); // Originally NSLog is a wrapper around NSLogv.
        va_end(argumentList);
    }

#endif
}

