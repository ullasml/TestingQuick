#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "AppConfig.h"
#import "PersistedSettingsStorage.h"
#import "ModuleProvider.h"
#import "RepliconKitDependencyModule.h"
#import "RepliconKitConstants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AppConfigSpec)

describe(@"AppConfig", ^{
    __block AppConfig *subject;
    __block PersistedSettingsStorage *persistedSettingsStorage;
    __block id<BSBinder, BSInjector> injector;
    __block NSUserDefaults *userDefaults;
    
    beforeEach(^{
        injector = [ModuleProvider injector];
    });
    
    beforeEach(^{
        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyRepliconKitUserDefaults toInstance:userDefaults];
        persistedSettingsStorage = nice_fake_for([PersistedSettingsStorage class]);
        [injector bind:[PersistedSettingsStorage class] toInstance:persistedSettingsStorage];
        subject =  [injector getInstance:[AppConfig class]];
    });

    describe(@"load appconfig from persisted store", ^{
        context(@"When valid persisted stored data available with node backend true", ^{
            beforeEach(^{
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kNodeBackend).and_return(true);
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kNewMarketingServices).and_return(false);
                persistedSettingsStorage stub_method(@selector(getAppConfigStrinValueforKey:)).with(kSource).and_return(@"company:testmobile");
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kNewContextualFlow).and_return(false);
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kTimesheetSaveAndStay).and_return(false);
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kTimesheetWidgetPlatform).and_return(false);
            });
            
            it(@"should return expected values", ^{
                [subject getNodeBackend] should equal(true);
                [subject getConfigurationLevel] should equal(@"company:testmobile");
                [subject getNewMarketingServices] should equal(false);
                [subject getNewContextualFlowPermission] should equal(false);
                [subject getTimesheetSaveAndStay] should equal(false);
                [subject getTimesheetWidgetPlatform] should equal(false);
            });
        });
        
        context(@"When valid persisted stored data available with node backend false", ^{
            beforeEach(^{
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kNodeBackend).and_return(false);
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kNewMarketingServices).and_return(true);
                persistedSettingsStorage stub_method(@selector(getAppConfigStrinValueforKey:)).with(kSource).and_return(@"company:testmobile");
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kNewContextualFlow).and_return(true);
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kTimesheetSaveAndStay).and_return(true);
                persistedSettingsStorage stub_method(@selector(getAppConfigBoolValueforKey:)).with(kTimesheetWidgetPlatform).and_return(true);
            });
            
            it(@"should return expected values", ^{
                [subject getNodeBackend] should equal(false);
                [subject getConfigurationLevel] should equal(@"company:testmobile");
                [subject getNewMarketingServices] should equal(true);
                [subject getNewContextualFlowPermission] should equal(true);
                [subject getTimesheetSaveAndStay] should equal(true);
                [subject getTimesheetWidgetPlatform] should equal(true);
            });
        });
        
        context(@"When no data", ^{
            it(@"should return expected values", ^{
                [subject getNodeBackend] should equal(false);
                [subject getConfigurationLevel] should equal(@"global");
                [subject getNewMarketingServices] should equal(false);
                [subject getNewContextualFlowPermission] should equal(false);
                [subject getTimesheetSaveAndStay] should equal(false);
                [subject getTimesheetWidgetPlatform] should equal(false);
            });
        });
        
    });
});

SPEC_END
