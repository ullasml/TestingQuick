

#import <Foundation/Foundation.h>

@interface MobileMonitorURLProvider : NSObject

@property (nonatomic, readonly) NSUserDefaults *userDefaults;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

- (NSString *)baseUrlForMobileMonitor;

@end
