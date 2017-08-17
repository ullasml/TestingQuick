#import "PersistedSettingsStorage.h"
#import <Blindside/Blindside.h>
#import "NSDictionary+Validation.h"
#import "RepliconKitConstants.h"
#import "ModuleProvider.h"

@interface PersistedSettingsStorage ()

@property (nonatomic) NSUserDefaults *userDefaults;

@end

@implementation PersistedSettingsStorage

#pragma mark -- properties

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self) {
        self.userDefaults = userDefaults;
    }
    return self;
}

#pragma mark - public Methods

- (void)storeAppConfigDictionary:(NSDictionary *)dict {
    if ([self isNotValidAppConfigResponse:dict]) {
        [self.userDefaults setObject:nil forKey:kAppConfig];
    } else {
        [self.userDefaults setObject:dict forKey:kAppConfig];
    }

    [self.userDefaults synchronize];
}

- (NSDictionary *)getAppConfigDictionary {
    return [self.userDefaults objectForKey:kAppConfig];
}

- (void)updateAppConfigValue:(id)value forKey:(id)key {
    NSMutableDictionary *appConfigDict = [[NSMutableDictionary alloc] initWithDictionary:[self getAppConfigDictionary]];
    [appConfigDict setObject:value forKey:key];
    [self storeAppConfigDictionary:appConfigDict];
}

-(id)getAppConfigValueforKey:(id)key {
    return [self getAppConfigDictionary][key];
}

-(NSString *)getAppConfigStrinValueforKey:(id)key {
    return [[self getAppConfigDictionary] stringForKey:key];
}

- (BOOL)getAppConfigBoolValueforKey:(id)key {
    return [[self getAppConfigDictionary] boolForKey:key];
}


#pragma mark - private
- (BOOL)isNotValidAppConfigResponse:(NSDictionary *)dict {
    return [[dict stringForKey:kSource] isEqualToString:@"no-data"];
}

@end
