#import <Foundation/Foundation.h>


@class KSPromise;


@protocol RequestPromiseClient <NSObject>

- (KSPromise *)promiseWithRequest:(NSURLRequest *)request;

@end
