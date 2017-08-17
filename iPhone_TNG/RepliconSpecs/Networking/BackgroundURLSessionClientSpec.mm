#import <Cedar/Cedar.h>
#import "BackgroundURLSessionClient.h"
#import "URLSessionListener.h"
#import <KSDeferred/KSPromise.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MyNewNSURLSessionDownloadTask : NSURLSessionDownloadTask
@property (assign) NSUInteger  taskIdentifier;  /* Temporarily overidden */
@end

@implementation MyNewNSURLSessionDownloadTask
@synthesize taskIdentifier;
@end


SPEC_BEGIN(BackgroundURLSessionClientSpec)

describe(@"BackgroundURLSessionClient", ^{
    __block BackgroundURLSessionClient *subject;
    __block URLSessionListener *urlSessionListener;
    __block NSURLSession *session;

    beforeEach(^{
        session = fake_for([NSURLSession class]);

        urlSessionListener = [[URLSessionListener alloc]  init];
        spy_on(urlSessionListener);

        subject = [[BackgroundURLSessionClient alloc] initWithURLSessionListener:urlSessionListener
                                                                      urlSession:session];
    });

    it(@"should add itself as the URL session listener's observer", ^{
        urlSessionListener should have_received(@selector(addObserver:)).with(subject);
    });

    describe(@"promiseWithRequest:", ^{
        __block NSURLRequest *request;
        __block KSPromise *promise;
        __block NSData *data;
        __block NSMutableArray *tasks;
        __block NSUInteger taskIdentifier;

        beforeEach(^{
            request = fake_for([NSURLRequest class]);

            tasks = [NSMutableArray array];
            taskIdentifier = 0;

            session stub_method(@selector(downloadTaskWithRequest:)).with(request).and_do_block(^NSURLSessionTask *(NSURLRequest *req){
                MyNewNSURLSessionDownloadTask *task = nice_fake_for([MyNewNSURLSessionDownloadTask class]);
                task stub_method(@selector(taskIdentifier)).and_return(taskIdentifier++);
                [tasks addObject:task];
                return task;
            });

            promise = [subject promiseWithRequest:request];

            data = fake_for([NSData class]);
        });

        it(@"should send the request", ^{
            tasks.firstObject should have_received(@selector(resume));
        });

        it(@"should resolve the promise when the task is done", ^{
            [subject urlSessionListener:nil downloadTask:tasks.firstObject didFinishDownloadingData:data];

            promise.value should be_same_instance_as(data);
        });

        it(@"should support multiple download tasks running at once", ^{
            KSPromise *secondPromise =  [subject promiseWithRequest:request];

            [subject urlSessionListener:nil downloadTask:tasks.lastObject didFinishDownloadingData:data];

            secondPromise.value should equal(data);
            promise.fulfilled should be_falsy;

            [subject urlSessionListener:nil downloadTask:tasks.firstObject didFinishDownloadingData:data];

            promise.value should be_same_instance_as(data);
        });

        it(@"should not resolve the same deferred twice", ^{
            ^{
                [subject urlSessionListener:nil downloadTask:tasks.firstObject didFinishDownloadingData:data];
                [subject urlSessionListener:nil downloadTask:tasks.firstObject didFinishDownloadingData:data];
            } should_not raise_exception;
        });

        it(@"should reject the promise when the task fails", ^{
            NSError *error = fake_for([NSError class]);

            [subject urlSessionListener:nil task:tasks.firstObject didCompleteWithError:error];

            promise.error should be_same_instance_as(error);
        });

        it(@"should not reject or fulfill the promise when the task succeeds", ^{
            [subject urlSessionListener:nil task:tasks.firstObject didCompleteWithError:nil];

            promise.fulfilled should_not be_truthy;
            promise.rejected should_not be_truthy;
            promise.cancelled should_not be_truthy;
        });

        it(@"should not reject the same deferred twice", ^{
            NSError *error = fake_for([NSError class]);

            ^{
                [subject urlSessionListener:nil task:tasks.firstObject didCompleteWithError:error];
                [subject urlSessionListener:nil task:tasks.firstObject didCompleteWithError:error];
            } should_not raise_exception;
        });
    });
});

SPEC_END
