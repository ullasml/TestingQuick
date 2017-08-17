#import "GUIDProvider.h"


@implementation GUIDProvider

- (NSString *)guid
{
    return [Util getRandomGUID];
}

@end
