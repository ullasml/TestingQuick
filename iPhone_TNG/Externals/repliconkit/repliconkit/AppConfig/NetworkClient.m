
#import "NetworkClient.h"
#import <KSDeferred/KSDeferred.h>

@interface NetworkClient ()
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSOperationQueue *queue;
@end

@implementation NetworkClient

typedef void (^Complestion)(id data,NSError *error);


- (instancetype)initWithSession:(NSURLSession *)session queue:(NSOperationQueue *)queue
{
    self = [super init];
    if (self) {
        self.session = session;
        self.queue = queue;
    }
    return self;
}

- (KSPromise *)promiseWithRequest:(NSURLRequest *)request
{
    KSDeferred *deferred = [[KSDeferred alloc] init];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         
                                                         __strong typeof(weakSelf) strongSelf = weakSelf;
                                                         if (error) {
                                                             [strongSelf.queue addOperationWithBlock:^{
                                                                 [deferred rejectWithError:error];
                                                             }];
                                                         } else {
                                                             [strongSelf parseData:data completion:^(id data, NSError *error) {
                                                                 if (error) {
                                                                     [strongSelf.queue addOperationWithBlock:^{
                                                                         [deferred rejectWithError:error];
                                                                     }];
                                                                 } else {
                                                                     [strongSelf.queue addOperationWithBlock:^{
                                                                         [deferred resolveWithValue:data];
                                                                     }];
                                                                 }
                                                             }];
                                                         }
                                                     }];
    [dataTask resume];
    
    return deferred.promise;
}

- (void)parseData:(NSData *)data completion:(Complestion)completion {
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        if (completion) {
            completion(nil, error);
        }
    } else {
        if (completion) {
            completion(json, nil);
        }
    }
}

@end
