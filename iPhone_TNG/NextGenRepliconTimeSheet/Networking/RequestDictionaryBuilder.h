#import <Foundation/Foundation.h>


@class AppProperties;


@interface RequestDictionaryBuilder : NSObject

@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) AppProperties *appProperties;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithAppProperties:(AppProperties *)appProperties userDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

- (NSDictionary *)requestDictionaryWithEndpointName:(NSString *)endpointName httpBodyDictionary:(NSDictionary *)httpBodyDictionary;

@end
