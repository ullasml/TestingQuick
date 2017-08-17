#import "Geolocation.h"

@interface Geolocation ()

@property (nonatomic) CLLocation *location;
@property (nonatomic) NSString *address;

@end

@implementation Geolocation

- (instancetype)initWithLocation:(CLLocation *)location address:(NSString *)address
{
    self = [super init];
    if (self) {
        self.location = location;
        self.address = address;
    }

    return self;
}
@end
