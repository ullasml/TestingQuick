#import <Cedar/Cedar.h>
#import "ErrorDetails.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ErrorDetailsSpec)

describe(@"ErrorDetails", ^{
    __block ErrorDetails *errorDetailsA;
    __block ErrorDetails *errorDetailsB;

    describe(@"equality", ^{
        context(@"when the two objects are not the same type", ^{

            it(@"should not be equal", ^{
                errorDetailsA = [[ErrorDetails alloc] initWithUri:nil errorMessage:nil errorDate:nil moduleName:nil];
                errorDetailsB = (ErrorDetails *)@"asbsf";
                errorDetailsA should_not equal(errorDetailsB);
            });
        });

        context(@"when all parameters are nil", ^{
            it(@"should be equal", ^{
                errorDetailsA = [[ErrorDetails alloc] initWithUri:nil errorMessage:nil errorDate:nil moduleName:nil];
                errorDetailsB = [[ErrorDetails alloc] initWithUri:nil errorMessage:nil errorDate:nil moduleName:nil];
                errorDetailsA should equal(errorDetailsB);
            });
        });

        context(@"when message are equal and uris,dates and names are nil", ^{
            it(@"should be equal", ^{
                errorDetailsA = [[ErrorDetails alloc] initWithUri:nil errorMessage:@"custom" errorDate:nil moduleName:nil];
                errorDetailsB = [[ErrorDetails alloc] initWithUri:nil errorMessage:@"custom" errorDate:nil moduleName:nil];
                errorDetailsA should equal(errorDetailsB);
            });
        });

        context(@"when messages are not equal and uris,dates and names are nil", ^{
            it(@"should not be equal", ^{
                errorDetailsA = [[ErrorDetails alloc] initWithUri:nil errorMessage:@"custom" errorDate:nil moduleName:nil];
                errorDetailsB = [[ErrorDetails alloc] initWithUri:nil errorMessage:@"custom again" errorDate:nil moduleName:nil];
                errorDetailsA should_not equal(errorDetailsB);
            });
        });

        context(@"when all parameters are equal", ^{
            it(@"should be equal", ^{
                errorDetailsA = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
                errorDetailsB = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
                errorDetailsA should equal(errorDetailsB);
            });
        });
    });

    describe(@"<NSCoding>", ^{

        it(@"should implement NSCoding", ^{
            ErrorDetails *errorDetailsToBeEncoded = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];

            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:errorDetailsToBeEncoded];
            ErrorDetails *decodedErrorDetailsType = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            decodedErrorDetailsType should equal(errorDetailsToBeEncoded);
        });
    });

    describe(@"<NSCopying>", ^{

        describe(NSStringFromSelector(@selector(copy)), ^{
            it(@"should return an exact copy of the object", ^{
                ErrorDetails *errorDetailsToBeCopied = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];

                ErrorDetails *copiedErrorDetails = [errorDetailsToBeCopied copy];

                copiedErrorDetails should equal(errorDetailsToBeCopied);
                copiedErrorDetails should_not be_same_instance_as(errorDetailsToBeCopied);
            });
        });

        describe(NSStringFromSelector(@selector(copyWithZone:)), ^{
            it(@"should return an exact copy of the object", ^{
                ErrorDetails *errorDetailsToBeCopied = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];

                ErrorDetails *copiedErrorDetails = [errorDetailsToBeCopied copyWithZone:nil];

                copiedErrorDetails should equal(errorDetailsToBeCopied);
                copiedErrorDetails should_not be_same_instance_as(errorDetailsToBeCopied);
            });
        });
    });
});

SPEC_END
