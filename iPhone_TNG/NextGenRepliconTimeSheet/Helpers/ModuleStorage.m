#import "ModuleStorage.h"
#import "Constants.h"


@interface ModuleStorage ()

@property (nonatomic) NSUserDefaults *userDefaults;

@end


@implementation ModuleStorage

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self)
    {
        self.userDefaults = userDefaults;
    }
    return self;
}

- (void)storeModulesWhenDifferent:(NSArray *)modules
{
    NSSet *storedModules = [NSSet setWithArray:[self modules]];
    NSSet *newModules = [NSSet setWithArray:modules];

    if (![storedModules isEqual:newModules])
    {
        NSArray *sortedModules = [self sortModules:modules];
        [self storeModules:sortedModules];
    }
}

- (void)storeModules:(NSArray *)modules
{
    [self.userDefaults setObject:modules forKey:TAB_BAR_MODULES_KEY];
    [self.userDefaults synchronize];
}

- (NSArray *)modules
{
    return [self.userDefaults objectForKey:TAB_BAR_MODULES_KEY];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (NSArray *)sortModules:(NSArray *)modules
{
    NSArray *defaultModuleOrder = @[
                                    CLOCK_IN_OUT_TAB_MODULE_NAME,
                                    NEW_PUNCH_WIDGET_MODULE_NAME,
                                    PUNCH_IN_PROJECT_MODULE_NAME,
                                    PUNCH_INTO_ACTIVITIES_MODULE_NAME,
                                    PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME,
                                    WRONG_CONFIGURATION_MODULE_NAME,
                                    TIMESHEETS_TAB_MODULE_NAME,
                                    APPROVAL_TAB_MODULE_NAME,
                                    SCHEDULE_TAB_MODULE_NAME,
                                    EXPENSES_TAB_MODULE_NAME,
                                    TIME_OFF_TAB_MODULE_NAME,
                                    PUNCH_HISTORY_TAB_MODULE_NAME,
                                    SETTINGS_TAB_MODULE_NAME,
                                    ];

    return [modules sortedArrayUsingComparator:^NSComparisonResult(NSString *module1, NSString *module2) {
        NSNumber *index1 = @([defaultModuleOrder indexOfObject:module1]);
        NSNumber *index2 = @([defaultModuleOrder indexOfObject:module2]);

        return [index1 compare:index2];
    }];
}

@end
