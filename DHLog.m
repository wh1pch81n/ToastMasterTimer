//
//  DHLog.m
//  TMTimer
//
//  Created by Derrick Ho on 8/26/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHLog.h"

void DHRLog(void(^action)()) {
#if RELEASE
    if (action) {
        action();
    }
#endif
}

void DHDLog(void(^action)()) {
#if DEBUG
    if (action) {
        action();
    }
#endif
}

