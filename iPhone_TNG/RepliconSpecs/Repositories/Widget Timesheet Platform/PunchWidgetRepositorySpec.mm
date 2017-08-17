#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "NextGenRepliconTimeSheet-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchWidgetRepositorySpec)

describe(@"PunchWidgetRepository", ^{
    __block PunchWidgetRepository *subject;
    __block id<BSBinder, BSInjector> injector;
    __block TimesheetInfoDeserializer *timesheetInfoDeserializer;
    __block WidgetTimesheetRequestProvider *timesheetRequestProvider;
    __block id <RequestPromiseClient> client;
    __block NSURLRequest *expectedRequest;
    __block KSDeferred *timesheetDeferred;
    __block KSPromise *expectedPromise;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        client = nice_fake_for(@protocol(RequestPromiseClient));
        timesheetInfoDeserializer = nice_fake_for([TimesheetInfoDeserializer class]);
        timesheetRequestProvider = nice_fake_for([WidgetTimesheetRequestProvider class]);
        [injector bind:[TimesheetInfoDeserializer class] toInstance:timesheetInfoDeserializer];
        [injector bind:[WidgetTimesheetRequestProvider class] toInstance:timesheetRequestProvider];
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        subject = [injector getInstance:[PunchWidgetRepository class]];
    });
    
    describe(@"fetchPunchWidgetInfoForTimesheetWithUri:", ^{
        
        
        beforeEach(^{
            timesheetDeferred = [[KSDeferred alloc]init];
            expectedRequest = [[NSURLRequest alloc]init];
            timesheetRequestProvider stub_method(@selector(requestForPunchWidgetSummary:)).with(@"timesheet-uri").and_return(expectedRequest);
            client stub_method(@selector(promiseWithRequest:)).with(expectedRequest).and_return(timesheetDeferred.promise);
        });
        
        beforeEach(^{
            expectedPromise = [subject fetchPunchWidgetInfoForTimesheetWithUri:@"timesheet-uri"];
        });
        
        it(@"should request TimesheetRequestProvider to provide proper request", ^{
            timesheetRequestProvider should have_received(@selector(requestForPunchWidgetSummary:)).with(@"timesheet-uri");
        });
        
        it(@"should return a promise for a request", ^{
            client should have_received(@selector(promiseWithRequest:)).with(expectedRequest);
        });
        
        describe(@"when the timesheet fetch succeeds", ^{
            __block NSDictionary *responseDictionary;
            __block TimesheetInfo *timesheetInfo;
            beforeEach(^{
                timesheetInfo = nice_fake_for([TimesheetInfo class]);
                responseDictionary = @{};
                timesheetInfoDeserializer stub_method(@selector(deserializeTimesheetInfoForWidget:)).with(responseDictionary).and_return(timesheetInfo);
                [timesheetDeferred resolveWithValue:responseDictionary];
            });
            
            it(@"should request TimesheetWidgetsDeserializer to deserialize Widget Timesheet", ^{
                timesheetInfoDeserializer should have_received(@selector(deserializeTimesheetInfoForWidget:)).with(responseDictionary);
            });
            
            it(@"should set the value properly", ^{
                expectedPromise.value should equal(timesheetInfo);
            });
        });
        
        describe(@"when the timesheet fetch fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = [[NSError alloc]initWithDomain:@"" code:0 userInfo:nil];
                [timesheetDeferred rejectWithError:error];
            });
            
            it(@"should set the error properly", ^{
                expectedPromise.error should equal(error);
            });
        });
        
    });
});

SPEC_END
