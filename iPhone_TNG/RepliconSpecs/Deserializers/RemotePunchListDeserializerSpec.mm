#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import <MacTypes.h>
#import "RemotePunchListDeserializer.h"
#import "RepliconSpecHelper.h"
#import "RemotePunch.h"
#import "Util.h"
#import "PunchActionTypes.h"
#import "DateProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "OEFType.h"
#import "Enum.h"
#import "RemotePunchDeserializer.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(RemotePunchListDeserializerSpec)

describe(@"RemotePunchListDeserializer", ^{
    __block RemotePunchListDeserializer *subject;
    __block RemotePunchDeserializer *remotePunchDeserializer;
    __block DateProvider *dateProvider;
    __block id<BSBinder, BSInjector> injector;
    __block NSArray * deserializedPunchesArray;


    beforeEach(^{
        injector = [InjectorProvider injector];
        dateProvider = nice_fake_for([DateProvider class]);
        remotePunchDeserializer = nice_fake_for([RemotePunchDeserializer class]);
    });

    describe(NSStringFromSelector(@selector(deserialize:)), ^{

        context(@"For PST timeZone", ^{

            beforeEach(^{

                NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
                longDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"PST"];
                longDateFormatter.dateFormat = @"MMM d, YYYY";

                [injector bind:[RemotePunchDeserializer class] toInstance:remotePunchDeserializer];
                [injector bind:InjectorKeyShortDateWithYearInLocalTimeZoneDateFormatter toInstance:longDateFormatter];
                subject = [injector getInstance:[RemotePunchListDeserializer class]];

            });

            describe(@"should return the punches falling in the presented date", ^{
                __block RemotePunch *expectedPunch;
                beforeEach(^{
                    expectedPunch = nice_fake_for([RemotePunch class]);
                    expectedPunch stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1436951580]);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-value-A"}).and_return(expectedPunch);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-value-B"}).and_return(expectedPunch);
                    deserializedPunchesArray = [subject deserialize:@{@"d":@[@{@"uri":@"some-value-A"},@{@"uri":@"some-value-B"}]}];
                });

                it(@"should return correct first punch", ^{
                    [deserializedPunchesArray firstObject] should equal(expectedPunch);
                });
            });
            
            describe(@"should not return the punches falling in the presented date with invalid punch uri", ^{
                __block RemotePunch *expectedPunch;
                beforeEach(^{
                    expectedPunch = nice_fake_for([RemotePunch class]);
                    expectedPunch stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1436951580]);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-value-A":@"some-value-A"}).and_return(expectedPunch);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-value-B":@"some-value-B"}).and_return(expectedPunch);
                    deserializedPunchesArray = [subject deserialize:@{@"d":@[@{@"some-value-A":@"some-value-A"},@{@"some-value-B":@"some-value-B"}]}];
                });
                
                it(@"should return correct count", ^{
                    deserializedPunchesArray.count should equal(0);
                });
            });


            describe(@"should not return the punches falling in the presented date", ^{
                __block RemotePunch *expectedPunchA;
                __block RemotePunch *expectedPunchB;

                beforeEach(^{
                    expectedPunchA = nice_fake_for([RemotePunch class]);
                    expectedPunchA stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475238637]);

                    expectedPunchB = nice_fake_for([RemotePunch class]);
                    expectedPunchB stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475239447]);

                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-value-A"}).and_return(expectedPunchA);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-value-B"}).and_return(expectedPunchB);

                    deserializedPunchesArray = [subject deserialize:@{@"d":@[@{@"uri":@"some-value-A"},@{@"uri":@"some-value-B"}]}];
                });

                it(@"should return correct first punch", ^{
                    deserializedPunchesArray.count should equal(2);
                });
            });

            describe(@"when no punches available", ^{
                __block RemotePunch *expectedPunchA;
                __block RemotePunch *expectedPunchB;

                beforeEach(^{
                    expectedPunchA = nice_fake_for([RemotePunch class]);
                    expectedPunchA stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475238637]);

                    expectedPunchB = nice_fake_for([RemotePunch class]);
                    expectedPunchB stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475239447]);

                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-key-A":@"some-value-A"}).and_return(expectedPunchA);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-key-B":@"some-value-B"}).and_return(expectedPunchB);

                    deserializedPunchesArray = [subject deserialize:@{@"d":[NSNull null]}];
                });

                it(@"should return correct first punch", ^{
                    deserializedPunchesArray.count should equal(0);
                });
                it(@"punch list should not be nil", ^{
                    deserializedPunchesArray should_not be_nil;
                });
            });

            describe(@"when json in nil", ^{
                __block RemotePunch *expectedPunchA;
                __block RemotePunch *expectedPunchB;

                beforeEach(^{
                    expectedPunchA = nice_fake_for([RemotePunch class]);
                    expectedPunchA stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475238637]);

                    expectedPunchB = nice_fake_for([RemotePunch class]);
                    expectedPunchB stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475239447]);

                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-key-A":@"some-value-A"}).and_return(expectedPunchA);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-key-B":@"some-value-B"}).and_return(expectedPunchB);

                    deserializedPunchesArray = [subject deserialize:nil];
                });

                it(@"should return correct first punch", ^{
                    deserializedPunchesArray.count should equal(0);
                });
                it(@"punch list should not be nil", ^{
                    deserializedPunchesArray should_not be_nil;
                });
            });


        });

        context(@"For IST timeZone", ^{

            beforeEach(^{


                NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
                longDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"IST"];
                longDateFormatter.dateFormat = @"MMM d, YYYY";

                [injector bind:[RemotePunchDeserializer class] toInstance:remotePunchDeserializer];
                [injector bind:InjectorKeyShortDateWithYearInLocalTimeZoneDateFormatter toInstance:longDateFormatter];
                subject = [injector getInstance:[RemotePunchListDeserializer class]];

            });
            describe(@"should return the punches falling in the presented date", ^{
                __block RemotePunch *expectedPunch;
                beforeEach(^{
                    expectedPunch = nice_fake_for([RemotePunch class]);
                    expectedPunch stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1437015214]);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-value-A"}).and_return(expectedPunch);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-value-B"}).and_return(expectedPunch);
                    deserializedPunchesArray = [subject deserialize:@{@"d":@[@{@"uri":@"some-value-A"},@{@"uri":@"some-value-B"}]}];
                });

                it(@"should return correct first punch", ^{
                    [deserializedPunchesArray firstObject] should equal(expectedPunch);
                });
            });

            describe(@"should not return the punches falling in the presented date", ^{
                __block RemotePunch *expectedPunch;
                beforeEach(^{
                    expectedPunch = nice_fake_for([RemotePunch class]);
                    expectedPunch stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475238637]);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-value-A"}).and_return(expectedPunch);
                     remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"uri":@"some-value-B"}).and_return(expectedPunch);
                    deserializedPunchesArray = [subject deserialize:@{@"d":@[@{@"uri":@"some-value-A"},@{@"uri":@"some-value-B"}]}];
                });

                it(@"should return correct first punch", ^{
                    deserializedPunchesArray.count should equal(2);
                });
            });
            
            describe(@"should not return the punches falling in the presented date with invalid punch uri", ^{
                __block RemotePunch *expectedPunch;
                beforeEach(^{
                    expectedPunch = nice_fake_for([RemotePunch class]);
                    expectedPunch stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475238637]);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-value-A":@"some-value-A"}).and_return(expectedPunch);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-value-B":@"some-value-B"}).and_return(expectedPunch);
                    deserializedPunchesArray = [subject deserialize:@{@"d":@[@{@"some-value-A":@"some-value-A"},@{@"some-value-B":@"some-value-B"}]}];
                });
                
                it(@"should return correct count", ^{
                    deserializedPunchesArray.count should equal(0);
                });
            });


            describe(@"when no punches available", ^{
                __block RemotePunch *expectedPunchA;
                __block RemotePunch *expectedPunchB;

                beforeEach(^{
                    expectedPunchA = nice_fake_for([RemotePunch class]);
                    expectedPunchA stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475238637]);

                    expectedPunchB = nice_fake_for([RemotePunch class]);
                    expectedPunchB stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475239447]);

                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-key-A":@"some-value-A"}).and_return(expectedPunchA);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-key-B":@"some-value-B"}).and_return(expectedPunchB);

                    deserializedPunchesArray = [subject deserialize:@{@"d":[NSNull null]}];
                });

                it(@"should return correct first punch", ^{
                    deserializedPunchesArray.count should equal(0);
                });
                it(@"punch list should not be nil", ^{
                    deserializedPunchesArray should_not be_nil;
                });
            });

            describe(@"when json in nil", ^{
                __block RemotePunch *expectedPunchA;
                __block RemotePunch *expectedPunchB;

                beforeEach(^{
                    expectedPunchA = nice_fake_for([RemotePunch class]);
                    expectedPunchA stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475238637]);

                    expectedPunchB = nice_fake_for([RemotePunch class]);
                    expectedPunchB stub_method(@selector(date)).and_return([NSDate dateWithTimeIntervalSince1970:1475239447]);

                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-key-A":@"some-value-A"}).and_return(expectedPunchA);
                    remotePunchDeserializer stub_method(@selector(deserialize:)).with(@{@"some-key-B":@"some-value-B"}).and_return(expectedPunchB);

                    deserializedPunchesArray = [subject deserialize:nil];
                });

                it(@"should return correct first punch", ^{
                    deserializedPunchesArray.count should equal(0);
                });
                it(@"punch list should not be nil", ^{
                    deserializedPunchesArray should_not be_nil;
                });
            });

        });
    });
});

SPEC_END
