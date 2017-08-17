#import <Cedar/Cedar.h>
#import "ModuleStorage.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ModuleStorageSpec)

describe(@"ModuleStorage", ^{
    __block ModuleStorage *subject;
    __block NSUserDefaults *userDefaults;

    beforeEach(^{
        userDefaults = [[NSUserDefaults alloc]init];
        spy_on(userDefaults);

        subject = [[ModuleStorage alloc] initWithUserDefaults:userDefaults];
    });

    describe(@"storeModulesWhenDifferent:", ^{

        it(@"should sort and store the modules", ^{
            NSArray *expectedModules = @[
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

            NSMutableArray *shuffledModules = [expectedModules mutableCopy];

            NSUInteger count = shuffledModules.count;
            for (NSUInteger i = 0; i < count; ++i) {
                NSInteger remainingCount = count - i;
                NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
                [shuffledModules exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
            }

            [subject storeModulesWhenDifferent:shuffledModules];

            userDefaults should have_received(@selector(setObject:forKey:))
                .with(expectedModules, TAB_BAR_MODULES_KEY);

            userDefaults should have_received(@selector(synchronize));
            [subject modules] should equal(expectedModules);
        });

        it(@"should ignore new set of modules if same set of modules are already stored, regardless of order", ^{
            NSArray *expectedModules = @[
                                         TIMESHEETS_TAB_MODULE_NAME,
                                         SETTINGS_TAB_MODULE_NAME
                                         ];
            userDefaults stub_method(@selector(objectForKey:))
                .with(TAB_BAR_MODULES_KEY).and_return(@[TIMESHEETS_TAB_MODULE_NAME, SETTINGS_TAB_MODULE_NAME]);

            [subject storeModulesWhenDifferent:@[SETTINGS_TAB_MODULE_NAME, TIMESHEETS_TAB_MODULE_NAME]];

            userDefaults should_not have_received(@selector(setObject:forKey:));
            [subject modules] should equal(expectedModules);
        });

        it(@"should replace stored modules if a different set of modules are being stored", ^{
            userDefaults stub_method(@selector(objectForKey:))
                .with(TAB_BAR_MODULES_KEY).and_return(@[TIMESHEETS_TAB_MODULE_NAME, SETTINGS_TAB_MODULE_NAME]);

            [subject storeModulesWhenDifferent:@[CLOCK_IN_OUT_TAB_MODULE_NAME, SETTINGS_TAB_MODULE_NAME]];

            userDefaults should have_received(@selector(setObject:forKey:))
                .with(@[CLOCK_IN_OUT_TAB_MODULE_NAME,SETTINGS_TAB_MODULE_NAME], TAB_BAR_MODULES_KEY);

            userDefaults should have_received(@selector(synchronize));

        });
    });

    describe(@"storeModules:", ^{
        it(@"should store the modules", ^{
            NSArray *modules = @[
                                 PUNCH_HISTORY_TAB_MODULE_NAME,
                                 CLOCK_IN_OUT_TAB_MODULE_NAME,
                                 TIMESHEETS_TAB_MODULE_NAME,
                                 APPROVAL_TAB_MODULE_NAME,
                                 EXPENSES_TAB_MODULE_NAME,
                                 SCHEDULE_TAB_MODULE_NAME,
                                 SETTINGS_TAB_MODULE_NAME,
                                 TIME_OFF_TAB_MODULE_NAME,
                                 NEW_PUNCH_WIDGET_MODULE_NAME,
                                 ];

            [subject storeModules:modules];

            userDefaults should have_received(@selector(setObject:forKey:))
                .with(modules, TAB_BAR_MODULES_KEY);

            userDefaults should have_received(@selector(synchronize));

            [subject modules] should equal(modules);
        });
    });

    describe(@"modules", ^{
        it(@"should return the stored modules", ^{
            NSArray *modules = fake_for([NSArray class]);

            userDefaults stub_method(@selector(objectForKey:))
                .with(TAB_BAR_MODULES_KEY).and_return(modules);
            
            [subject modules] should be_same_instance_as(modules);
        });
    });
});

SPEC_END
