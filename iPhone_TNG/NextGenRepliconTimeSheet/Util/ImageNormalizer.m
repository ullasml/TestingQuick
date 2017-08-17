#import "ImageNormalizer.h"

@implementation ImageNormalizer

- (UIImage *)normalizeImage:(UIImage *)sourceImage {

    float oldHeight = sourceImage.size.height;
    float scaleFactor = 320.0f / oldHeight;

    float newWidth = sourceImage.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;

    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *scaledDownImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (scaledDownImage.imageOrientation == UIImageOrientationUp) return scaledDownImage;

    UIGraphicsBeginImageContextWithOptions(scaledDownImage.size, NO, scaledDownImage.scale);
    [scaledDownImage drawInRect:(CGRect){0, 0, scaledDownImage.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return normalizedImage;
}

@end
