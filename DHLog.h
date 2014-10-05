//
//  DHLog.h
//  TMTimer
//
//  Created by Derrick Ho on 8/26/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

@import Foundation;

/**
 By default, Xcode defines the DEBUG macro to 1.
 
 You need to go into the project>build settings.
 
 under the Apple Preprocessing, you should see DEBUG=1.  Since RELEASE is blank, you should add a value to it (ie RELEASE=2).
 */

/**
 Calls the block when on RELEASE
 */
void DHRLog(void(^action)(), NSString *format, ...);

/**
 Calls the block when on DEBUG
 */
void DHDLog(void(^action)(), NSString *format, ...);

