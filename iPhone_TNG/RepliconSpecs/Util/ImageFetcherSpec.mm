#import <Cedar/Cedar.h>
#import "ImageFetcher.h"
#import "URLSessionClient.h"
#import "PSHKFakeOperationQueue.h"
#import <KSDeferred/KSDeferred.h>
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ImageFetcherSpec)

describe(@"ImageFetcher", ^{
    __block ImageFetcher *subject;
    __block URLSessionClient<CedarDouble> *client;
    __block PSHKFakeOperationQueue *queue;
    __block UIScreen *screen;
    __block NSCache *urltoImageCache;
    __block NSMutableDictionary *deferredCache;
    __block id<BSBinder, BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        client = nice_fake_for([URLSessionClient class]);
        [injector bind:[URLSessionClient class] toInstance:client];

        queue = [[PSHKFakeOperationQueue alloc] init];
        queue.runSynchronously = NO;
        [injector bind:InjectorKeyMainQueue toInstance:queue];

        screen = nice_fake_for([UIScreen class]);
        [injector bind:InjectorKeyMainScreen toInstance:screen];

        urltoImageCache = [[NSCache alloc] init];
        [injector bind:InjectorKeyImageCache toInstance:urltoImageCache];

        deferredCache = [[NSMutableDictionary alloc] init];
        [injector bind:InjectorKeyImageURLToDeferredCache toInstance:deferredCache];

        subject = [injector getInstance:[ImageFetcher class]];
    });

    describe(@"promiseWithImageURL:", ^{
        __block NSURL *imageURL;
        __block KSDeferred *deferred;
        __block KSPromise *promise;

        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            imageURL = [NSURL URLWithString:@"http://example.com/avatar.jpg"];

            client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
            promise = [subject promiseWithImageURL:imageURL];
        });

        it(@"should sent a request to the client", ^{
            NSURLRequest *expectedRequest = [[NSURLRequest alloc] initWithURL:imageURL];
            client should have_received(@selector(promiseWithRequest:)).with(expectedRequest);
        });

        context(@"before the request returns NSData", ^{
            __block KSPromise *anotherPromise;
            beforeEach(^{
                [client reset_sent_messages];

                anotherPromise = [subject promiseWithImageURL:imageURL];
            });

            it(@"should not make a new request to the client ", ^{
                client should_not have_received(@selector(promiseWithRequest:));
            });

            it(@"should not create another deferred", ^{
                anotherPromise should be_same_instance_as(promise);
            });

            context(@"when another instance requests the same URL", ^{
                __block KSPromise *anotherInstancePromise;

                beforeEach(^{
                    ImageFetcher *anotherImageFetcher = [injector getInstance:[ImageFetcher class]];
                    anotherInstancePromise = [anotherImageFetcher promiseWithImageURL:imageURL];
                });

                it(@"should not make a new request to the client ", ^{
                    client should_not have_received(@selector(promiseWithRequest:));
                });

                it(@"should not create another deferred", ^{
                    anotherInstancePromise should be_same_instance_as(promise);
                });
            });
        });

        context(@"after the request returns NSData", ^{
            __block NSData *rawJPEGData;
            __block UIImage *expectedDecodedAndScaledImage;

            beforeEach(^{
                screen stub_method(@selector(scale)).and_return((CGFloat)1.0);
                UIImage *image = [UIImage imageNamed:@"Avatar_placeholder_sm"];
                rawJPEGData = UIImageJPEGRepresentation(image, 1.0);
                expectedDecodedAndScaledImage = [UIImage imageWithData:rawJPEGData scale:(CGFloat)1.0];

                [deferred resolveWithValue:rawJPEGData];
            });

            context(@"when the next operation on the queue runs", ^{
                beforeEach(^{
                    [queue runNextOperation];
                });

                it(@"should deserialize the image and resolve the promise with it", ^{
                    __block UIImage *receivedImage;
                    [promise then:^id(UIImage *image) {
                        receivedImage = image;
                        return nil;
                    } error:nil];
                    receivedImage should be_instance_of([UIImage class]);
                    [UIImagePNGRepresentation(receivedImage) isEqualToData:UIImagePNGRepresentation(expectedDecodedAndScaledImage)] should be_truthy;
                });

                it(@"should evict the deferredCache", ^{
                    deferredCache should be_empty;
                });

                context(@"when the image is then requested subsequent time", ^{
                    it(@"should immediately resolve the promise with the value from the previous request", ^{
                        KSPromise *promise = [subject promiseWithImageURL:imageURL];

                        promise.fulfilled should be_truthy;

                        [UIImagePNGRepresentation(promise.value) isEqualToData:UIImagePNGRepresentation(expectedDecodedAndScaledImage)] should be_truthy;
                    });
                });

                context(@"when the image is then requested subsequent time with another fetcher instance", ^{
                    __block ImageFetcher *otherImageFetcher;
                    beforeEach(^{
                        otherImageFetcher = [injector getInstance:[ImageFetcher class]];
                    });

                    it(@"should immediately resolve the promise with the value from the previous request", ^{
                        KSPromise *promise = [otherImageFetcher promiseWithImageURL:imageURL];

                        promise.fulfilled should be_truthy;

                        [UIImagePNGRepresentation(promise.value) isEqualToData:UIImagePNGRepresentation(expectedDecodedAndScaledImage)] should be_truthy;
                    });
                });
            });
        });

        context(@"when the request fails with an error", ^{
            __block NSError *error;

            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });

            context(@"when the next operation on the queue runs", ^{
                beforeEach(^{
                    [queue runNextOperation];
                });
                
                it(@"should resolve the promise with an error", ^{
                    promise.error should be_same_instance_as(error);
                });

                it(@"should evict the deferred from the cache", ^{
                    deferredCache should be_empty;
                });
            });
        });
    });
});

SPEC_END
