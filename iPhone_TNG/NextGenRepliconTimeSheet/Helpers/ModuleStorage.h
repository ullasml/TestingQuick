#import <Foundation/Foundation.h>


@interface ModuleStorage : NSObject

@property (nonatomic, readonly) NSUserDefaults *userDefaults;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;

- (void)storeModulesWhenDifferent:(NSArray *)modules;
- (void)storeModules:(NSArray *)modules;

- (NSArray *)modules;

@end
