#import <Cedar/Cedar.h>
#import "PunchRequestBodyProvider.h"
#import "GUIDProvider.h"
#import "LocalPunch.h"
#import "BreakType.h"
#import "Constants.h"
#import "OfflineLocalPunch.h"
#import "PunchSerializer.h"
#import "RemotePunch.h"
#import "UserSession.h"
#import "Guid.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchRequestBodyProviderSpec)

describe(@"PunchRequestBodyProvider", ^{
    __block PunchRequestBodyProvider *subject;
    __block PunchSerializer *punchSerializer;
    __block id<UserSession> userSession;
    __block GUIDProvider *guidProvider;

    beforeEach(^{
        guidProvider = nice_fake_for([GUIDProvider class]);
        guidProvider stub_method(@selector(guid)).and_return(@"a-totally-unique-guid");

        punchSerializer = fake_for([PunchSerializer class]);

        userSession = fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"some:user:uri");

        subject = [[PunchRequestBodyProvider alloc] initWithPunchSerializer:punchSerializer
                                                               guidProvider:guidProvider
                                                                userSession:userSession];
    });

    describe(@"requestBodyForMostRecentPunch", ^{
        it(@"should be configured correctly reading from usersession when userUri is nil", ^{
            NSDictionary *requestBody = [subject requestBodyForMostRecentPunchForUserUri:nil];
            requestBody should equal(@{@"user": @{@"uri": @"some:user:uri"}});
        });
        it(@"should be configured correctly when userUri is passed", ^{
            NSDictionary *requestBody = [subject requestBodyForMostRecentPunchForUserUri:@"my:user:uri"];
            requestBody should equal(@{@"user": @{@"uri": @"my:user:uri"}});
        });
    });

    describe(@"requestBodyForPunch:", ^{
        __block NSDictionary *requestBody;

        context(@"When guid provider is nil", ^{
            beforeEach(^{

                guidProvider = nil;

                subject = [[PunchRequestBodyProvider alloc] initWithPunchSerializer:punchSerializer
                                                                       guidProvider:guidProvider
                                                                        userSession:userSession];

                spy_on(subject);
                
                subject stub_method(@selector(guid)).and_return(@"global-unique-guid");

                id<Punch> punch = fake_for(@protocol(Punch));

                punchSerializer stub_method(@selector(timePunchDictionaryForPunch:))
                .with(punch).and_return(@{@"punch": @"A"});

                requestBody = [subject requestBodyForPunch:@[punch]];

            });

            it(@"should send a correctly configured request to the client", ^{
                NSDictionary *expectedBody = @{
                                               @"unitOfWorkId": @"global-unique-guid",
                                               @"punchWithCreatedAtTimeBulkParameters": @[@{@"punch": @"A"}]
                                               };

                requestBody should equal(expectedBody);
            });

            afterEach(^{
                stop_spying_on(subject);
            });
        });

        context(@"for a single punch", ^{
            beforeEach(^{
                id<Punch> punch = fake_for(@protocol(Punch));

                punchSerializer stub_method(@selector(timePunchDictionaryForPunch:))
                .with(punch).and_return(@{@"punch": @"A"});

                requestBody = [subject requestBodyForPunch:@[punch]];
            });

            it(@"should send a correctly configured request to the client", ^{
                NSDictionary *expectedBody = @{
                                               @"unitOfWorkId": @"a-totally-unique-guid",
                                               @"punchWithCreatedAtTimeBulkParameters": @[@{@"punch": @"A"}]
                                               };
                
                requestBody should equal(expectedBody);
            });
        });

        context(@"for multiple punches", ^{
            beforeEach(^{
                id<Punch> punchA = fake_for(@protocol(Punch));
                id<Punch> punchB = fake_for(@protocol(Punch));

                punchSerializer stub_method(@selector(timePunchDictionaryForPunch:))
                .with(punchA).and_return(@{@"punch": @"A"});
                punchSerializer stub_method(@selector(timePunchDictionaryForPunch:))
                .with(punchB).and_return(@{@"punch": @"B"});

                requestBody = [subject requestBodyForPunch:@[punchA,punchB]];
            });

            it(@"should send a correctly configured request to the client", ^{
                NSDictionary *expectedBody = @{
                                               @"unitOfWorkId": @"a-totally-unique-guid",
                                               @"punchWithCreatedAtTimeBulkParameters": @[@{@"punch": @"A"},@{@"punch": @"B"}]
                                               };
                
                requestBody should equal(expectedBody);
            });
        });


    });

    describe(@"requestBodyForPunchesWithDate:userURI:", ^{
        it(@"should return a correctly configured request", ^{
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:1430331456]; // 2014-04-29
            NSString *expectedUserURI = @"some-other-user-uri";

            NSDictionary *requestBody = [subject requestBodyForPunchesWithDate:date userURI:expectedUserURI];

            requestBody should equal(@{
                                    @"user": @{
                                            @"uri": expectedUserURI
                                            },
                                    @"dateRange": @{
                                            @"startDate": @{
                                                    @"year": @2015,
                                                    @"month": @4,
                                                    @"day": @28
                                                    },
                                            @"endDate": @{
                                                    @"year": @2015,
                                                    @"month": @4,
                                                    @"day": @30
                                                    }
                                            }
                                    });
        });
    });

    describe(@"requestBodyForPunchesWithLastTwoMostRecentPunchWithDate:", ^{
        it(@"should return a correctly configured request", ^{
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:1430331456]; // 2014-04-29

            NSDictionary *requestBody = [subject requestBodyForPunchesWithLastTwoMostRecentPunchWithDate:date];

            requestBody should equal(@{
                                               @"date": @{
                                                       @"year": @2015,
                                                       @"month": @4,
                                                       @"day": @29
                                                       },
                                               @"checkIsTimeEntryAvailable": @"urn:replicon:check-punch-time-entry-available:penultimate-only"
                                       });
        });
    });

    describe(@"requestBodyToDeletePunchWithURI:", ^{
        it(@"should return a correctly configured request body", ^{
            NSDictionary *body = [subject requestBodyToDeletePunchWithURI:@"My Special URI"];

            NSDictionary *expectedBody = @{
                @"timePunchUris": @[@"My Special URI"]
            };

            body should equal(expectedBody);
        });
    });

    describe(@"requestBodyToUpdatePunch:", ^{
        it(@"should return a correctly configured request body for a single punch", ^{
            RemotePunch *punch = fake_for([RemotePunch class]);
            punch stub_method(@selector(uri)).and_return(@"My Special URI");
            punch stub_method(@selector(requestID)).and_return(@"ABCD1234");
            punchSerializer stub_method(@selector(timePunchDictionaryForPunch:))
                .with(punch).and_return(@{@"timePunch": @{@"foo": @"bar"}});

            NSDictionary *body = [subject requestBodyToUpdatePunch:@[punch]];

            NSDictionary *expectedBody = @{
                @"putTimePunchParameters": @[@{
                    @"timePunch": @{
                        @"target": @{@"uri": @"My Special URI",@"parameterCorrelationId": @"ABCD1234"},
                        @"foo": @"bar"
                    }
                }],
                @"unitOfWorkId": @"a-totally-unique-guid"
            };

            body should equal(expectedBody);
        });

        it(@"should return a correctly configured request body for a multiple punch", ^{
            RemotePunch *punchA = fake_for([RemotePunch class]);
            RemotePunch *punchB = fake_for([RemotePunch class]);
            punchA stub_method(@selector(uri)).and_return(@"My PunchA URI");
            punchA stub_method(@selector(requestID)).and_return(@"punchA");
            punchB stub_method(@selector(uri)).and_return(@"My PunchB URI");
            punchB stub_method(@selector(requestID)).and_return(@"punchB");
            punchSerializer stub_method(@selector(timePunchDictionaryForPunch:))
            .with(punchA).and_return(@{@"timePunch": @{@"foo1": @"bar1"}});
            punchSerializer stub_method(@selector(timePunchDictionaryForPunch:))
            .with(punchB).and_return(@{@"timePunch": @{@"foo2": @"bar2"}});

            NSDictionary *body = [subject requestBodyToUpdatePunch:@[punchA,punchB]];

            NSDictionary *expectedBody = @{
                                           @"putTimePunchParameters": @[@{
                                                                            @"timePunch": @{
                                                                                    @"target": @{@"uri": @"My PunchA URI",@"parameterCorrelationId": @"punchA"},
                                                                                    @"foo1": @"bar1"
                                                                                    }
                                                                            },
                                                                        @{
                                                                            @"timePunch": @{
                                                                                    @"target": @{@"uri": @"My PunchB URI",@"parameterCorrelationId": @"punchB"},
                                                                                    @"foo2": @"bar2"
                                                                                    }
                                                                            }],
                                           @"unitOfWorkId": @"a-totally-unique-guid"
                                           };
            
            body should equal(expectedBody);
        });
    });
});

SPEC_END
