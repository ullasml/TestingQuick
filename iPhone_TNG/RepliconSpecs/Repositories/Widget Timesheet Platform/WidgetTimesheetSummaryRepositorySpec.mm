#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "NextGenRepliconTimeSheet-Swift.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WidgetTimesheetSummaryRepositorySpec)

WidgetTimesheet *(^doSubjectAction)(NSString *, TimesheetPeriod *,Summary *,NSArray *,TimesheetApprovalTimePunchCapabilities *,BOOL) = ^(NSString *uri, TimesheetPeriod *period,Summary *summary,NSArray *metadata,TimesheetApprovalTimePunchCapabilities *capabilities,BOOL canAutoSubmitOnDueDate){
    return [[WidgetTimesheet alloc]initWithUri:uri
                                        period:period
                                       summary:summary
                               widgetsMetaData:metadata
                 approvalTimePunchCapabilities:capabilities
                        canAutoSubmitOnDueDate:canAutoSubmitOnDueDate
                              displayPayAmount:false 
                    canOwnerViewPayrollSummary:false
                              displayPayTotals:false
                             attestationStatus:Attested];
};

describe(@"WidgetTimesheetSummaryRepository", ^{
    __block WidgetTimesheetSummaryRepository *subject;
    __block id<BSBinder, BSInjector> injector;
    __block WidgetTimesheetSummaryDeserializer *widgetTimesheetSummaryDeserializer;
    __block WidgetTimesheetRequestProvider *timesheetRequestProvider;
    __block id <RequestPromiseClient> client;
    __block WidgetTimesheet *widgetTimesheet;
    __block id <WidgetTimesheetSummaryRepositoryObserver> observer;
    __block NSURLRequest *expectedRequest;
    __block KSDeferred *timesheetDeferred;
    __block KSPromise *expectedPromise;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        observer = nice_fake_for(@protocol(WidgetTimesheetSummaryRepositoryObserver));
        client = nice_fake_for(@protocol(RequestPromiseClient));
        widgetTimesheetSummaryDeserializer = nice_fake_for([WidgetTimesheetSummaryDeserializer class]);
        timesheetRequestProvider = nice_fake_for([WidgetTimesheetRequestProvider class]);
        [injector bind:[WidgetTimesheetSummaryDeserializer class] toInstance:widgetTimesheetSummaryDeserializer];
        [injector bind:[WidgetTimesheetRequestProvider class] toInstance:timesheetRequestProvider];
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        subject = [injector getInstance:[WidgetTimesheetSummaryRepository class]];
    });
    
    context(@"addObserver:", ^{
        __block id <WidgetTimesheetSummaryRepositoryObserver> observerA;
        beforeEach(^{
            observerA = nice_fake_for(@protocol(WidgetTimesheetSummaryRepositoryObserver));
            timesheetDeferred = [[KSDeferred alloc]init];
            expectedRequest = [[NSURLRequest alloc]init];
            timesheetRequestProvider stub_method(@selector(requestForTimesheetSummary:)).with(@"timesheet-uri").and_return(expectedRequest);
            client stub_method(@selector(promiseWithRequest:)).with(expectedRequest).and_return(timesheetDeferred.promise);
            [subject addListener:observerA];            
        });
        beforeEach(^{
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,nil,nil,nil,true);        
            expectedPromise = [subject fetchSummaryForTimesheet:widgetTimesheet];
        });
        
        context(@"when the promise succeeds", ^{
            __block NSDictionary *responseDictionary;
            __block Summary *widgetTimesheetSummary;
            beforeEach(^{
                widgetTimesheetSummary = nice_fake_for([Summary class]);
                responseDictionary = @{};
                widgetTimesheetSummaryDeserializer stub_method(@selector(deserialize:isAutoSubmitEnabled:)).with(responseDictionary,true).and_return(widgetTimesheetSummary);
                [timesheetDeferred resolveWithValue:responseDictionary];
            });
            
            it(@"should inform its observers", ^{
                observerA should have_received(@selector(widgetTimesheetSummaryRepository:fetchedNewSummary:)).with(subject,widgetTimesheetSummary);
            });
        });

    });
    
    context(@"removeObserver", ^{
        __block id <WidgetTimesheetSummaryRepositoryObserver> observerA;
        beforeEach(^{
            observerA = nice_fake_for(@protocol(WidgetTimesheetSummaryRepositoryObserver));
            timesheetDeferred = [[KSDeferred alloc]init];
            expectedRequest = [[NSURLRequest alloc]init];
            timesheetRequestProvider stub_method(@selector(requestForTimesheetSummary:)).with(@"timesheet-uri").and_return(expectedRequest);
            client stub_method(@selector(promiseWithRequest:)).with(expectedRequest).and_return(timesheetDeferred.promise);
            [subject addListener:observerA];            
        });
        
        beforeEach(^{
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,nil,nil,nil,true);        
            expectedPromise = [subject fetchSummaryForTimesheet:widgetTimesheet];
        });
        
        context(@"when the promise succeeds", ^{
            __block NSDictionary *responseDictionary;
            __block Summary *widgetTimesheetSummary;
            beforeEach(^{
                widgetTimesheetSummary = nice_fake_for([Summary class]);
                responseDictionary = @{};
                widgetTimesheetSummaryDeserializer stub_method(@selector(deserialize:isAutoSubmitEnabled:)).with(responseDictionary,true).and_return(widgetTimesheetSummary);
                [subject removeListener:observerA];
                [timesheetDeferred resolveWithValue:responseDictionary];
            });
            
            it(@"should not inform its observers", ^{
                observerA should_not have_received(@selector(widgetTimesheetSummaryRepository:fetchedNewSummary:));
            });
        });

    });
    
    context(@"removeAllObserver", ^{
        __block id <WidgetTimesheetSummaryRepositoryObserver> observerA;
        __block id <WidgetTimesheetSummaryRepositoryObserver> observerB;
        beforeEach(^{
            observerA = nice_fake_for(@protocol(WidgetTimesheetSummaryRepositoryObserver));
            observerB = nice_fake_for(@protocol(WidgetTimesheetSummaryRepositoryObserver));
            timesheetDeferred = [[KSDeferred alloc]init];
            expectedRequest = [[NSURLRequest alloc]init];
            timesheetRequestProvider stub_method(@selector(requestForTimesheetSummary:)).with(@"timesheet-uri").and_return(expectedRequest);
            client stub_method(@selector(promiseWithRequest:)).with(expectedRequest).and_return(timesheetDeferred.promise);
            [subject addListener:observerA];
            [subject addListener:observerB];

        });
        
        beforeEach(^{
            widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,nil,nil,nil,true);        
            expectedPromise = [subject fetchSummaryForTimesheet:widgetTimesheet];
        });
        
        context(@"when the promise succeeds", ^{
            __block NSDictionary *responseDictionary;
            __block Summary *widgetTimesheetSummary;
            beforeEach(^{
                widgetTimesheetSummary = nice_fake_for([Summary class]);
                responseDictionary = @{};
                widgetTimesheetSummaryDeserializer stub_method(@selector(deserialize:isAutoSubmitEnabled:)).with(responseDictionary,true).and_return(widgetTimesheetSummary);
                [subject removeAllListeners];
                [timesheetDeferred resolveWithValue:responseDictionary];
            });
            
            it(@"should not inform its observers", ^{
                observerA should_not have_received(@selector(widgetTimesheetSummaryRepository:fetchedNewSummary:));
                observerB should_not have_received(@selector(widgetTimesheetSummaryRepository:fetchedNewSummary:));
            });
        });
    });

    describe(@"fetchWidgetTimesheetForTimesheetWithUri:", ^{
        
        
        beforeEach(^{
            timesheetDeferred = [[KSDeferred alloc]init];
            expectedRequest = [[NSURLRequest alloc]init];
            timesheetRequestProvider stub_method(@selector(requestForTimesheetSummary:)).with(@"timesheet-uri").and_return(expectedRequest);
            client stub_method(@selector(promiseWithRequest:)).with(expectedRequest).and_return(timesheetDeferred.promise);
        });
        
        context(@"When isAutoSubmitEnabled is enabled ", ^{
            
            beforeEach(^{
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,nil,nil,nil,true);        
                expectedPromise = [subject fetchSummaryForTimesheet:widgetTimesheet];
            });
            
            it(@"should request TimesheetRequestProvider to provide proper request", ^{
                timesheetRequestProvider should have_received(@selector(requestForTimesheetSummary:)).with(@"timesheet-uri");
            });
            
            it(@"should return a promise for a request", ^{
                client should have_received(@selector(promiseWithRequest:)).with(expectedRequest);
            });
            
            describe(@"when the timesheet fetch succeeds", ^{
                __block NSDictionary *responseDictionary;
                __block Summary *widgetTimesheetSummary;
                beforeEach(^{
                    widgetTimesheetSummary = nice_fake_for([Summary class]);
                    responseDictionary = @{};
                    widgetTimesheetSummaryDeserializer stub_method(@selector(deserialize:isAutoSubmitEnabled:)).with(responseDictionary,true).and_return(widgetTimesheetSummary);
                    [timesheetDeferred resolveWithValue:responseDictionary];
                });
                
                it(@"should request TimesheetWidgetsDeserializer to deserialize Widget Timesheet", ^{
                    widgetTimesheetSummaryDeserializer should have_received(@selector(deserialize:isAutoSubmitEnabled:)).with(responseDictionary,true);
                });
                
                it(@"should set the value properly", ^{
                    expectedPromise.value should equal(widgetTimesheetSummary);
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
        
        context(@"When isAutoSubmitEnabled is disabled ", ^{
            
            beforeEach(^{
                widgetTimesheet = doSubjectAction(@"timesheet-uri", nil,nil,nil,nil,false);        
                expectedPromise = [subject fetchSummaryForTimesheet:widgetTimesheet];
            });
            
            it(@"should request TimesheetRequestProvider to provide proper request", ^{
                timesheetRequestProvider should have_received(@selector(requestForTimesheetSummary:)).with(@"timesheet-uri");
            });
            
            it(@"should return a promise for a request", ^{
                client should have_received(@selector(promiseWithRequest:)).with(expectedRequest);
            });
            
            describe(@"when the timesheet fetch succeeds", ^{
                __block NSDictionary *responseDictionary;
                __block Summary *widgetTimesheetSummary;
                beforeEach(^{
                    widgetTimesheetSummary = nice_fake_for([Summary class]);
                    responseDictionary = @{};
                    widgetTimesheetSummaryDeserializer stub_method(@selector(deserialize:isAutoSubmitEnabled:)).with(responseDictionary,false).and_return(widgetTimesheetSummary);
                    [timesheetDeferred resolveWithValue:responseDictionary];
                });
                
                it(@"should request TimesheetWidgetsDeserializer to deserialize Widget Timesheet", ^{
                    widgetTimesheetSummaryDeserializer should have_received(@selector(deserialize:isAutoSubmitEnabled:)).with(responseDictionary,false);
                });
                
                it(@"should set the value properly", ^{
                    expectedPromise.value should equal(widgetTimesheetSummary);
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
});

SPEC_END
