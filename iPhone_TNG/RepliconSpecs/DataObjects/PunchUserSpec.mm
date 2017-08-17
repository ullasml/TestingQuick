#import <Cedar/Cedar.h>
#import "PunchUser.h"
#import "BookedTimeOff.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchUserSpec)

describe(NSStringFromClass([PunchUser class]), ^{
    describe(NSStringFromSelector(@selector(isEqual:)), ^{
        __block PunchUser *userA;
        __block PunchUser *userB;

        it(@"should not be equal when comparing a different type of object", ^{
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            dateComponents.hour = 1;
            dateComponents.minute = 2;
            dateComponents.second = 3;

            NSArray *bookedTimeOffArray = @[[[BookedTimeOff alloc] initWithDescriptionText:@"Some Time off Description"]];

            userA = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponents
                                   overtimeDateComponents:dateComponents
                                            bookedTimeOff:bookedTimeOffArray];

            userA should_not equal((PunchUser *)[NSDate date]);
        });

        it(@"should not be equal when one of the members are not equal", ^{
            NSDateComponents *dateComponentsA = [[NSDateComponents alloc] init];
            dateComponentsA.hour = 1;
            dateComponentsA.minute = 2;
            dateComponentsA.second = 3;

            NSDateComponents *dateComponentsB = [[NSDateComponents alloc] init];
            dateComponentsA.hour = 4;
            dateComponentsA.minute = 5;
            dateComponentsA.second = 6;

            NSArray *bookedTimeOffArray = @[[[BookedTimeOff alloc] initWithDescriptionText:@"Some Time off Description"]];

            userA = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponentsA
                                   overtimeDateComponents:dateComponentsA
                                            bookedTimeOff:bookedTimeOffArray];


            userB = [[PunchUser alloc] initWithNameString:@"Bar Baz"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponentsA
                                   overtimeDateComponents:dateComponentsA
                                            bookedTimeOff:bookedTimeOffArray];
            userA should_not equal(userB);

            userB = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://another.com/some.other.image"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponentsA
                                   overtimeDateComponents:dateComponentsA
                                            bookedTimeOff:bookedTimeOffArray];
            userA should_not equal(userB);

            userB = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1600 Some Big Street"
                                    regularDateComponents:dateComponentsA
                                   overtimeDateComponents:dateComponentsA
                                            bookedTimeOff:bookedTimeOffArray];
            userA should_not equal(userB);

            userB = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponentsB
                                   overtimeDateComponents:dateComponentsA
                                            bookedTimeOff:bookedTimeOffArray];
            userA should_not equal(userB);

            userB = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponentsA
                                   overtimeDateComponents:dateComponentsB
                                            bookedTimeOff:bookedTimeOffArray];
            userA should_not equal(userB);

            NSArray *differentBookedTimeOffArray = @[[[BookedTimeOff alloc] initWithDescriptionText:@"a different value"]];

            userB = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponentsA
                                   overtimeDateComponents:dateComponentsA
                                            bookedTimeOff:differentBookedTimeOffArray];
            userA should_not equal(userB);
        });

        it(@"should be equal when all of the members are equal", ^{
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            dateComponents.hour = 1;
            dateComponents.minute = 2;
            dateComponents.second = 3;

            NSArray *bookedTimeOffArray = @[[[BookedTimeOff alloc] initWithDescriptionText:@"Some Time off Description"]];

            userA = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponents
                                   overtimeDateComponents:dateComponents
                                            bookedTimeOff:bookedTimeOffArray];

            userB = [[PunchUser alloc] initWithNameString:@"Foo Bar"
                                                 imageURL:[NSURL URLWithString:@"http://example.com/asdf.large"]
                                            addressString:@"1200 Sycamore Road"
                                    regularDateComponents:dateComponents
                                   overtimeDateComponents:dateComponents
                                            bookedTimeOff:bookedTimeOffArray];

            userA should equal(userB);
        });

        it(@"should be equal when all of the members are nil", ^{
            userA = [[PunchUser alloc] initWithNameString:nil
                                                 imageURL:nil
                                            addressString:nil
                                    regularDateComponents:nil
                                   overtimeDateComponents:nil
                                            bookedTimeOff:nil];

            userB = [[PunchUser alloc] initWithNameString:nil
                                                 imageURL:nil
                                            addressString:nil
                                    regularDateComponents:nil
                                   overtimeDateComponents:nil
                                            bookedTimeOff:nil];


            userA should equal(userB);
        });
    });
});

SPEC_END
