//
//  ObjectExtensionFieldLimitDeserializerSpec.m
//  NextGenRepliconTimeSheet
//

#import <Foundation/Foundation.h>
#import <Cedar/Cedar.h>
#import "ObjectExtensionFieldLimitDeserializer.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "Constants.h"
#import "RepliconSpecHelper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ObjectExtensionFieldLimitDeserializerSpec)


describe(@"ObjectExtensionFieldLimitDeserializer", ^{
    __block NSUserDefaults *testDefaults;
    __block ObjectExtensionFieldLimitDeserializer *subject;
    __block id <BSInjector,BSBinder> injector;
    
    beforeEach(^{
        
        injector = [InjectorProvider injector];
        
        testDefaults = nice_fake_for([NSUserDefaults class]);
        [injector bind:InjectorKeyStandardUserDefaults toInstance:testDefaults];
        
        subject = [injector getInstance:[ObjectExtensionFieldLimitDeserializer class]];
        
    });
    
    context(@"When oef limit dictionary is available", ^{
        
        beforeEach(^{
            NSDictionary *oefLimitsDict =       @{
                                                         @"numericObjectExtensionFieldMaxPrecision":@14,
                                                         @"numericObjectExtensionFieldMaxScale": @4,
                                                         @"textObjectExtensionFieldMaxLength": @255
                                                 };
            
            [subject deserializeObjectExtensionFieldLimitFromHomeFlowService:oefLimitsDict];
        });
        
        it(@"Should have stored the limits in user defaults", ^{
            
            testDefaults should have_received(@selector(setObject:forKey:)).with([NSNumber numberWithInt:4], OEFMaxScaleKey);
            testDefaults should have_received(@selector(setObject:forKey:)).with([NSNumber numberWithInt:14], OEFMaxPrecisionKey);
            testDefaults should have_received(@selector(setObject:forKey:)).with([NSNumber numberWithInt:255], OEFMaxTextCharLimitKey);
            
        });
        
    });
    
    context(@"When oef limit dictionary is not available", ^{
        
        beforeEach(^{
            NSDictionary *oefLimitsDict =       @{};
            [subject deserializeObjectExtensionFieldLimitFromHomeFlowService:oefLimitsDict];
        });
        
        it(@"Should not have stored the limits in user defaults", ^{
            
            testDefaults should_not have_received(@selector(setObject:forKey:)).with([NSNumber numberWithInt:4], OEFMaxScaleKey);
            testDefaults should_not have_received(@selector(setObject:forKey:)).with([NSNumber numberWithInt:14], OEFMaxPrecisionKey);
            testDefaults should_not have_received(@selector(setObject:forKey:)).with([NSNumber numberWithInt:255], OEFMaxTextCharLimitKey);
            
        });
        
    });
    
    
});


SPEC_END




