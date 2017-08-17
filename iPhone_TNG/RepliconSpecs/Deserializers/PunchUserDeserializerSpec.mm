#import <Cedar/Cedar.h>
#import "PunchUserDeserializer.h"
#import "PunchUser.h"
#import "RepliconSpecHelper.h"
#import "BookedTimeOff.h"
#import "BookedTimeOffDeserializer.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchUserDeserializerSpec)

describe(@"PunchUserDeserializer", ^{
    __block PunchUserDeserializer *subject;
    __block BookedTimeOffDeserializer *bookedTimeOffDeserializer;

    beforeEach(^{
        bookedTimeOffDeserializer = nice_fake_for([BookedTimeOffDeserializer class]);
    });

    beforeEach(^{
        subject = [[PunchUserDeserializer alloc] initWithBookedTimeOffDeserializer:bookedTimeOffDeserializer];
    });

    describe(NSStringFromSelector(@selector(deserialize:)), ^{
        __block PunchUser *punchUser;

        context(@"when the user has a latest punch with an image and address", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary = [RepliconSpecHelper jsonWithFixture:@"teamstatus_summary_with_latest_punch"];
                NSDictionary *userDictionary = jsonDictionary[@"d"][@"clockedInUsers"][0];

                punchUser = [subject deserialize:userDictionary];
            });

            it(@"should return a correctly deserialized user object with the address and image URLs from the latest punch", ^{
                NSString *expectedNameString = @"Testing, Mike";

                NSURL *expectedImageURL = [NSURL URLWithString:@"https://na2.swimlane08c.replicon.staging/astro/services/BinaryObjectHandler.ashx?id=abccc5e1c4fc44eba42989cf723a0c44"];

                NSString *expectedAddressString = @"1800 Ellis Street, San Francisco, CA 94115, USA";

                NSDateComponents *expectedRegularDateComponents = [[NSDateComponents alloc] init];
                expectedRegularDateComponents.hour = 8;
                expectedRegularDateComponents.minute = 12;
                expectedRegularDateComponents.second = 12;

                NSDateComponents *expectedOvertimeDateComponents = [[NSDateComponents alloc] init];
                expectedOvertimeDateComponents.hour = 1;
                expectedOvertimeDateComponents.minute = 29;
                expectedOvertimeDateComponents.second = 23;

                PunchUser *expectedPunchUser = [[PunchUser alloc] initWithNameString:expectedNameString
                                                                            imageURL:expectedImageURL
                                                                       addressString:expectedAddressString
                                                               regularDateComponents:expectedRegularDateComponents
                                                              overtimeDateComponents:expectedOvertimeDateComponents
                                                                       bookedTimeOff:@[]];

                punchUser should equal(expectedPunchUser);
            });
        });

        context(@"when the user's latest punch lacks an image", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary = [RepliconSpecHelper jsonWithFixture:@"team_time_punch_overview_with_overtime_and_no_images_summary_response"];
                NSDictionary *userDictionary = jsonDictionary[@"d"][@"overtimeUsersDetails"][0];

                punchUser = [subject deserialize:userDictionary];
            });

            it(@"should return a correctly deserialized user object with an address, but no images", ^{
                NSString *expectedNameString = @"user, punch";
                NSString *expectedAddressString = @"1800 Ellis Street, San Francisco, CA 94115, USA";

                NSDateComponents *expectedRegularDateComponents = [[NSDateComponents alloc] init];
                expectedRegularDateComponents.hour = 8;
                expectedRegularDateComponents.minute = 0;
                expectedRegularDateComponents.second = 0;

                NSDateComponents *expectedOvertimeDateComponents = [[NSDateComponents alloc] init];
                expectedOvertimeDateComponents.hour = 1;
                expectedOvertimeDateComponents.minute = 29;
                expectedOvertimeDateComponents.second = 46;

                PunchUser *expectedPunchUser = [[PunchUser alloc] initWithNameString:expectedNameString
                                                                            imageURL:nil
                                                                       addressString:expectedAddressString
                                                               regularDateComponents:expectedRegularDateComponents
                                                              overtimeDateComponents:expectedOvertimeDateComponents
                                                                       bookedTimeOff:@[]];

                punchUser should equal(expectedPunchUser);
            });
        });

        context(@"when the user's latest punch lacks a geolocation", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary = [RepliconSpecHelper jsonWithFixture:@"team_time_punch_overview_with_overtime_without_geolocation_summary_response"];
                NSDictionary *userDictionary = jsonDictionary[@"d"][@"overtimeUsersDetails"][0];

                punchUser = [subject deserialize:userDictionary];
            });

            it(@"should return a correctly deserialized user object with an address, but no images", ^{
                NSString *expectedNameString = @"user, punch";

                NSURL *expectedImageURL = [NSURL URLWithString:@"https://na2.swimlane08c.replicon.staging/astro/services/BinaryObjectHandler.ashx?id=20668b2303634044a3a007b2a7450f60"];


                NSDateComponents *expectedRegularDateComponents = [[NSDateComponents alloc] init];
                expectedRegularDateComponents.hour = 8;
                expectedRegularDateComponents.minute = 0;
                expectedRegularDateComponents.second = 0;

                NSDateComponents *expectedOvertimeDateComponents = [[NSDateComponents alloc] init];
                expectedOvertimeDateComponents.hour = 1;
                expectedOvertimeDateComponents.minute = 29;
                expectedOvertimeDateComponents.second = 46;

                PunchUser *expectedPunchUser = [[PunchUser alloc] initWithNameString:expectedNameString
                                                                            imageURL:expectedImageURL
                                                                       addressString:nil
                                                               regularDateComponents:expectedRegularDateComponents
                                                              overtimeDateComponents:expectedOvertimeDateComponents
                                                                       bookedTimeOff:@[]];

                punchUser should equal(expectedPunchUser);
            });

        });

        context(@"when the user's latest punch lacks an address", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary = [RepliconSpecHelper jsonWithFixture:@"team_time_punch_overview_without_address_summary_response"];
                NSDictionary *userDictionary = jsonDictionary[@"d"][@"overtimeUsersDetails"][0];

                punchUser = [subject deserialize:userDictionary];
            });

            it(@"should return a correctly deserialized user object with an address, but no images", ^{
                NSString *expectedNameString = @"user, punch";
                
                NSURL *expectedImageURL = [NSURL URLWithString:@"https://na2.swimlane08c.replicon.staging/astro/services/BinaryObjectHandler.ashx?id=20668b2303634044a3a007b2a7450f60"];


                NSDateComponents *expectedRegularDateComponents = [[NSDateComponents alloc] init];
                expectedRegularDateComponents.hour = 8;
                expectedRegularDateComponents.minute = 0;
                expectedRegularDateComponents.second = 0;

                NSDateComponents *expectedOvertimeDateComponents = [[NSDateComponents alloc] init];
                expectedOvertimeDateComponents.hour = 1;
                expectedOvertimeDateComponents.minute = 29;
                expectedOvertimeDateComponents.second = 46;

                PunchUser *expectedPunchUser = [[PunchUser alloc] initWithNameString:expectedNameString
                                                                            imageURL:expectedImageURL
                                                                       addressString:nil
                                                               regularDateComponents:expectedRegularDateComponents
                                                              overtimeDateComponents:expectedOvertimeDateComponents
                                                                       bookedTimeOff:@[]];
                
                punchUser should equal(expectedPunchUser);
            });
        });

        context(@"when the user has some booked time off", ^{
            __block NSDictionary *userDictionary;
            beforeEach(^{
                NSDictionary *jsonDictionary = [RepliconSpecHelper jsonWithFixture:@"teamstatus_summary_with_timeoff"];
                userDictionary = jsonDictionary[@"d"][@"notInUsers"][0];
            });

            __block BookedTimeOff *bookedTimeOffA;
            __block BookedTimeOff *bookedTimeOffB;
            beforeEach(^{
                bookedTimeOffA = [[BookedTimeOff alloc] initWithDescriptionText:@"Banked Time: 2:00 PM to 4:00 PM"];
                bookedTimeOffDeserializer stub_method(@selector(deserialize:)).with(userDictionary[@"timeOffDetails"][0]).and_return(bookedTimeOffA);
                bookedTimeOffB = [[BookedTimeOff alloc] initWithDescriptionText:@"Second time off description"];
                bookedTimeOffDeserializer stub_method(@selector(deserialize:)).with(userDictionary[@"timeOffDetails"][1]).and_return(bookedTimeOffB);
            });

            beforeEach(^{
                punchUser = [subject deserialize:userDictionary];
            });

            it(@"should return a correctly deserialized user object with the booked time off objects", ^{
                NSString *expectedNameString = @"Testing, Wiley";

                NSDateComponents *expectedRegularDateComponents = [[NSDateComponents alloc] init];
                expectedRegularDateComponents.hour = 0;
                expectedRegularDateComponents.minute = 0;
                expectedRegularDateComponents.second = 0;

                NSDateComponents *expectedOvertimeDateComponents = [[NSDateComponents alloc] init];
                expectedOvertimeDateComponents.hour = 0;
                expectedOvertimeDateComponents.minute = 0;
                expectedOvertimeDateComponents.second = 0;


                PunchUser *expectedPunchUser = [[PunchUser alloc] initWithNameString:expectedNameString
                                                                            imageURL:nil
                                                                       addressString:nil
                                                               regularDateComponents:expectedRegularDateComponents
                                                              overtimeDateComponents:expectedOvertimeDateComponents
                                                                       bookedTimeOff:@[bookedTimeOffA, bookedTimeOffB]];


                punchUser should equal(expectedPunchUser);
            });

        });
    });
});

SPEC_END
