
#import "ImageFetcher.h"
#import <KSDeferred/KSPromise.h>
#import "URLSessionClient.h"
#import <KSDeferred/KSDeferred.h>


@interface ImageFetcher ()

@property (nonatomic) URLSessionClient *client;
@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic) CGFloat screenScale;
@property (nonatomic) NSMutableDictionary *urlToDeferredMap;
@property (nonatomic) NSCache *urlToImageCache;

@end


@implementation ImageFetcher

- (instancetype)initWithURLSessionClient:(URLSessionClient *)urlSessionClient
                           deferredCache:(NSMutableDictionary *)deferredCache
                             screenScale:(CGFloat)screenScale
                              imageCache:(NSCache *)imageCache
                                   queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        self.queue = queue;
        self.screenScale = screenScale;
        self.client = urlSessionClient;
        self.urlToImageCache = imageCache;
        self.urlToDeferredMap = deferredCache;
    }
    return self;
}

- (KSPromise *)promiseWithImageURL:(NSURL *)imageURL
{
    UIImage *image = [self.urlToImageCache objectForKey:imageURL];
    if (image) {
        KSDeferred *deferred = [[KSDeferred alloc] init];
        [deferred resolveWithValue:image];
        return deferred.promise;
    }

    KSDeferred *existingDeferred = self.urlToDeferredMap[imageURL];
    if (existingDeferred) {
        return existingDeferred.promise;
    }

    KSDeferred *deferred = [[KSDeferred alloc] init];
    self.urlToDeferredMap[imageURL] = deferred;

    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    KSPromise *dataPromise = [self.client promiseWithRequest:request];

    [dataPromise then:^id(NSData *data) {
        UIImage *image = [UIImage imageWithData:data scale:self.screenScale];

        [self.queue addOperationWithBlock:^{
            [deferred resolveWithValue:image];
            [self.urlToDeferredMap removeObjectForKey:imageURL];
            [self.urlToImageCache setObject:image forKey:imageURL];
        }];

        return nil;
    } error:^id(NSError *error) {
        [self.queue addOperationWithBlock:^{
            [self.urlToDeferredMap removeObjectForKey:imageURL];
            [deferred rejectWithError:error];
        }];

        return nil;
    }];

    return deferred.promise;
}

@end
