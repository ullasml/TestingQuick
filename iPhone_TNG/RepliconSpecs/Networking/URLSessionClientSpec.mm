#import <Cedar/Cedar.h>
#import "URLSessionClient.h"
#import <KSDeferred/KSDeferred.h>
#import "Constants.h"



using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MyNSURLResponse : NSURLResponse
@property (assign) NSInteger statusCode; /* Temporarily overidden */
@end

@implementation MyNSURLResponse
@synthesize statusCode;
@end

SPEC_BEGIN(URLSessionClientSpec)

describe(@"URLSessionClient", ^{
    __block URLSessionClient *subject;
    __block NSURLSession *session;
    __block NSURLSessionDataTask *task;
    __block NSURLRequest *expectedRequest;
    __block DoorKeeper *doorKeeper;
    __block NSUserDefaults *defaults;
    __block NSDateFormatter *dateFormatter;

    __block void (^simulateNetworkResponse)(NSData *, NSURLResponse *, NSError *);

    beforeEach(^{
        task = nice_fake_for([NSURLSessionDataTask class]);
        session = nice_fake_for([NSURLSession class]);
        doorKeeper = nice_fake_for([DoorKeeper class]);
        defaults = nice_fake_for([NSUserDefaults class]);

        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Kolkata"];
        dateFormatter.dateFormat = @"EE, dd MMM yyyy HH:mm:ss ZZZ";

        session stub_method(@selector(dataTaskWithRequest:completionHandler:))
        .and_do_block(^NSURLSessionDataTask *(NSURLRequest *receivedRequest, void (^completionHandler)(NSData *, NSURLResponse *, NSError *)){
            expectedRequest = receivedRequest;
            simulateNetworkResponse = [completionHandler copy];

            return task;
        });

        subject = [[URLSessionClient alloc] initWithURLSession:session doorKeeper:doorKeeper userDefaults:defaults dateFormatter:dateFormatter];
    });

    describe(@"making a network request with the URLSession and getting a promise back", ^{
        __block KSPromise *promise;
        __block NSURLRequest *request;

        context(@"When request is not made for search", ^{
            beforeEach(^{
                request = nice_fake_for([NSURLRequest class]);
                promise = [subject promiseWithRequest:request];
            });

            it(@"should send the request to the session", ^{
                session should have_received(@selector(dataTaskWithRequest:completionHandler:))
                .with(request, Arguments::anything);
            });

            it(@"should resume the data task ", ^{
                task should have_received(@selector(resume));
            });

            context(@"when the session is invalidate", ^{
                beforeEach(^{
                    [subject doorKeeperDidLogOut:doorKeeper];
                });

                it(@"isInvalidateSession should be true", ^{
                    subject.isInvalidateSession should be_truthy;
                });

                it(@"should create new session  ", ^{
                    subject.session should be_same_instance_as(session);
                });

            });

            context(@"when the request succeeds with data", ^{
                __block NSData *data;
                __block MyNSURLResponse *response;

                beforeEach(^{
                    data = nice_fake_for([NSData class]);
                    response = nice_fake_for([MyNSURLResponse class]);

                });

                context(@"When valid status code", ^{

                    context(@"When valid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.value should be_same_instance_as(data);
                        });
                    });

                    context(@"When valid session and url is for updating error details", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"http://baseurl/TimesheetListService1.svc/GetCacheUpdateData"]);
                            response stub_method(@selector(allHeaderFields)).and_return(@{@"Date" : @"Fri, 02 Jun 2016 02:58:56 GMT"});
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.value should be_same_instance_as(data);
                        });
                        it(@"should have correct defaults value for ErrorTimeSheetLastModifiedTime", ^{

                             defaults should have_received(@selector(removeObjectForKey:)).with(@"ErrorTimeSheetLastModifiedTime");
                            defaults should have_received(@selector(setObject:forKey:)).with(@"Fri, 02 Jun 2016 02:58:56 GMT",@"ErrorTimeSheetLastModifiedTime");
                            defaults should have_received(@selector(synchronize));

                        });
                    });

                    context(@"When invalid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            [subject doorKeeperDidLogOut:doorKeeper];
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should reject the promise with the error", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(InvalidUserSessionRequestDomain);
                        });
                    });

                });

                context(@"When not valid status code", ^{

                    context(@"When valid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)403);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(RepliconFailureStatusCodeDomain);
                            promise.error.userInfo[@"NSErrorFailingURLStringKey"] should equal(@"my-special-URL");
                        });
                    });
                    context(@"When invalid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)403);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            [subject doorKeeperDidLogOut:doorKeeper];
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(InvalidUserSessionRequestDomain);
                        });
                    });

                });

                context(@"When not valid status code", ^{

                    context(@"When valid session with 503 error code", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)503);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(RepliconServiceUnAvailabilityResponseErrorDomain);
                        });
                    });
                    
                    context(@"When valid session with 504 error code", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)504);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(RepliconServiceUnAvailabilityResponseErrorDomain);
                        });
                    });
                                        
                    context(@"When invalid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)403);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            [subject doorKeeperDidLogOut:doorKeeper];
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(InvalidUserSessionRequestDomain);
                        });
                    });

                });


            });

            describe(@"when the request fails with an error", ^{

                context(@"When valid session", ^{
                    __block NSError *error;
                    __block NSData *failedData;
                    __block MyNSURLResponse *response;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(code)).and_return((NSInteger)500);
                        error stub_method(@selector(domain)).and_return(RandomErrorDomain);
                        failedData=nice_fake_for([NSData class]);
                        response = nice_fake_for([MyNSURLResponse class]);
                        response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                        simulateNetworkResponse(failedData, response, error);
                    });

                    it(@"should resolve the promise with an error", ^{
                        promise.error.code should equal(500);
                        promise.error.domain should equal(RandomErrorDomain);
                    });

                    it(@"should match the error userinfo", ^{
                        promise.error.userInfo[@"failedData"] should equal(failedData);
                    });
                });

                context(@"When invalid session", ^{
                    __block MyNSURLResponse *response;
                    __block NSError *error;
                    __block NSData *failedData;
                    beforeEach(^{
                        response = nice_fake_for([MyNSURLResponse class]);
                        error = nice_fake_for([NSError class]);
                        response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                        [subject doorKeeperDidLogOut:doorKeeper];
                        failedData=nice_fake_for([NSData class]);
                        simulateNetworkResponse(failedData, response, error);
                    });

                    it(@"should resolve the promise with an error", ^{
                        promise.error should_not be_nil;
                        promise.error.domain should equal(InvalidUserSessionRequestDomain);

                    });
                    it(@"should resolve the promise with an error", ^{
                        promise.error.userInfo[@"failedData"] should equal(failedData);
                    });

                    it(@"should match the error userinfo", ^{
                        promise.error.userInfo[@"failedData"] should equal(failedData);
                    });
                });

            });

            context(@"when user click on logout button", ^{
                beforeEach(^{
                    [subject doorKeeperDidLogOut:doorKeeper];
                });

                it(@"should invalidate And Cancel all request", ^{
                    session should have_received(@selector(invalidateAndCancel));
                });

                it(@"should empty all cookies, cache and credential stores, removes disk files", ^{
                    session should_not have_received(@selector(resetWithCompletionHandler:));
                });

                it(@"should flush storage to disk and clear transient network caches", ^{
                    session should_not have_received(@selector(flushWithCompletionHandler:));
                });

                it(@"should make true isInvalidateSession ", ^{
                    subject.isInvalidateSession should be_truthy;
                });
            });
        });

        context(@"When request is made for search", ^{
            beforeEach(^{
                defaults stub_method(@selector(objectForKey:)).and_return(@"some-new-search-text");
                request = nice_fake_for([NSURLRequest class]);
                request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"some-url"]);
                request stub_method(@selector(allHTTPHeaderFields)).and_return(@{RequestMadeForSearchWithHeaderKey:@"some-search-text"});
                promise = [subject promiseWithRequest:request];
            });

            it(@"should send the request to the session", ^{
                session should have_received(@selector(dataTaskWithRequest:completionHandler:))
                .with(request, Arguments::anything);
            });

            it(@"should resume the data task ", ^{
                task should have_received(@selector(resume));
            });

            context(@"when the session is invalidate", ^{
                beforeEach(^{
                    [subject doorKeeperDidLogOut:doorKeeper];
                });

                it(@"isInvalidateSession should be true", ^{
                    subject.isInvalidateSession should be_truthy;
                });

                it(@"should create new session  ", ^{
                    subject.session should be_same_instance_as(session);
                });

            });

            context(@"when the request succeeds with data", ^{
                __block NSData *data;
                __block MyNSURLResponse *response;

                beforeEach(^{
                    data = nice_fake_for([NSData class]);
                    response = nice_fake_for([MyNSURLResponse class]);

                });

                context(@"When valid status code", ^{

                    context(@"When valid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should reject the promise with the error", ^{
                            promise.error.domain should equal(RepliconNoAlertErrorDomain);
                            promise.error.userInfo[@"NSErrorFailingURLStringKey"] should equal(@"some-url");
                        });
                    });

                    context(@"When invalid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            [subject doorKeeperDidLogOut:doorKeeper];
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should reject the promise with the error", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(InvalidUserSessionRequestDomain);
                        });
                    });

                });

                context(@"When not valid status code", ^{

                    context(@"When valid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)403);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(RepliconFailureStatusCodeDomain);
                            promise.error.userInfo[@"NSErrorFailingURLStringKey"] should equal(@"my-special-URL");
                        });
                    });
                    context(@"When invalid session", ^{
                        beforeEach(^{
                            response stub_method(@selector(statusCode)).and_return((NSInteger)403);
                            response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                            [subject doorKeeperDidLogOut:doorKeeper];
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.error should_not be_nil;
                            promise.error.domain should equal(InvalidUserSessionRequestDomain);
                        });
                    });

                });

                context(@"When syncing pending queues", ^{
                    __block MyNSURLResponse *response;
                    __block NSError *error;
                    __block NSData *data;
                    beforeEach(^{
                        response = nice_fake_for([MyNSURLResponse class]);
                        error = nice_fake_for([NSError class]);
                        response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                        data=nice_fake_for([NSData class]);
                        NSDictionary *header = [[NSDictionary alloc]initWithObjectsAndKeys:
                                                RequestMadeWhilePendingQueueSyncHeaderValue,
                                                RequestMadeWhilePendingQueueSyncHeaderKey,
                                                nil];

                        request stub_method(@selector(allHTTPHeaderFields)).again().and_return(header);

                    });

                    context(@"when request fails", ^{
                        beforeEach(^{
                            simulateNetworkResponse(nil, nil, error);
                        });
                        it(@"should resolve the promise with an error", ^{
                             promise.error should_not be_nil;
                             promise.error.domain should equal(InvalidUserSessionRequestDomain);
                        });
                    });

                    context(@"when request passes", ^{
                        beforeEach(^{
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should resolve the promise with the data", ^{
                            promise.value should be_same_instance_as(data);
                        });
                    });



                });

            });

            context(@"when user click on logout button", ^{
                beforeEach(^{
                    [subject doorKeeperDidLogOut:doorKeeper];
                });

                it(@"isInvalidateSession should be true", ^{
                    subject.isInvalidateSession should be_truthy;
                });

                it(@"should create new session  ", ^{
                    subject.session should be_same_instance_as(session);
                });

            });

            describe(@"when the request fails with an error", ^{

                context(@"When valid session", ^{
                    __block NSError *error;
                    __block NSData *failedData;
                    __block MyNSURLResponse *response;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(code)).and_return((NSInteger)500);
                        error stub_method(@selector(domain)).and_return(RandomErrorDomain);
                        failedData=nice_fake_for([NSData class]);
                        response = nice_fake_for([MyNSURLResponse class]);
                        response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                        simulateNetworkResponse(failedData, response, error);
                    });

                    it(@"should resolve the promise with an error", ^{
                        promise.error.code should equal(500);
                        promise.error.domain should equal(RandomErrorDomain);
                    });

                    it(@"should match the error userinfo", ^{
                        promise.error.userInfo[@"failedData"] should equal(failedData);
                    });
                });

                context(@"When invalid session", ^{
                    __block MyNSURLResponse *response;
                    __block NSError *error;
                    __block NSData *failedData;
                    beforeEach(^{
                        response = nice_fake_for([MyNSURLResponse class]);
                        error = nice_fake_for([NSError class]);
                        response stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
                        [subject doorKeeperDidLogOut:doorKeeper];
                        failedData=nice_fake_for([NSData class]);
                        simulateNetworkResponse(failedData, response, error);
                    });

                    it(@"should resolve the promise with an error", ^{
                        promise.error should_not be_nil;
                        promise.error.domain should equal(InvalidUserSessionRequestDomain);

                    });
                    it(@"should resolve the promise with an error", ^{
                        promise.error.userInfo[@"failedData"] should equal(failedData);
                    });

                    it(@"should match the error userinfo", ^{
                        promise.error.userInfo[@"failedData"] should equal(failedData);
                    });
                });

            });

            context(@"when user click on logout button", ^{
                beforeEach(^{
                    [subject doorKeeperDidLogOut:doorKeeper];
                });

                it(@"should invalidate And Cancel all request", ^{
                    session should have_received(@selector(invalidateAndCancel));
                });

                it(@"should empty all cookies, cache and credential stores, removes disk files", ^{
                    session should_not have_received(@selector(resetWithCompletionHandler:));
                });
                
                it(@"should flush storage to disk and clear transient network caches", ^{
                    session should_not have_received(@selector(flushWithCompletionHandler:));
                });
                
                it(@"should make true isInvalidateSession ", ^{
                    subject.isInvalidateSession should be_truthy;
                });
            });
            
            context(@"When invalid session and session invalidated and cancelled", ^{
                __block MyNSURLResponse *response;
                __block NSError *error;
                beforeEach(^{
                    response = nice_fake_for([MyNSURLResponse class]);
                    error = nice_fake_for([NSError class]);
                    error stub_method(@selector(code)).and_return((NSInteger)-999);
                    simulateNetworkResponse(nil, nil, error);
                });
                
                it(@"should resolve the promise with an error", ^{
                    promise.error should_not be_nil;
                    promise.error.domain should equal(InvalidUserSessionRequestDomain);
                    
                });
                
            });
        });

        context(@"When request is made for most recent punch", ^{

            context(@"request is older than recent punch", ^{
                beforeEach(^{
                    defaults stub_method(@selector(objectForKey:)).with(@"PunchRecordedLastModifiedTime").and_return(@"Wed, 06 Jul 2016 16:07:50 +0530");
                    request = nice_fake_for([NSURLRequest class]);
                    request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"mobile-backend/TimePunchFlowService1.svc/GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"]);
                    request stub_method(@selector(allHTTPHeaderFields)).and_return(@{MostRecentPunchDateIdentifierHeader:@"Wed, 06 Jul 2016 16:07:45 +0530"});
                    promise = [subject promiseWithRequest:request];
                });


                context(@"when the request succeeds with data", ^{
                    __block NSData *data;
                    __block MyNSURLResponse *response;

                    beforeEach(^{
                        data = nice_fake_for([NSData class]);
                        response = nice_fake_for([MyNSURLResponse class]);

                    });

                    context(@"When valid status code", ^{

                        context(@"When valid session", ^{
                            beforeEach(^{
                                response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                                simulateNetworkResponse(data, response, nil);
                            });
                            it(@"should reject the promise with the error", ^{
                                promise.error.domain should equal(RepliconNoAlertErrorDomain);
                                promise.error.userInfo[@"NSErrorFailingURLStringKey"] should be_nil;
                            });

                            it(@"should not resolve the promise with the data", ^{
                                promise.value should be_nil;
                            });
                        });

                        context(@"When old service response is same as current received response", ^{
                            beforeEach(^{
                                 defaults stub_method(@selector(objectForKey:)).with(@"oldMostRecentPunchData").and_return(data);
                                response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                                simulateNetworkResponse(data, response, nil);
                            });
                            it(@"should reject the promise with the error", ^{
                                promise.error.domain should equal(RepliconNoAlertErrorDomain);
                                promise.error.userInfo[@"NSErrorFailingURLStringKey"] should be_nil;
                            });

                            it(@"should not resolve the promise with the data", ^{
                                promise.value should be_nil;
                            });
                        });
                        
                        
                    });
                    
                });

            });

            context(@"request is newer than recent punch", ^{
                beforeEach(^{
                    defaults stub_method(@selector(objectForKey:)).with(@"PunchRecordedLastModifiedTime").and_return(@"Wed, 06 Jul 2016 16:07:50 +0530");
                    request = nice_fake_for([NSURLRequest class]);
                    request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"mobile-backend/TimePunchFlowService1.svc/GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"]);
                    request stub_method(@selector(allHTTPHeaderFields)).and_return(@{MostRecentPunchDateIdentifierHeader:@"Wed, 06 Jul 2016 16:07:55 +0530"});
                    promise = [subject promiseWithRequest:request];
                });


                context(@"when the request succeeds with data", ^{
                    __block NSData *data;
                    __block MyNSURLResponse *response;

                    beforeEach(^{
                        data = nice_fake_for([NSData class]);
                        response = nice_fake_for([MyNSURLResponse class]);

                    });

                    context(@"When valid status code", ^{

                        context(@"When valid session", ^{
                            beforeEach(^{
                                response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                                simulateNetworkResponse(data, response, nil);
                            });
                            it(@"should resolve the promise with the data", ^{
                                promise.value should be_same_instance_as(data);
                            });
                            it(@"should not reject the promise with the error", ^{
                                promise.error.domain should be_nil;
                                promise.error.userInfo[@"NSErrorFailingURLStringKey"] should be_nil;
                            });
                        });

                        
                    });

                    context(@"When old service response is same as current received response", ^{
                        beforeEach(^{
                            defaults stub_method(@selector(objectForKey:)).with(@"oldMostRecentPunchData").and_return(data);
                            response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                            simulateNetworkResponse(data, response, nil);
                        });
                        it(@"should reject the promise with the error", ^{
                            promise.error.domain should equal(RepliconNoAlertErrorDomain);
                            promise.error.userInfo[@"NSErrorFailingURLStringKey"] should be_nil;
                        });

                        it(@"should not resolve the promise with the data", ^{
                            promise.value should be_nil;
                        });
                    });

                });
                
            });


       });

        context(@"When request is made for GetTimesheetSummary", ^{

            context(@"request is older than recent punch", ^{
                beforeEach(^{
                    defaults stub_method(@selector(objectForKey:)).with(@"PunchRecordedLastModifiedTime").and_return(@"Wed, 06 Jul 2016 16:07:50 +0530");
                    request = nice_fake_for([NSURLRequest class]);
                    request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"mobile-backend/TimesheetFlowService1.svc/GetTimesheetSummary"]);
                    request stub_method(@selector(allHTTPHeaderFields)).and_return(@{GetTimesheetSummaryDateIdentifierHeader:@"Wed, 06 Jul 2016 16:07:45 +0530"});
                    promise = [subject promiseWithRequest:request];
                });


                context(@"when the request succeeds with data", ^{
                    __block NSData *data;
                    __block MyNSURLResponse *response;

                    beforeEach(^{
                        data = nice_fake_for([NSData class]);
                        response = nice_fake_for([MyNSURLResponse class]);

                    });

                    context(@"When valid status code", ^{

                        context(@"When valid session", ^{
                            beforeEach(^{
                                response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                                simulateNetworkResponse(data, response, nil);
                            });
                            it(@"should reject the promise with the error", ^{
                                promise.error.domain should equal(RepliconNoAlertErrorDomain);
                                promise.error.userInfo[@"NSErrorFailingURLStringKey"] should be_nil;
                            });

                            it(@"should not resolve the promise with the data", ^{
                                promise.value should be_nil;
                            });
                        });

                    });

                });

            });

            context(@"request is newer than recent punch", ^{
                beforeEach(^{
                    defaults stub_method(@selector(objectForKey:)).with(@"PunchRecordedLastModifiedTime").and_return(@"Wed, 06 Jul 2016 16:07:50 +0530");
                    request = nice_fake_for([NSURLRequest class]);
                    request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"mobile/TimesheetFlowService1.svc/GetTimesheetSummary"]);
                    request stub_method(@selector(allHTTPHeaderFields)).and_return(@{GetTimesheetSummaryDateIdentifierHeader:@"Wed, 06 Jul 2016 16:07:55 +0530"});
                    promise = [subject promiseWithRequest:request];
                });


                context(@"when the request succeeds with data", ^{
                    __block NSData *data;
                    __block MyNSURLResponse *response;

                    beforeEach(^{
                        data = nice_fake_for([NSData class]);
                        response = nice_fake_for([MyNSURLResponse class]);

                    });

                    context(@"When valid status code", ^{

                        context(@"When valid session", ^{
                            beforeEach(^{
                                response stub_method(@selector(statusCode)).and_return((NSInteger)200);
                                simulateNetworkResponse(data, response, nil);
                            });
                            it(@"should resolve the promise with the data", ^{
                                promise.value should be_same_instance_as(data);
                            });
                            it(@"should not reject the promise with the error", ^{
                                promise.error.domain should be_nil;
                                promise.error.userInfo[@"NSErrorFailingURLStringKey"] should be_nil;
                            });
                        });


                    });
                    
                });
                
            });
            
            
        });
        
        
        
    });
});

SPEC_END
