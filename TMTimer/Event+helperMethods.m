//
//  Event+helperMethods.m
//  TMTimer
//
//  Created by ryukkusakku on 2/16/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "Event+helperMethods.h"

static const NSInteger kOneByteMaxValue = 255;
static const NSInteger kNumBitsInOneByte = 8;
static const NSInteger kNumBitsInTwoBytes = 16;
static const NSInteger kNumBitsInThreeBytes = 24;
static const NSInteger kMaskRed = 0xFF000000;
static const NSInteger kMaskGrn = 0x00FF0000;
static const NSInteger kMaskBlu = 0x0000FF00;
static const NSInteger kMaskAlf = 0x000000FF;


@implementation Event (helperMethods)

- (void)setBgColorDataWithColor:(UIColor *)color {
    CGFloat red, grn, blu, alf;
    [color getRed:&red green:&grn blue:&blu alpha:&alf];
   
    NSInteger r, g, b, a;
    r = red * kOneByteMaxValue;
    g = grn * kOneByteMaxValue;
    b = blu * kOneByteMaxValue;
    a = alf * kOneByteMaxValue;
    
    NSNumber *hex = @((r << kNumBitsInThreeBytes) | (g << kNumBitsInTwoBytes) | (b << kNumBitsInOneByte) | (a));
    
    [self setBgColor:hex];
}

- (UIColor *)bgColorFromData {
    NSInteger r, g, b, a;
    r = (self.bgColor.integerValue & kMaskRed) >> kNumBitsInThreeBytes;
    g = (self.bgColor.integerValue & kMaskGrn) >> kNumBitsInTwoBytes;
    b = (self.bgColor.integerValue & kMaskBlu) >> kNumBitsInOneByte;
    a = (self.bgColor.integerValue & kMaskAlf);
    
    UIColor *color = [UIColor colorWithRed:(CGFloat)r/kOneByteMaxValue
                                     green:(CGFloat)g/kOneByteMaxValue
                                      blue:(CGFloat)b/kOneByteMaxValue
                                     alpha:(CGFloat)a/kOneByteMaxValue];
    return color;
}

@end
