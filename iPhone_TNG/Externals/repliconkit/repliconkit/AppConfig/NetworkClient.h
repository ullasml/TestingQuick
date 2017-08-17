
#import <Foundation/Foundation.h>
@class KSPromise;

@interface NetworkClient : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSession:(NSURLSession *)session queue:(NSOperationQueue *)queue NS_DESIGNATED_INITIALIZER;

- (KSPromise *)promiseWithRequest:(NSURLRequest *)request;

@end
