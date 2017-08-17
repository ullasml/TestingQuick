

#import <Foundation/Foundation.h>
#import "URLSessionClient.h"

@class KSPromise;


@interface ImageFetcher : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLSessionClient:(URLSessionClient *)urlSessionClient
                           deferredCache:(NSMutableDictionary *)deferredCache
                             screenScale:(CGFloat)screenScale
                              imageCache:(NSCache *)imageCache
                                   queue:(NSOperationQueue *)queue;

-(KSPromise *)promiseWithImageURL:(NSURL *)imageURL;

@end
