//
//  UIImage+AvatarPlaceholder.h
//  LunchSpot
//
//  Created by James Hung on 3/13/16.
//  Copyright © 2016 James Hung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AvatarPlaceholder)

+ (UIImage *)ls_placeholderImageFromName:(NSString *)name size:(CGSize)size font:(UIFont *)font circular:(BOOL)circular;
@end
