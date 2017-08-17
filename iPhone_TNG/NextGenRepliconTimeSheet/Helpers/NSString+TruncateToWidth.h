
#import <Foundation/Foundation.h>

@interface NSString (TruncateToWidth)

- (NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont *)font;

@end
