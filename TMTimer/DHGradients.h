//
//  DHGradients.h
//  TMTimer
//
//  Created by Derrick Ho on 3/24/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHGradients : NSObject
+ (void)produceRandomDots:(NSUInteger)numLines inFrame:(CGRect)rect withColor:(UIColor *)color;
+ (void)drawLineFromPointA:(CGPoint)pA toPointB:(CGPoint)pB withColorA:(UIColor *)colorA toColorB:(UIColor *)colorB;

/**
 draws point with black color
 
 */
+ (void)drawPoint:(CGPoint)p;

/**
 Draws point with specified color
 */
+ (void)drawPoint:(CGPoint)p withColor:(UIColor *) color;

/**
 draws a horizontal line with the given color
 */
+ (void)drawHorizontalLineFromX0:(NSInteger)x0 toX1:(NSInteger)x1 atY:(NSInteger)y withColor:(UIColor *)color;

/**
 draws a horizontal line gradient with the left color being colorA and the right color bring colorB
 */
+ (void)drawHorizontalLineFromX0:(NSInteger)x0 toX1:(NSInteger)x1 atY:(NSInteger)y fromColorA:(UIColor *)colorA toColorB:(UIColor *)colorB;

/**
 draws a square gradient with the left color being leftColor and right being rightColor
 */
+ (void)drawSquareAtULPoint:(CGPoint)ul width:(NSInteger)w leftColor:(UIColor *)lColor rightColor:(UIColor *)rColor;

/**
 draws a square with three gradients: the upper left, upper right and lower right
 */
+ (void)drawSquareAtULPoint:(CGPoint)ul width:(NSInteger)w ulColor:(UIColor *)ulColor urColor:(UIColor *)urColor lrColor:(UIColor *)lrColor;

/**
 draws a square with four gradients: the upper left, upper right, lower left, and lower right
 */
+ (void)drawSquareAtULPoint:(CGPoint)ul width:(NSInteger)w ulColor:(UIColor *)ulColor urColor:(UIColor *)urColor llColor:(UIColor *)llColor lrColor:(UIColor *)lrColor;

/**
 draws a rectangle with four gradients: the upper left, upper right, lower left, and lower right
 */
+ (void)drawRectAtULPoint:(CGPoint)ul size:(CGSize)size ulColor:(UIColor *)ulColor urColor:(UIColor *)urColor llColor:(UIColor *)llColor lrColor:(UIColor *)lrColor;

@end
