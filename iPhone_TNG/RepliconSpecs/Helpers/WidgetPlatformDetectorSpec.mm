#import <Cedar/Cedar.h>
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <repliconkit/AppConfig.h>
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetPlatformDetectorSpec)

describe(@"WidgetPlatformDetector", ^{
    __block WidgetPlatformDetector *subject;
    __block id<BSInjector, BSBinder> injector;
    __block AppConfig *appConfig;

    beforeEach(^{
        injector = [InjectorProvider injector];
        
        appConfig =  nice_fake_for([AppConfig class]);
        [injector bind:[AppConfig class] toInstance:appConfig];
        
        subject = [injector getInstance:InjectorKeyWidgetPlatformDetector];
    });
    
    describe(@"isWidgetPlatformSupported", ^{
        
        context(@"when widgetPlatformFeatureFlag is false", ^{
            
            it(@"should return false", ^{
                [subject isWidgetPlatformSupported] should_not be_truthy;
            });
        });
        
        context(@"when widgetPlatformFeatureFlag is true", ^{
            beforeEach(^{
                appConfig stub_method(@selector(getTimesheetWidgetPlatform)).and_return(true);
            });

            context(@"when userConfiguredWidgets are supported in widgetPlatform", ^{
                beforeEach(^{
                    [subject setupWithUserConfiguredWidgetUris:@[PUNCH_WIDGET_URI, INOUT_WIDGET_URI , NOTICE_WIDGET_URI,ATTESTATION_WIDGET_URI]];
                });
                
                it(@"should return true for isWidgetPlatformSupported", ^{
                    [subject isWidgetPlatformSupported] should be_truthy;
                });
            });
            
            context(@"when urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry is supported in widgetPlatform", ^{
                beforeEach(^{
                    [subject setupWithUserConfiguredWidgetUris:@[PUNCH_WIDGET_URI]];
                });
                
                it(@"should return true for isWidgetPlatformSupported", ^{
                    [subject isWidgetPlatformSupported] should be_truthy;
                });
            });
            
            context(@"when urn:replicon:policy:timesheet:widget-timesheet:payroll-summary is supported in widgetPlatform", ^{
                beforeEach(^{
                    [subject setupWithUserConfiguredWidgetUris:@[PAYSUMMARY_WIDGET_URI]];
                });
                
                it(@"should return true for isWidgetPlatformSupported", ^{
                    [subject isWidgetPlatformSupported] should be_truthy;
                });
            });
            
            context(@"when urn:replicon:policy:timesheet:widget-timesheet:notice is supported in widgetPlatform", ^{
                beforeEach(^{
                    [subject setupWithUserConfiguredWidgetUris:@[NOTICE_WIDGET_URI]];
                });
                
                it(@"should return true for isWidgetPlatformSupported", ^{
                    [subject isWidgetPlatformSupported] should be_truthy;
                });
            });
            
            context(@"when urn:replicon:policy:timesheet:widget-timesheet:attestation is supported in widgetPlatform", ^{
                beforeEach(^{
                    [subject setupWithUserConfiguredWidgetUris:@[ATTESTATION_WIDGET_URI]];
                });
                
                it(@"should return true for isWidgetPlatformSupported", ^{
                    [subject isWidgetPlatformSupported] should be_truthy;
                });
            });
        });
    });
});

SPEC_END
