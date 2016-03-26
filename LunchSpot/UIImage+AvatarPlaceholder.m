//
//  UIImage+AvatarPlaceholder.m
//  LunchSpot
//
//  Created by James Hung on 3/13/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

#import "UIImage+AvatarPlaceholder.h"
#import "UIColor+DetermineBrightness.h"
#import <ChameleonFramework/Chameleon.h>

static NSString * const UIImagePlaceholderRenderDarkTextColor = @"#000000";
static NSString * const UIImagePlaceholderRenderLightTextColor = @"#FFFFFF";

@implementation UIImage (AvatarPlaceholder)

+ (UIImage *)ls_placeholderImageFromName:(NSString *)name size:(CGSize)size font:(UIFont *)font circular:(BOOL)circular {
    
    if ([name length] == 0) {
        return nil;
    }
    
    if (font == nil) {
        font = [UIFont fontWithName:@"Avenir-Book" size:size.width*0.5];
    }
    
    NSMutableDictionary *textAttributes = [NSMutableDictionary new];
    textAttributes[NSFontAttributeName] = font;
    
    UIColor *backgroundColor = [self colorForText:name];
    
    // Based on background color brightness, determine text color for contrast.

    if ([backgroundColor isBright]) {
        textAttributes[NSForegroundColorAttributeName] = [UIColor colorWithHexString:UIImagePlaceholderRenderDarkTextColor withAlpha:0.8];
    } else {
        textAttributes[NSForegroundColorAttributeName] = [UIColor colorWithHexString:UIImagePlaceholderRenderLightTextColor withAlpha:0.8];
    }
    
    // Only use first initial of name for placeholder text
    NSString *firstInitial = [[name substringWithRange:NSMakeRange(0, 1)] uppercaseString];
    UIImage *image = [self ls_imageFromText:firstInitial backgroundColor:backgroundColor circular:circular textAttributes:textAttributes size:size];
    
    return image;
}

+ (UIColor *)colorForText:(NSString *)text {
    text = [text capitalizedString];
    
    NSInteger hash = 0;
    NSInteger index = 0;
    
    while (index < [text length]) {
        unichar theChar = [text characterAtIndex:index];
        hash = theChar + (hash << 5) - hash;
        index++;
    }
    
    index = 0;
    NSString *hexColorString = @"#";
    while (index < 3) {
        int colorNumber = (hash >> index * 8 & 0xFF);
        NSString *colorSubString = [NSString stringWithFormat:@"%x", colorNumber];
        colorSubString = [NSString stringWithFormat:@"00%@", colorSubString];
        colorSubString = [colorSubString substringFromIndex:[colorSubString length]-2];
        hexColorString = [hexColorString stringByAppendingString:colorSubString];
        index++;
    }
    return [UIColor colorWithHexString:hexColorString];
}

#pragma - Private Helper Methods

+ (UIImage *)ls_imageFromText:(NSString *)text backgroundColor:(UIColor *)color circular:(BOOL)isCircular textAttributes:(NSDictionary *)textAttributes size:(CGSize)size {
    
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    int radius = size.width/2;
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (isCircular) {
        // Clip context to a circle
        CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, size.width, size.height), NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }
    
    // Fill background of context
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    // Draw text in the context
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    
    [text drawInRect:CGRectMake(size.width/2 - textSize.width/2,
                                size.height/2 - textSize.height/2,
                                textSize.width,
                                textSize.height)
      withAttributes:textAttributes];
    
    // Draw 1 pt width border
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 0.1);
    CGContextAddArc(context, center.x, center.y, radius, 0, M_PI *2, NO);
    CGContextStrokePath(context);
    
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapshot;
}

@end
