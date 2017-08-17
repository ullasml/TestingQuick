
#import "NSDictionary+RCategory.h"

@implementation NSDictionary (RCategory)

- (BOOL)isNotNull:(NSDictionary *)dictionary{
    return (dictionary != nil && dictionary != (id)[NSNull null]);
}

@end
