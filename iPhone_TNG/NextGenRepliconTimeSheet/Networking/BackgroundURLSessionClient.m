#import "BackgroundURLSessionClient.h"
#import <KSDeferred/KSDeferred.h>


@interface BackgroundURLSessionClient ()

@property (nonatomic) NSURLSession *session;

@property (nonatomic) NSMutableDictionary *deferreds;

@end


@implementation BackgroundURLSessionClient

- (instancetype)initWithURLSessionListener:(URLSessionListener *)urlSessionListener
                                urlSession:(NSURLSession *)session
{
    self = [super init];
    if (self)
    {
        self.session = session;

        [urlSessionListener addObserver:self];

        self.deferreds = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <URLSessionListenerObserver>

- (void)urlSessionListener:(URLSessionListener *)urlSessionListener downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingData:(NSData *)data
{
    KSDeferred *deferred = self.deferreds[@(downloadTask.taskIdentifier)];
    [self.deferreds removeObjectForKey:@(downloadTask.taskIdentifier)];
    [deferred resolveWithValue:data];
}

- (void)urlSessionListener:(URLSessionListener *)urlSessionListener task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
    {
        KSDeferred *deferred = self.deferreds[@(task.taskIdentifier)];
        [self.deferreds removeObjectForKey:@(task.taskIdentifier)];
        [deferred rejectWithError:error];
    }
}

#pragma mark - <RequestPromiseClient>

- (KSPromise *)promiseWithRequest:(NSURLRequest *)request
{
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];

    KSDeferred *deferred = [[KSDeferred alloc] init];
    self.deferreds[@(task.taskIdentifier)] = deferred;

    [task resume];

    return deferred.promise;
}

@end
