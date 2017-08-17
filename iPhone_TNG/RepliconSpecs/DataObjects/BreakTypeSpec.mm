#import <Cedar/Cedar.h>
#import "BreakType.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(BreakTypeSpec)

describe(@"BreakType", ^{
    __block BreakType *breakA;
    __block BreakType *breakB;

    describe(@"equality", ^{
        context(@"when the two objects are not the same type", ^{

            it(@"should not be equal", ^{
                breakA = [[BreakType alloc] initWithName:nil uri:nil];
                breakB = (BreakType *)@"asdf";
                breakA should_not equal(breakB);
            });
        });

        context(@"when name and uri are both nil", ^{

            it(@"should be equal", ^{
                breakA = [[BreakType alloc] initWithName:nil uri:nil];
                breakB = [[BreakType alloc] initWithName:nil uri:nil];
                breakA should equal(breakB);
            });
        });

        context(@"when names are equal and uris are nil", ^{
            it(@"should be equal", ^{
                breakA = [[BreakType alloc] initWithName:@"asdf" uri:nil];
                breakB = [[BreakType alloc] initWithName:@"asdf" uri:nil];
                breakA should equal(breakB);
            });
        });

        context(@"when names are not equal and uris are nil", ^{
            it(@"should not be equal", ^{
                breakA = [[BreakType alloc] initWithName:@"asdf" uri:nil];
                breakB = [[BreakType alloc] initWithName:@"zsxv" uri:nil];
                breakA should_not equal(breakB);
            });
        });

        context(@"when names are nil and uris are equal", ^{
            it(@"should be equal", ^{
                breakA = [[BreakType alloc] initWithName:nil uri:@"asdf"];
                breakB = [[BreakType alloc] initWithName:nil uri:@"asdf"];
                breakA should equal(breakB);
            });
        });

        context(@"when names are nil and uris are not equal", ^{
            it(@"should not be equal", ^{
                breakA = [[BreakType alloc] initWithName:nil uri:@"asdf"];
                breakB = [[BreakType alloc] initWithName:nil uri:@"zsxv"];
                breakA should_not equal(breakB);
            });
        });

        context(@"when names are equal and uris are equal", ^{
            it(@"should be equal", ^{
                breakA = [[BreakType alloc] initWithName:@"zxcv" uri:@"asdf"];
                breakB = [[BreakType alloc] initWithName:@"zxcv" uri:@"asdf"];
                breakA should equal(breakB);
            });
        });
    });

    describe(@"<NSCoding>", ^{

        it(@"should implement NSCoding", ^{
            BreakType *breakTypeToBeEncoded = [[BreakType alloc] initWithName:@"asdf" uri:@"zxcv"];

            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:breakTypeToBeEncoded];
            BreakType *decodedBreakType = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            decodedBreakType should equal(breakTypeToBeEncoded);
        });
    });

    describe(@"<NSCopying>", ^{

        describe(NSStringFromSelector(@selector(copy)), ^{
            it(@"should return an exact copy of the object", ^{
                BreakType *breakTypeToBeCopied = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-uri"];

                BreakType *copiedBreakType = [breakTypeToBeCopied copy];

                copiedBreakType should equal(breakTypeToBeCopied);
                copiedBreakType should_not be_same_instance_as(breakTypeToBeCopied);
            });
        });

        describe(NSStringFromSelector(@selector(copyWithZone:)), ^{
            it(@"should return an exact copy of the object", ^{
                BreakType *breakTypeToBeCopied = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-uri"];

                BreakType *copiedBreakType = [breakTypeToBeCopied copyWithZone:nil];

                copiedBreakType should equal(breakTypeToBeCopied);
                copiedBreakType should_not be_same_instance_as(breakTypeToBeCopied);
            });
        });
    });
});

SPEC_END
