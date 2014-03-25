//
//  DHGradients.m
//  TMTimer
//
//  Created by Derrick Ho on 3/24/14.
//  Copyright (c) 2014 ryukkusakku. All rights reserved.
//

#import "DHGradients.h"

@implementation DHGradients
+ (void)produceRandomDots:(NSUInteger)numLines inFrame:(CGRect)rect{
	for (int i = 0; i < numLines; ++i) {
    CGPoint p0 = CGPointMake(arc4random() % (int)rect.size.width, arc4random() % (int)rect.size.height);
		[self drawPoint:p0 withColor:[UIColor colorWithRed:49/255.0 green:249/255.0 blue:236/255.0 alpha:0.5]];
	}
}

+ (void)drawLineFromPointA:(CGPoint)pA toPointB:(CGPoint)pB withColorA:(UIColor *)colorA toColorB:(UIColor *)colorB {
	if (pA.x == pB.x && pA.y == pB.y) {
    [self drawPoint:pB withColor:colorB];
		return;
	}
	
	CGFloat r,g,b,a;
	[colorA getRed:&r green:&g blue:&b alpha:&a];
	CGFloat r2,g2,b2,a2;
	[colorB getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
	
	CGFloat rInc;
	CGFloat gInc;
	CGFloat bInc;
	CGFloat aInc;
	
	if ((NSInteger)pA.y == (NSInteger)pB.y) { //horizontal line
		NSInteger inc = (pA.x - pB.x) < 0? +1: -1;
		NSInteger distance = fabsf(pA.x - pB.x);
		
		rInc = ((r-r2)/distance);
		gInc = ((g-g2)/distance);
		bInc = ((b-b2)/distance);
		aInc = ((a-a2)/distance);
    for (NSInteger i = pA.x; i != pB.x; i += inc) {
			
			[self drawPoint:CGPointMake(i, pA.y) withColor:[UIColor colorWithRed:r green:g blue:b alpha:a]];
			r -= rInc;
			g -= gInc;
			b -= bInc;
			a -= aInc;
		}
		//color b
		[self drawPoint:pB withColor:[UIColor colorWithRed:r2 green:g2 blue:b2 alpha:a2]];
	} else if (pA.x == pB.x) { //vertical line
		NSInteger inc = (pA.y - pB.y) < 0? +1: -1;
		NSInteger distance = fabsf(pA.y - pB.y);
		
		rInc = ((r-r2)/distance);
		gInc = ((g-g2)/distance);
		bInc = ((b-b2)/distance);
		aInc = ((a-a2)/distance);
    for (NSInteger i = pA.y; i != pB.y; i += inc) {
			
			[self drawPoint:CGPointMake(pA.x, i) withColor:[UIColor colorWithRed:r green:g blue:b alpha:a]];
			r -= rInc;
			g -= gInc;
			b -= bInc;
			a -= aInc;
		}
		//color b
		[self drawPoint:pB withColor:[UIColor colorWithRed:r2 green:g2 blue:b2 alpha:a2]];
	} else { //use bresenham lines for everything else
		int x0 = pA.x;
		int y0 = pA.y;
		int x1 = pB.x;
		int y1 = pB.y;
		
		int dx, dy, sx, sy, err;
		BOOL notdone;
		dx = fabsf( x1-x0);
		dy = fabsf( y1-y0);
		sx = -1;
		sy = -1;
		if( x0 < x1){ sx = 1;}
		if( y0 < y1){ sy = 1;}
		err = dx-dy;
		
		notdone = true;
		
		CGFloat distance = sqrtf(pow(pA.x - pB.x, 2) + pow(pA.y - pB.y, 2));
		
		rInc = ((r-r2)/distance);
		gInc = ((g-g2)/distance);
		bInc = ((b-b2)/distance);
		aInc = ((a-a2)/distance);
		
		while( notdone){
			[self drawPoint:CGPointMake(x0, y0) withColor:[UIColor colorWithRed:r green:g blue:b alpha:a]];
			r -= rInc;
			g -= gInc;
			b -= bInc;
			a -= aInc;
			if( (x0 == x1) || ( y0 == y1)){
				break;
			}
			if( !((err+err) < (-dy))){
				err = err -dy;
				x0 = x0 + sx;
			}
			if( !((err+err) > dx)){
				err = err + dx;
				y0 = y0 + sy;
			}
		}
		[self drawPoint:CGPointMake(x1, y1) withColor:[UIColor colorWithRed:r2 green:g2 blue:b2 alpha:a2]];
	}
}

/**
 draws point with black color
 
 */
+ (void)drawPoint:(CGPoint)p {
	[self drawPoint:p withColor:[UIColor blackColor]];
}

/**
 Draws point with specified color
 */
+ (void)drawPoint:(CGPoint)p withColor:(UIColor *) color{
	CGFloat red = 0 , blu = 0, grn = 0, alf = 0;
	[color getRed:&red green:&grn blue:&blu alpha:&alf];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetRGBFillColor(context, red, grn, blu, alf);
	CGContextFillRect(context, CGRectMake(p.x, p.y, 1, 1));
}

/**
 draws a horizontal line with the given color
 */
+ (void)drawHorizontalLineFromX0:(NSInteger)x0 toX1:(NSInteger)x1 atY:(NSInteger)y withColor:(UIColor *)color{
	NSInteger direction = 0;
	if ((x1 - x0) > 0) {
    direction = 1;
	} else if ((x1 - x0) < 0) {
		direction = -1;
	}
	for (NSInteger i = x0; i != x1; i += direction) {
		[self drawPoint:CGPointMake(i, y) withColor:color];
	}
	[self drawPoint:CGPointMake(x1, y) withColor:color];
}

/**
 draws a horizontal line gradient with the left color being colorA and the right color bring colorB
 */
+ (void)drawHorizontalLineFromX0:(NSInteger)x0 toX1:(NSInteger)x1 atY:(NSInteger)y fromColorA:(UIColor *)colorA toColorB:(UIColor *)colorB {
	CGFloat r,g,b,a;
	CGFloat r2,g2,b2,a2;
	
	[colorA getRed:&r green:&g blue:&b alpha:&a];
	[colorB getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
	
	NSInteger distance = fabsf(x1 - x0);
	CGFloat rInc = (r2-r) / distance;
	CGFloat gInc = (g2-g) / distance;
	CGFloat bInc = (b2-b) / distance;
	CGFloat aInc = (a2-a) /distance;
	
	NSInteger inc = 1;
	if (x1-x0 < 0) {
    NSInteger temp = x1;
		x1 = x0;
		x0 = temp;
	}
	NSInteger i = x0;
	while (i != x1) {
		UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
		[self drawPoint:CGPointMake(i, y) withColor:color];
		i += inc;
		r += rInc;
		b += bInc;
		g += gInc;
		a += aInc;
	}
	[self drawPoint:CGPointMake(x1, y) withColor:colorB];
}

/**
 draws a square gradient with the left color being leftColor and right being rightColor
 */
+ (void)drawSquareAtULPoint:(CGPoint)ul width:(NSInteger)w leftColor:(UIColor *)lColor rightColor:(UIColor *)rColor {
	[self drawRectAtULPoint:ul size:CGSizeMake(w, w) ulColor:lColor urColor:rColor llColor:lColor lrColor:rColor];
}

/**
 draws a square with three gradients: the upper left, upper right and lower right
 */
+ (void)drawSquareAtULPoint:(CGPoint)ul width:(NSInteger)w ulColor:(UIColor *)ulColor urColor:(UIColor *)urColor lrColor:(UIColor *)lrColor{
	[self drawRectAtULPoint:ul size:CGSizeMake(w, w) ulColor:ulColor urColor:urColor llColor:ulColor lrColor:lrColor];
}

/**
 draws a square with four gradients: the upper left, upper right, lower left, and lower right
 */
+ (void)drawSquareAtULPoint:(CGPoint)ul width:(NSInteger)w ulColor:(UIColor *)ulColor urColor:(UIColor *)urColor llColor:(UIColor *)llColor lrColor:(UIColor *)lrColor {
	[self drawRectAtULPoint:ul size:CGSizeMake(w, w) ulColor:ulColor urColor:urColor llColor:llColor lrColor:lrColor];
}

/**
 draws a rectangle with four gradients: the upper left, upper right, lower left, and lower right
 */
+ (void)drawRectAtULPoint:(CGPoint)ul size:(CGSize)size ulColor:(UIColor *)ulColor urColor:(UIColor *)urColor llColor:(UIColor *)llColor lrColor:(UIColor *)lrColor {
	CGFloat urRed, urGreen, urBlue, urAlpha;
	CGFloat lrRed, lrGreen, lrBlue, lrAlpha;
	[urColor getRed:&urRed green:&urGreen blue:&urBlue alpha:&urAlpha];
	[lrColor getRed:&lrRed green:&lrGreen blue:&lrBlue alpha:&lrAlpha];
	CGFloat incRedRight = (lrRed - urRed) / size.height;
	CGFloat incGreenRight = (lrGreen - urGreen) / size.height;
	CGFloat incBlueRight = (lrBlue - urBlue) / size.height;
	CGFloat incAlphaRight = (lrAlpha - urAlpha) / size.height;
	
	CGFloat ulRed, ulGreen, ulBlue, ulAlpha;
	CGFloat llRed, llGreen, llBlue, llAlpha;
	[ulColor getRed:&ulRed green:&ulGreen blue:&ulBlue alpha:&ulAlpha];
	[llColor getRed:&llRed green:&llGreen blue:&llBlue alpha:&llAlpha];
	CGFloat incRedLeft = (llRed - ulRed) / size.height;
	CGFloat incGreenLeft = (llGreen - ulGreen) / size.height;
	CGFloat incBlueLeft = (llBlue - ulBlue) / size.height;
	CGFloat incAlphaLeft = (llAlpha - ulAlpha) / size.height;
	
	NSInteger i = 0;
	while (i < size.height) {
		UIColor *colorLeft = [UIColor colorWithRed:ulRed green:ulGreen blue:ulBlue alpha:ulAlpha];
		UIColor *colorRight = [UIColor colorWithRed:urRed green:urGreen blue:urBlue alpha:urAlpha];
    [self drawHorizontalLineFromX0:ul.x toX1:ul.x + size.width atY:ul.y + i fromColorA:colorLeft toColorB:colorRight];
		++i;
		urRed += incRedRight;
		urGreen += incGreenRight;
		urBlue += incBlueRight;
		urAlpha += incAlphaRight;
		
		ulRed += incRedLeft;
		ulGreen += incGreenLeft;
		ulBlue += incBlueLeft;
		ulAlpha += incAlphaLeft;
	}
}

@end
