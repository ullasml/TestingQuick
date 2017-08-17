
#import "NSString+RCategory.h"

@implementation NSString (RCategory)

- (BOOL)isNotNullOrEmpty {
    return (self != nil && self != (id)[NSNull null] && self.length > 0);
}

@end
