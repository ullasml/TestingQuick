#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "NextGenRepliconTimeSheet-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetRepositorySpec)

describe(@"WidgetTimesheetRepository", ^{
    __block WidgetTimesheetRepository *subject;
    __block id<BSBinder, BSInjector> injector;
    __block WidgetTimesheetDeserializer *timesheetWidgetsDeserializer;
    __block TimesheetRequestProvider *timesheetRequestProvider;
    __block id <RequestPromiseClient> client;

    beforeEach(^{
        injector = [InjectorProvider injector];
        client = nice_fake_for(@protocol(RequestPromiseClient));
        timesheetWidgetsDeserializer = nice_fake_for([WidgetTimesheetDeserializer class]);
        timesheetRequestProvider = nice_fake_for([TimesheetRequestProvider class]);
        [injector bind:[WidgetTimesheetDeserializer class] toInstance:timesheetWidgetsDeserializer];
        [injector bind:[TimesheetRequestProvider class] toInstance:timesheetRequestProvider];
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        subject = [injector getInstance:[WidgetTimesheetRepository class]];
    });
    
    describe(@"fetchWidgetTimesheetForTimesheetWithUri:", ^{
        __block NSURLRequest *expectedRequest;
        __block KSDeferred *timesheetDeferred;
        __block KSPromise *expectedPromise;

        beforeEach(^{
            timesheetDeferred = [[KSDeferred alloc]init];
            NSURLRequest *request = [[NSURLRequest alloc]init];
            timesheetRequestProvider stub_method(@selector(requestForFetchingTimesheetWidgetsForTimesheetUri:)).and_do_block(^NSURLRequest *(NSString *timesheetUri){
                expectedRequest = request;
                return request;
            });
            client stub_method(@selector(promiseWithRequest:)).and_return(timesheetDeferred.promise);
            expectedPromise = [subject fetchWidgetTimesheetForTimesheetWithUri:@"timesheet-uri"];
        });
        it(@"should request TimesheetRequestProvider to provide proper request", ^{
            timesheetRequestProvider should have_received(@selector(requestForFetchingTimesheetWidgetsForTimesheetUri:)).with(@"timesheet-uri");
        });
        
        it(@"should return a promise for a request", ^{
            client should have_received(@selector(promiseWithRequest:)).with(expectedRequest);
        });
        
        describe(@"when the timesheet fetch succeeds", ^{
            __block NSDictionary *responseDictionary;
            __block WidgetTimesheet *widgetTimesheet;
            beforeEach(^{
                widgetTimesheet = nice_fake_for([WidgetTimesheet class]);
                responseDictionary = @{};
                timesheetWidgetsDeserializer stub_method(@selector(deserialize:)).with(responseDictionary).and_return(widgetTimesheet);
                [timesheetDeferred resolveWithValue:responseDictionary];
            });
            
            it(@"should request TimesheetWidgetsDeserializer to deserialize Widget Timesheet", ^{
                timesheetWidgetsDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
            });
            
            it(@"should set the value properly", ^{
                expectedPromise.value should equal(widgetTimesheet);
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
    
    describe(@"fetchWidgetTimesheetForDate:", ^{
        __block NSURLRequest *expectedRequest;
        __block KSDeferred *timesheetDeferred;
        __block NSDate *date;
        __block KSPromise *expectedPromise;
        beforeEach(^{
            timesheetDeferred = [[KSDeferred alloc]init];
            date = [NSDate dateWithTimeIntervalSince1970:0];
            NSURLRequest *request = [[NSURLRequest alloc]init];

            timesheetRequestProvider stub_method(@selector(requestForFetchingTimesheetWidgetsForDate:)).and_do_block(^NSURLRequest *(NSDate *date){
                expectedRequest = request;
                return request;
            });
            client stub_method(@selector(promiseWithRequest:)).and_return(timesheetDeferred.promise);
            expectedPromise = [subject fetchWidgetTimesheetForDate:date];
        });
        
        it(@"should request TimesheetRequestProvider to provide proper request", ^{
            timesheetRequestProvider should have_received(@selector(requestForFetchingTimesheetWidgetsForDate:)).with(date);
        });
        
        it(@"should return a promise for a request", ^{
            client should have_received(@selector(promiseWithRequest:)).with(expectedRequest);
        });
        
        describe(@"when the timesheet fetch succeeds", ^{
            __block NSDictionary *responseDictionary;
            __block WidgetTimesheet *widgetTimesheet;
            beforeEach(^{
                widgetTimesheet = nice_fake_for([WidgetTimesheet class]);
                responseDictionary = @{};
                timesheetWidgetsDeserializer stub_method(@selector(deserialize:)).with(responseDictionary).and_return(widgetTimesheet);
                [timesheetDeferred resolveWithValue:responseDictionary];
            });
            
            it(@"should request TimesheetWidgetsDeserializer to deserialize Widget Timesheet", ^{
                timesheetWidgetsDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
            });
            
            it(@"should set the value properly", ^{
                expectedPromise.value should equal(widgetTimesheet);
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
