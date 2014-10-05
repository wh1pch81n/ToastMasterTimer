//
//  DHNavigationItem.h
//  TMTimer
//
//  Created by Derrick Ho on 3/24/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

@import UIKit;

@interface DHNavigationItem : UINavigationItem

/**
 controls whether or not the title view is displayed or not
 @param b if YES it will show the title.  otherwise it will not be visible
 */
- (void)showTitleView:(BOOL)b;

@end
