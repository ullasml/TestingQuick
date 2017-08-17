#import <Cedar/Cedar.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetCapabilitiesDeserializerSpec)

describe(@"WidgetTimesheetCapabilitiesDeserializer", ^{
    __block WidgetTimesheetCapabilitiesDeserializer *subject;
    __block NSArray *widgetTimesheetCapabilities;
    __block id<BSInjector, BSBinder> injector;
    
    beforeEach(^{
        widgetTimesheetCapabilities = @[
                                           @{
                                               @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry",
                                               @"policyValue": @{
                                                       @"bool": @YES,
                                                       @"uri": @"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry"
                                            }
                                        },
                                           @{
                                               @"policyKeyUri": @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry",
                                               @"policyValue": @{
                                                }
                                        }];
        injector = [InjectorProvider injector];
        
        subject = [[WidgetTimesheetCapabilitiesDeserializer alloc] init];
    });
    
    describe(@"getUserConfiguredSupportedWidgetUris:", ^{
        __block NSArray *configuredUris;
        beforeEach(^{
            configuredUris = [subject getUserConfiguredSupportedWidgetUris:widgetTimesheetCapabilities];
        });
        
        it(@"should return one uri", ^{
            configuredUris.count should equal(1);
        });
        
        it(@"should return inout uri", ^{
            NSString *inOutUri = configuredUris[0];
            inOutUri should equal(@"urn:replicon:policy:timesheet:widget-timesheet:in-out-time-entry");
        });
    });
});

SPEC_END
