#import <Foundation/Foundation.h>


@interface URLStringProvider : NSObject

@property (nonatomic, readonly) NSUserDefaults *userDefaults;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (NSString *)urlStringWithEndpointName:(NSString *)endpointName;

@end
