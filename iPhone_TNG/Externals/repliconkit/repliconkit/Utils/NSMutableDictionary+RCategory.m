
#import "NSMutableDictionary+RCategory.h"

@implementation NSMutableDictionary (RCategory)
- (BOOL)isNotNull:(NSMutableDictionary *)dictionary{
    return (dictionary != nil && dictionary != (id)[NSNull null]);
}

@end
