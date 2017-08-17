#import <Cedar/Cedar.h>
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "TimesheetSyncOperationManager.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "TimesheetModel.h"
#import <KSDeferred/KSPromise.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import <KSDeferred/KSDeferred.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetSyncOperationManagerSpec)

xdescribe(@"TimesheetSyncOperationManager", ^{
    __block TimesheetSyncOperationManager<CedarDouble> *subject;
    __block id<BSBinder, BSInjector> injector;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block TimesheetModel *timesheetModel;
    __block TimesheetService *timesheetService;
    __block id <RequestPromiseClient> client;
    __block NSURLRequest *request;
    __block KSDeferred *deferred;
    __block NSNotificationCenter *notificationCenter;

    beforeEach(^{
       injector = [InjectorProvider injector];

        notificationCenter = [[NSNotificationCenter alloc]init];
        [injector bind:InjectorKeyDefaultNotificationCenter toInstance:notificationCenter];

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];

        timesheetModel = nice_fake_for([TimesheetModel class]);
        [injector bind:[TimesheetModel class] toInstance:timesheetModel];

        timesheetService = nice_fake_for([TimesheetService class]);
        [injector bind:[TimesheetService class] toInstance:timesheetService];

        deferred = [[KSDeferred alloc] init];
        
        client = nice_fake_for(@protocol(RequestPromiseClient));
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];

        client stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            request = receivedRequest;
            return deferred.promise;
        });

        subject = [injector getInstance:[TimesheetSyncOperationManager class]];
        spy_on(subject);

        spy_on(notificationCenter);
    });

    describe(@"startPendingQueueSync:", ^{

        context(@"when sync is in progress", ^{
            beforeEach(^{
                (id<CedarDouble>)subject stub_method(@selector(isTimesheetSyncInProcess)).and_return(YES);
                [subject startPendingQueueSync:nil];
            });

            it(@"should getAllTimesheetsFromDB", ^{
                subject.timesheetModel should_not have_received(@selector(getAllTimesheetsFromDB));
            });
        });

        context(@"when sync is not in progress", ^{
            beforeEach(^{
                (id<CedarDouble>)subject stub_method(@selector(isTimesheetSyncInProcess)).and_return(NO);
                [subject startPendingQueueSync:nil];
            });

            it(@"should not do anything", ^{
                subject.timesheetModel should_not have_received(@selector(getAllTimesheetsFromDB));
            });
        });

    });

    describe(@"callServiceWithName:andTimeSheetURI:", ^{
        context(@"when operation is timesheet save", ^{
            beforeEach(^{
                subject.timesheetModel stub_method(@selector(getAttestationDetailsFromDBForTimesheetUri:)).and_return(@{});
                [subject callServiceWithName:WIDGET_TIMESHEET_SAVE_SERVICE andTimeSheetURI:@"my-timesheet-uri"];
            });

            it(@"should update attestation status", ^{
                subject.timesheetService should have_received(@selector(sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:forAttestationStatusUri:)).with(@"my-timesheet-uri",ATTESTATION_STATUS_UNATTESTED);
            });

            context(@"When the network is reachable", ^{
                __block KSPromise *promise;
                beforeEach(^{

                    promise = nice_fake_for([KSPromise class]);
                    subject.timesheetModel stub_method(@selector(getTimeSheetInfoSheetIdentity:)).and_return(@[[NSMutableDictionary dictionary]]);
                });

                it(@"should send a request to the json client", ^{
                    client should have_received(@selector(promiseWithRequest:));
                });

                it(@"should configure the outgoing request url correctly", ^{
                    request.URL.absoluteString should contain(@"mobile/TimesheetFlowService1.svc/PutTimesheetTimeEntries");
                });

                it(@"should configure the outgoing request http method correctly", ^{
                    request.HTTPMethod should equal(@"POST");
                });



                context(@"when the request is successful", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = nice_fake_for([NSDictionary class]);
                        [deferred resolveWithValue:responseDictionary];

                        __block volatile bool loadComplete = false;
                        dispatch_async(dispatch_get_main_queue(), ^{

                            CFRunLoopStop(CFRunLoopGetCurrent());

                            loadComplete = true;

                        });


                        NSDate* startTime = [NSDate date];
                        while ( !loadComplete )
                        {


                            NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                            [[NSRunLoop currentRunLoop] runUntilDate:nextTry];

                            if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                                NSLog(@"");
                        }
                    });




                    it(@"delete operation name", ^{
                        subject.timesheetModel should have_received(@selector(deleteOperationName:andTimesheetURI:)).with(@"SAVE",@"my-timesheet-uri");
                    });

                    it(@"should handle the response", ^{
                        subject.timesheetService should have_received(@selector(handleTimesheetsSummaryFetchData:isFromSave:)).with(@{@"response":responseDictionary},YES);
                    });

                    it(@"should execute remaining actions", ^{

                        (id<CedarDouble>)subject should have_received(@selector(executeRemainingActionsOnTimeSheetURI:)).with(@"my-timesheet-uri");
                    });

                    it(@"should post previous approvals notification", ^{
                       [notificationCenter postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil] should_not raise_exception;

                    });

                });

                context(@"when the request is successful with business logic Failure", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = @{@"error":@{}};
                        [deferred resolveWithValue:responseDictionary];

                        __block volatile bool loadComplete = false;
                        dispatch_async(dispatch_get_main_queue(), ^{

                            CFRunLoopStop(CFRunLoopGetCurrent());

                            loadComplete = true;

                        });


                        NSDate* startTime = [NSDate date];
                        while ( !loadComplete )
                        {


                            NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                            [[NSRunLoop currentRunLoop] runUntilDate:nextTry];

                            if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                                NSLog(@"");
                        }
                    });




                    it(@"should post errorNotification notification", ^{
                        NSDictionary *userInfo = @{@"uri": @"my-timesheet-uri", @"error_msg": @{}, @"module": TIMESHEETS_TAB_MODULE_NAME};
                        [notificationCenter postNotificationName:errorNotification object:nil userInfo:userInfo] should_not raise_exception;

                    });

                    it(@"should call businessLogicErrorHandlingFortimesheetUri", ^{
                        subject.timesheetModel should have_received(@selector(deleteAllOperationNamesForTimesheetURI:)).with(@"my-timesheet-uri");
                         subject.timesheetModel should have_received(@selector(getTimeSheetInfoSheetIdentity:)).with(@"my-timesheet-uri");
                        subject.timesheetModel should have_received(@selector(updateTimesheetDataForTimesheetUri:withDataDict:)).with(@"my-timesheet-uri",@{});
                        subject.timesheetModel should have_received(@selector(deleteLastKnownApprovalStatusForTimesheetURI:)).with(@"my-timesheet-uri");

                    });
                    
                });

                context(@"when the request is failed", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [deferred rejectWithError:error];
                    });
                    
                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.error should be_nil;
                    });
                });


            });
        });
        context(@"when operation is timesheet submit", ^{
            beforeEach(^{
                subject.timesheetModel stub_method(@selector(getTimeSheetInfoSheetIdentity:)).and_return(@[[NSMutableDictionary dictionary]]);
                [subject callServiceWithName:WIDGET_TIMESHEET_SUBMIT_SERVICE andTimeSheetURI:@"my-timesheet-uri"];
            });

            it(@"should update approval status", ^{
                subject.timesheetModel should have_received(@selector(updateTimesheetDataForTimesheetUri:withDataDict:)).with(@"my-timesheet-uri",@{@"approvalStatus": @"Submitted"});
            });

            context(@"When the network is reachable", ^{
                __block KSPromise *promise;
                beforeEach(^{

                    promise = nice_fake_for([KSPromise class]);
    
                });

                it(@"should send a request to the json client", ^{
                    client should have_received(@selector(promiseWithRequest:));
                });

                it(@"should configure the outgoing request url correctly", ^{
                    request.URL.absoluteString should contain(@"mobile/TimesheetFlowService1.svc/Submit8");
                });

                it(@"should configure the outgoing request http method correctly", ^{
                    request.HTTPMethod should equal(@"POST");
                });



                context(@"when the request is successful", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = nice_fake_for([NSDictionary class]);
                        [deferred resolveWithValue:responseDictionary];

                        __block volatile bool loadComplete = false;
                        dispatch_async(dispatch_get_main_queue(), ^{

                            CFRunLoopStop(CFRunLoopGetCurrent());

                            loadComplete = true;

                        });


                        NSDate* startTime = [NSDate date];
                        while ( !loadComplete )
                        {


                            NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                            [[NSRunLoop currentRunLoop] runUntilDate:nextTry];

                            if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                                NSLog(@"");
                        }
                    });




                    it(@"delete operation name", ^{
                        subject.timesheetModel should have_received(@selector(deleteOperationName:andTimesheetURI:)).with(@"SUBMIT",@"my-timesheet-uri");
                    });

                    it(@"should handle the response", ^{
                        subject.timesheetService should have_received(@selector(handleTimesheetsSummaryFetchData:isFromSave:)).with(@{@"response":responseDictionary},YES);
                    });

                    it(@"should execute remaining actions", ^{

                        (id<CedarDouble>)subject should have_received(@selector(executeRemainingActionsOnTimeSheetURI:)).with(@"my-timesheet-uri");
                    });

                    it(@"should post previous approvals notification", ^{
                        [notificationCenter postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil] should_not raise_exception;

                    });

                });

                context(@"when the request is successful with business logic Failure", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = @{@"error":@{}};
                        [deferred resolveWithValue:responseDictionary];

                        __block volatile bool loadComplete = false;
                        dispatch_async(dispatch_get_main_queue(), ^{

                            CFRunLoopStop(CFRunLoopGetCurrent());

                            loadComplete = true;

                        });


                        NSDate* startTime = [NSDate date];
                        while ( !loadComplete )
                        {


                            NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                            [[NSRunLoop currentRunLoop] runUntilDate:nextTry];

                            if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                                NSLog(@"");
                        }
                    });




                    it(@"should post errorNotification notification", ^{
                        NSDictionary *userInfo = @{@"uri": @"my-timesheet-uri", @"error_msg": @{}, @"module": TIMESHEETS_TAB_MODULE_NAME};
                        [notificationCenter postNotificationName:errorNotification object:nil userInfo:userInfo] should_not raise_exception;

                    });

                    it(@"should call businessLogicErrorHandlingFortimesheetUri", ^{
                        subject.timesheetModel should have_received(@selector(deleteAllOperationNamesForTimesheetURI:)).with(@"my-timesheet-uri");
                        subject.timesheetModel should have_received(@selector(getTimeSheetInfoSheetIdentity:)).with(@"my-timesheet-uri");
                        subject.timesheetModel should have_received(@selector(updateTimesheetDataForTimesheetUri:withDataDict:)).with(@"my-timesheet-uri",@{});
                        subject.timesheetModel should have_received(@selector(deleteLastKnownApprovalStatusForTimesheetURI:)).with(@"my-timesheet-uri");
                        
                    });
                    
                });
                
                context(@"when the request is failed", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [deferred rejectWithError:error];
                    });
                    
                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.error should be_nil;
                    });
                });
                
                
            });
        });
        context(@"when operation is timesheet resubmit", ^{
            beforeEach(^{
                subject.timesheetModel stub_method(@selector(getTimeSheetInfoSheetIdentity:)).and_return(@[[NSMutableDictionary dictionary]]);
                [subject callServiceWithName:WIDGET_TIMESHEET_RESUBMIT_SERVICE andTimeSheetURI:@"my-timesheet-uri"];
            });

            it(@"should update approval status", ^{
                subject.timesheetModel should have_received(@selector(updateTimesheetDataForTimesheetUri:withDataDict:)).with(@"my-timesheet-uri",@{@"approvalStatus": @"Submitted"});
            });

            context(@"When the network is reachable", ^{
                __block KSPromise *promise;
                beforeEach(^{

                    promise = nice_fake_for([KSPromise class]);

                });

                it(@"should send a request to the json client", ^{
                    client should have_received(@selector(promiseWithRequest:));
                });

                it(@"should configure the outgoing request url correctly", ^{
                    request.URL.absoluteString should contain(@"mobile/TimesheetFlowService1.svc/Submit8");
                });

                it(@"should configure the outgoing request http method correctly", ^{
                    request.HTTPMethod should equal(@"POST");
                });



                context(@"when the request is successful", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = nice_fake_for([NSDictionary class]);
                        [deferred resolveWithValue:responseDictionary];

                        __block volatile bool loadComplete = false;
                        dispatch_async(dispatch_get_main_queue(), ^{

                            CFRunLoopStop(CFRunLoopGetCurrent());

                            loadComplete = true;

                        });


                        NSDate* startTime = [NSDate date];
                        while ( !loadComplete )
                        {


                            NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                            [[NSRunLoop currentRunLoop] runUntilDate:nextTry];

                            if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                                NSLog(@"");
                        }
                    });




                    it(@"delete operation name", ^{
                        subject.timesheetModel should have_received(@selector(deleteOperationName:andTimesheetURI:)).with(@"RESUBMIT",@"my-timesheet-uri");
                    });

                    it(@"should handle the response", ^{
                        subject.timesheetService should have_received(@selector(handleTimesheetsSummaryFetchData:isFromSave:)).with(@{@"response":responseDictionary},YES);
                    });

                    it(@"should execute remaining actions", ^{

                        (id<CedarDouble>)subject should have_received(@selector(executeRemainingActionsOnTimeSheetURI:)).with(@"my-timesheet-uri");
                    });

                    it(@"should post previous approvals notification", ^{
                        [notificationCenter postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil] should_not raise_exception;

                    });

                });

                context(@"when the request is successful with business logic Failure", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = @{@"error":@{}};
                        [deferred resolveWithValue:responseDictionary];

                        __block volatile bool loadComplete = false;
                        dispatch_async(dispatch_get_main_queue(), ^{

                            CFRunLoopStop(CFRunLoopGetCurrent());

                            loadComplete = true;

                        });


                        NSDate* startTime = [NSDate date];
                        while ( !loadComplete )
                        {


                            NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                            [[NSRunLoop currentRunLoop] runUntilDate:nextTry];

                            if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                                NSLog(@"");
                        }
                    });




                    it(@"should post errorNotification notification", ^{
                        NSDictionary *userInfo = @{@"uri": @"my-timesheet-uri", @"error_msg": @{}, @"module": TIMESHEETS_TAB_MODULE_NAME};
                        [notificationCenter postNotificationName:errorNotification object:nil userInfo:userInfo] should_not raise_exception;

                    });

                    it(@"should call businessLogicErrorHandlingFortimesheetUri", ^{
                        subject.timesheetModel should have_received(@selector(deleteAllOperationNamesForTimesheetURI:)).with(@"my-timesheet-uri");
                        subject.timesheetModel should have_received(@selector(getTimeSheetInfoSheetIdentity:)).with(@"my-timesheet-uri");
                        subject.timesheetModel should have_received(@selector(updateTimesheetDataForTimesheetUri:withDataDict:)).with(@"my-timesheet-uri",@{});
                        subject.timesheetModel should have_received(@selector(deleteLastKnownApprovalStatusForTimesheetURI:)).with(@"my-timesheet-uri");
                        
                    });
                    
                });
                
                context(@"when the request is failed", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [deferred rejectWithError:error];
                    });
                    
                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.error should be_nil;
                    });
                });
                
                
            });
        });

    });
});

SPEC_END
