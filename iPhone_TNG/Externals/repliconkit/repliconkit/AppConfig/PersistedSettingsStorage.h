#import <Foundation/Foundation.h>

@interface PersistedSettingsStorage : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

-(void)storeAppConfigDictionary:(NSDictionary *)dict;
-(void)updateAppConfigValue:(id)value forKey:(id)key;
-(id)getAppConfigValueforKey:(id)key;
-(NSString *)getAppConfigStrinValueforKey:(id)key;
-(BOOL)getAppConfigBoolValueforKey:(id)key;

@end
