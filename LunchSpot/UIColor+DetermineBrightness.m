//
//  UIColor+DetermineBrightness.m
//  Guidebook
//
//  Created by James Hung on 8/19/15.
//
//

#import "UIColor+DetermineBrightness.h"

static const NSInteger UIColorDetermineBrightnessThreshold = 160;

@implementation UIColor (DetermineBrightness)

- (BOOL)isBright {
    NSString *hexString = [UIColor hexValuesFromUIColor:self];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    // Extract red hex portion
    NSString *redHexString = [hexString substringWithRange:NSMakeRange(0, 2)];
    NSScanner *scanner = [[NSScanner alloc] initWithString:redHexString];
    unsigned redValue = 0;
    [scanner scanHexInt:&redValue];
    
    // Extract green hex portion
    NSString *greenHexString  = [hexString substringWithRange:NSMakeRange(2, 2)];
    scanner = [[NSScanner alloc] initWithString:greenHexString];
    unsigned greenValue = 0;
    [scanner scanHexInt:&greenValue];
    
    // Extract blue hex portion
    NSString *blueHexString  = [hexString substringWithRange:NSMakeRange(4, 2)];
    scanner = [[NSScanner alloc] initWithString:blueHexString];
    unsigned blueValue = 0;
    [scanner scanHexInt:&blueValue];
    
    NSInteger brightnessValue = (redValue * 299 + greenValue * 587 + blueValue * 114)/1000;
    return brightnessValue > UIColorDetermineBrightnessThreshold;
}

+(NSString *)hexValuesFromUIColor:(UIColor *)color {
    
    if (!color) {
        return nil;
    }
    
    if (color == [UIColor whiteColor]) {
        // Special case, as white doesn't fall into the RGB color space
        return @"ffffff";
    }
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int redDec = (int)(red * 255);
    int greenDec = (int)(green * 255);
    int blueDec = (int)(blue * 255);
    
    NSString *returnString = [NSString stringWithFormat:@"%02x%02x%02x", (unsigned int)redDec, (unsigned int)greenDec, (unsigned int)blueDec];
    
    return returnString;
    
}

+ (UIColor*)changeBrightness:(UIColor*)color amount:(CGFloat)amount {
    CGFloat hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        brightness += (amount-1.0);
        brightness = MAX(MIN(brightness, 1.0), 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    
    CGFloat white;
    if ([color getWhite:&white alpha:&alpha]) {
        white += (amount-1.0);
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }
    
    return nil;
}

@end
