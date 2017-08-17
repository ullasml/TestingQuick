#import <Foundation/Foundation.h>

@class CLLocation;

@interface Geolocation : NSObject

@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) NSString *address;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithLocation:(CLLocation *)location address:(NSString *)address NS_DESIGNATED_INITIALIZER;

@end
