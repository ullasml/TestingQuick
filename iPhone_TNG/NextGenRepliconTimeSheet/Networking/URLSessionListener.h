#import <Foundation/Foundation.h>


@protocol URLSessionListenerObserver;


@interface URLSessionListener : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, copy) void (^completionHandler)(void);

- (void)addObserver:(id<URLSessionListenerObserver>)observer;

@end


@protocol URLSessionListenerObserver

- (void)urlSessionListener:(URLSessionListener *)urlSessionListener downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingData:(NSData *)data;

- (void)urlSessionListener:(URLSessionListener *)urlSessionListener task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

@end
