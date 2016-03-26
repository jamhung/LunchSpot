//
//  UIColor+DetermineBrightness.h
//  Guidebook
//
//  Created by James Hung on 8/19/15.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (DetermineBrightness)

- (BOOL)isBright;
+ (UIColor*)changeBrightness:(UIColor*)color amount:(CGFloat)amount;
+(NSString *)hexValuesFromUIColor:(UIColor *)color;
@end
