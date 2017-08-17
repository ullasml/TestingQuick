#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "PersistedSettingsStorage.h"
#import "ModuleProvider.h"
#import "RepliconKitDependencyModule.h"
#import "RepliconKitConstants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PersistedSettingsStorageSpec)

describe(@"PersistedSettingsStorage", ^{
    __block PersistedSettingsStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block id<BSInjector, BSBinder> injector;
    
    beforeEach(^{
        injector = [ModuleProvider injector];
    });
    
    beforeEach(^{
        userDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyRepliconKitUserDefaults toInstance:userDefaults];
        subject = [injector getInstance:[PersistedSettingsStorage class]];
    });
    
    describe(@"readAppConfigDictionary:", ^{
        context(@"when nil data dict", ^{
            beforeEach(^{
                userDefaults stub_method(@selector(objectForKey:)).with(kAppConfig).and_return(nil);
            });
            
            it(@"should return nil value", ^{
                [subject getAppConfigValueforKey:kSource] should equal(nil);
                [subject getAppConfigValueforKey:kNodeBackend] should equal(nil);
            });
        });
        
        context(@"when no data", ^{
            beforeEach(^{
                userDefaults stub_method(@selector(objectForKey:)).with(kAppConfig).and_return(@{});
            });
            
            it(@"should return nil value", ^{
                [subject getAppConfigValueforKey:kSource] should equal(nil);
                [subject getAppConfigValueforKey:kNodeBackend] should equal(nil);
            });
        });
        
        __block NSDictionary *dataDict = nil;
        context(@"when valid data", ^{
            beforeEach(^{
                dataDict = @{kSource:@"company:testmobile",kNodeBackend:@1};
                userDefaults stub_method(@selector(objectForKey:)).with(kAppConfig).and_return(dataDict);
            });
            
            it(@"should return expected value", ^{
                [subject getAppConfigStrinValueforKey:kSource] should equal(@"company:testmobile");
                [subject getAppConfigBoolValueforKey:kNodeBackend] should equal(1);
            });
        });
    });
    
    describe(@"storeAppConfigDictionary:", ^{
        __block NSDictionary *dataDict = nil;
        context(@"when valid data", ^{
            beforeEach(^{
                dataDict = @{kSource:@"company:testmobile",kNodeBackend:@1};
                [subject storeAppConfigDictionary:dataDict];
            });
            
            it(@"should return expected value", ^{
                userDefaults should have_received(@selector(setObject:forKey:))
                .with(dataDict, kAppConfig);
                
                userDefaults should have_received(@selector(synchronize));
            });
        });
        
        context(@"when no data", ^{
            beforeEach(^{
                [subject storeAppConfigDictionary:@{kSource:@"no-data",kNodeBackend:@1}];
            });
            
            it(@"should return nil value", ^{
                userDefaults should have_received(@selector(setObject:forKey:))
                .with(nil, kAppConfig);
                
                userDefaults should have_received(@selector(synchronize));
            });
        });
        
        context(@"when nil data", ^{
            beforeEach(^{
                [subject storeAppConfigDictionary:nil];
            });
            
            it(@"should return nil value", ^{
                userDefaults should have_received(@selector(setObject:forKey:))
                .with(nil, kAppConfig);
                
                userDefaults should have_received(@selector(synchronize));
            });
        });
        
    });
});

SPEC_END
