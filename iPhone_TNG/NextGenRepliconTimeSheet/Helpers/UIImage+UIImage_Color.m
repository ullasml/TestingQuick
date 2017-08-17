//
//  UIImage+UIImage_Color.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 2017-06-14.
//  Copyright © 2017 Replicon. All rights reserved.
//

#import "UIImage+UIImage_Color.h"

@implementation UIImage (UIImage_Color)


+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
