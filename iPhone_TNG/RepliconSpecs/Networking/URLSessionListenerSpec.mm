#import <Cedar/Cedar.h>
#import "URLSessionListener.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(URLSessionListenerSpec)

describe(@"URLSessionListener", ^{
    __block URLSessionListener *subject;
    __block id<URLSessionListenerObserver, CedarDouble> observerA;
    __block id<URLSessionListenerObserver, CedarDouble> observerB;

    beforeEach(^{
        subject = [[URLSessionListener alloc] init];

        observerA = nice_fake_for(@protocol(URLSessionListenerObserver));
        observerB = nice_fake_for(@protocol(URLSessionListenerObserver));

        [subject addObserver:observerA];
        [subject addObserver:observerB];
    });

    it(@"should inform its observers when a download task is completed", ^{
        NSURLSessionDownloadTask *task = fake_for([NSURLSessionDownloadTask class]);

        NSData *data = [@"My Special Data" dataUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"whatever"]];
        [data writeToURL:url atomically:YES];

        [subject URLSession:[NSURLSession sharedSession] downloadTask:task didFinishDownloadingToURL:url];

        observerA should have_received(@selector(urlSessionListener:downloadTask:didFinishDownloadingData:)).with(subject, task, data);
        observerB should have_received(@selector(urlSessionListener:downloadTask:didFinishDownloadingData:)).with(subject, task, data);
    });

    it(@"should inform its observers when any task is completed", ^{
        NSURLSessionTask *task = fake_for([NSURLSessionTask class]);
        NSError *error = fake_for([NSError class]);

        [subject URLSession:[NSURLSession sharedSession] task:task didCompleteWithError:error];

        observerA should have_received(@selector(urlSessionListener:task:didCompleteWithError:)).with(subject, task, error);
        observerB should have_received(@selector(urlSessionListener:task:didCompleteWithError:)).with(subject, task, error);
    });

    describe(@"-URLSessionDidFinishEventsForBackgroundURLSession:", ^{
        context(@"when a completion handler has been set", ^{
            __block BOOL completionHandlerCalled;

            beforeEach(^{
                completionHandlerCalled = NO;
                subject.completionHandler = ^{
                    completionHandlerCalled =  YES;
                };
            });

            it(@"should call the completion handler", ^{
                [subject URLSessionDidFinishEventsForBackgroundURLSession:(id)[NSNull null]];

                completionHandlerCalled should be_truthy;
            });
        });

        context(@"when a completion handler hasn't been set", ^{
            it(@"should not raise an exception", ^{
                [subject URLSessionDidFinishEventsForBackgroundURLSession:(id)[NSNull null]];
            });
        });
    });

    describe(@"URLSession:didReceiveChallenge:completionHandler:", ^{

        __block BOOL handlerCalled = NO;
        __block NSURLAuthenticationChallenge *challenge;

        void (^_sessionCompletionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential) = ^void(NSURLSessionAuthChallengeDisposition,NSURLCredential *) {

            handlerCalled = YES;
        };

        beforeEach(^{
            challenge = nice_fake_for([NSURLAuthenticationChallenge class]);

        });

        it(@"should perform the completionHandler", ^{
            handlerCalled should be_falsy;
            [subject URLSession:[NSURLSession sharedSession] didReceiveChallenge:challenge completionHandler:_sessionCompletionHandler];
            handlerCalled should be_truthy;

        });

    });
});

SPEC_END
