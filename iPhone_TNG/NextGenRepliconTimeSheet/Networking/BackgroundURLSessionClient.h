#import <Foundation/Foundation.h>
#import "RequestPromiseClient.h"
#import "URLSessionListener.h"


@interface BackgroundURLSessionClient : NSObject <URLSessionListenerObserver, RequestPromiseClient>

@property (nonatomic, readonly) NSURLSession *session;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLSessionListener:(URLSessionListener *)urlSessionListener
                                urlSession:(NSURLSession *)session;

@end
