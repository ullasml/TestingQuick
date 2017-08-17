#import "URLSessionListener.h"


@interface URLSessionListener ()

@property (nonatomic) NSHashTable *observers;

@end


@implementation URLSessionListener

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.observers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addObserver:(id<URLSessionListenerObserver>)observer
{
    [self.observers addObject:observer];
}

#pragma mark - <NSURLSessionDownloadDelegate>

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSData *data = [NSData dataWithContentsOfURL:location];

    for (id<URLSessionListenerObserver> observer in self.observers)
    {
        [observer urlSessionListener:self downloadTask:downloadTask didFinishDownloadingData:data];
    }
}

#pragma mark - <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    for (id<URLSessionListenerObserver> observer in self.observers)
    {
        [observer urlSessionListener:self task:task didCompleteWithError:error];
    }
}

#pragma mark - <NSURLSessionDelegate>

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    if (self.completionHandler)
    {
        self.completionHandler();
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

@end
