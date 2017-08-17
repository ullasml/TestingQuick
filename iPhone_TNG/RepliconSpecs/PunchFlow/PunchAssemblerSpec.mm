#import "Cedar.h"
#import <CoreLocation/CoreLocation.h>
#import "PunchAssembler.h"
#import "DateProvider.h"
#import "KSDeferred.h"
#import "LocalPunch.h"
#import "Constants.h"
#import "Geolocation.h"
#import "BreakType.h"
#import "PunchRulesStorage.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchAssemblerSpec)

describe(@"PunchAssembler", ^{
    __block PunchAssembler *subject;
    __block PunchRulesStorage *punchRulesStorage;
    __block NSDate *expectedDate;

    beforeEach(^{
        punchRulesStorage = nice_fake_for([PunchRulesStorage class]);
        expectedDate = [NSDate dateWithTimeIntervalSince1970:0];

        subject = [[PunchAssembler alloc] initWithPunchRulesStorage:punchRulesStorage];
    });

    describe(NSStringFromSelector(@selector(assembleIncompletePunch:imagePromise:geolocationPromise:punchDeferred:)), ^{
        __block LocalPunch *incompletePunch;

        describe(@"creating a punch and resolving a deferred", ^{
            __block KSPromise *punchPromise;
            __block KSDeferred *punchDeferred;
            __block LocalPunch *receivedPunch;
            __block BreakType *mealBreak;

            beforeEach(^{
                mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break-uri"];
                incompletePunch = [[LocalPunch alloc] initWithDate:expectedDate
                                                   actionType:PunchActionTypeStartBreak
                                                    breakType:mealBreak
                                                     location:nil
                                                      address:nil
                                                        image:nil];

                punchDeferred = [[KSDeferred alloc] init];
                punchPromise = punchDeferred.promise;

                [punchPromise then:^id(LocalPunch *punch) {
                    receivedPunch = punch;
                    return nil;
                } error:^id(NSError *error) {
                    return nil;
                }];
            });

            describe(@"when the rules require neither location or image", ^{
                it(@"should resolve the promise with a valid punch", ^{
                    [subject assembleIncompletePunch:incompletePunch
                                                    imagePromise:nil
                                              geolocationPromise:nil
                                       punchDeferred:punchDeferred];;

                    LocalPunch *expectedPunch = [[LocalPunch alloc] initWithDate:expectedDate
                                                            actionType:PunchActionTypeStartBreak
                                                             breakType:mealBreak
                                                              location:nil
                                                               address:nil
                                                                 image:nil];

                    receivedPunch should equal(expectedPunch);
                });
            });

            describe(@"when the rules require only an image", ^{
                __block KSDeferred *imageDeferred;

                beforeEach(^{
                    punchRulesStorage stub_method(@selector(selfieRequired)).and_return(YES);
                    imageDeferred = [[KSDeferred alloc] init];
                });

                context(@"when passing an unfulfilled image promise", ^{
                    beforeEach(^{
                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:imageDeferred.promise
                                      geolocationPromise:nil
                                           punchDeferred:punchDeferred];;
                    });

                    it(@"should not resolve the punch promise", ^{
                        punchPromise.fulfilled should be_falsy;
                    });
                });

                context(@"when passing in a fulfilled image promise", ^{
                    __block UIImage *fulfilledImage;

                    beforeEach(^{
                        fulfilledImage = [UIImage imageNamed:ExpensesImageUp];
                        [imageDeferred resolveWithValue:fulfilledImage];

                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:imageDeferred.promise
                                      geolocationPromise:nil
                                           punchDeferred:punchDeferred];;

                    });

                    it(@"should resolve the punch with the correct image", ^{
                        punchPromise.fulfilled should be_truthy;

                        LocalPunch *expectedPunch = [[LocalPunch alloc] initWithDate:expectedDate
                                                                actionType:PunchActionTypeStartBreak
                                                                 breakType:mealBreak
                                                                  location:nil
                                                                   address:nil
                                                                     image:fulfilledImage];

                        receivedPunch should equal(expectedPunch);

                    });
                });
            });

            describe(@"When the rules require only a location", ^{
                __block KSDeferred *geolocationDeferred;
                __block Geolocation *resolvedGeolocation;

                beforeEach(^{
                    geolocationDeferred = [[KSDeferred alloc] init];
                    punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(YES);
                });

                context(@"When passing an unfulfilled Geolocation promise", ^{

                    beforeEach(^{
                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:nil
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];;
                    });

                    it(@"should not resolve the punch promise", ^{
                        punchPromise.fulfilled should be_falsy;
                    });
                });

                context(@"When passing an fulfilled geolocation promise", ^{
                    beforeEach(^{
                        CLLocation *location = [[CLLocation alloc] initWithLatitude:1.0 longitude:2.0];
                        NSString *address = @"Some Magic Street";

                        resolvedGeolocation = [[Geolocation alloc] initWithLocation:location address:address];

                        [geolocationDeferred resolveWithValue:resolvedGeolocation];

                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:nil
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];
                    });

                    it(@"should resolve the punch with the correct location", ^{
                        punchPromise.fulfilled should be_truthy;

                        LocalPunch *expectedPunch = [[LocalPunch alloc] initWithDate:expectedDate
                                                                actionType:PunchActionTypeStartBreak
                                                                 breakType:mealBreak
                                                                  location:resolvedGeolocation.location
                                                                   address:resolvedGeolocation.address
                                                                     image:nil];

                        receivedPunch should equal(expectedPunch);

                    });

                });

                context(@"When passing a rejected geolocation promise", ^{
                    beforeEach(^{
                        [geolocationDeferred rejectWithError:nil];

                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:nil
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];
                    });

                    it(@"should resolve the punch with the correct location", ^{
                        punchPromise.fulfilled should be_truthy;

                        LocalPunch *expectedPunch = [[LocalPunch alloc] initWithDate:expectedDate
                                                                actionType:PunchActionTypeStartBreak
                                                                 breakType:mealBreak
                                                                  location:nil
                                                                   address:nil
                                                                     image:nil];

                        receivedPunch should equal(expectedPunch);
                    });
                });
            });

            describe(@"when the rules requires both an image and a location", ^{
                __block KSDeferred *imageDeferred;
                __block KSDeferred *geolocationDeferred;

                beforeEach(^{
                    punchRulesStorage stub_method(@selector(selfieRequired)).and_return(YES);
                    punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(YES);
                    imageDeferred = [[KSDeferred alloc] init];
                    geolocationDeferred = [[KSDeferred alloc] init];
                });

                describe(@"when passing an unfulfilled image promise and an unfulfilled geolocation promise", ^{
                    beforeEach(^{
                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:imageDeferred.promise
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];
                    });

                    it(@"should not resolve the punch promise", ^{
                        punchPromise.fulfilled should be_falsy;
                    });
                });

                describe(@"when passing a fulfilled image promise and a fulfilled geolocation promise", ^{
                    __block Geolocation *fulfilledGeolocation;
                    __block UIImage *fulfilledImage;

                    beforeEach(^{
                        fulfilledImage = [UIImage imageNamed:ExpensesImageUp];
                        [imageDeferred resolveWithValue:fulfilledImage];

                        CLLocation *location = [[CLLocation alloc] initWithLatitude:1.0 longitude:2.0];
                        NSString *address = @"Some Magic Street";

                        fulfilledGeolocation = [[Geolocation alloc] initWithLocation:location address:address];

                        [geolocationDeferred resolveWithValue:fulfilledGeolocation];
                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:imageDeferred.promise
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];
                    });

                    it(@"should resolve the punch with the correct values", ^{
                        punchPromise.fulfilled should be_truthy;

                        LocalPunch *expectedPunch = [[LocalPunch alloc] initWithDate:expectedDate
                                                                actionType:PunchActionTypeStartBreak
                                                                 breakType:mealBreak
                                                                  location:fulfilledGeolocation.location
                                                                   address:fulfilledGeolocation.address
                                                                     image:fulfilledImage];

                        receivedPunch should equal(expectedPunch);
                    });
                });

                describe(@"when passing a fulfilled image promise and a rejected geolocation promise", ^{
                    __block UIImage *fulfilledImage;

                    beforeEach(^{
                        fulfilledImage = [UIImage imageNamed:ExpensesImageUp];
                        [imageDeferred resolveWithValue:fulfilledImage];

                        [geolocationDeferred rejectWithError:nil];
                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:imageDeferred.promise
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];
                    });

                    it(@"should resolve the punch with the correct values", ^{
                        punchPromise.fulfilled should be_truthy;

                        LocalPunch *expectedPunch = [[LocalPunch alloc] initWithDate:expectedDate
                                                                actionType:PunchActionTypeStartBreak
                                                                 breakType:mealBreak
                                                                  location:nil
                                                                   address:nil
                                                                     image:fulfilledImage];

                        receivedPunch should equal(expectedPunch);
                    });
                });

                describe(@"when passing a fulfilled image promise and an unfullled geolocation promise", ^{
                    __block UIImage *fulfilledImage;

                    beforeEach(^{
                        fulfilledImage = [UIImage imageNamed:ExpensesImageUp];
                        [imageDeferred resolveWithValue:fulfilledImage];

                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:imageDeferred.promise
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];
                    });

                    it(@"should not resolve the punch promise", ^{
                        punchPromise.fulfilled should be_falsy;
                    });
                });

                describe(@"when passing an unfulilled image promise and a fulfilled geolocation promise", ^{
                    beforeEach(^{
                        CLLocation *location = [[CLLocation alloc] initWithLatitude:1.0 longitude:2.0];
                        NSString *address = @"Some Magic Street";

                        Geolocation *fulfilledGeolocation = [[Geolocation alloc] initWithLocation:location address:address];

                        [geolocationDeferred resolveWithValue:fulfilledGeolocation];
                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:imageDeferred.promise
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];
                    });

                    it(@"should not resolve the punch promise", ^{
                        punchPromise.fulfilled should be_falsy;
                    });
                });

                describe(@"when passing an unfulfilled image promise and a rejected image promise", ^{
                    beforeEach(^{
                        [geolocationDeferred rejectWithError:nil];
                        [subject assembleIncompletePunch:incompletePunch
                                            imagePromise:imageDeferred.promise
                                      geolocationPromise:geolocationDeferred.promise
                                           punchDeferred:punchDeferred];
                    });

                    it(@"should not resolve the punch promise", ^{
                        punchPromise.fulfilled should be_falsy;
                    });
                });
            });
        });
    });
});

SPEC_END
