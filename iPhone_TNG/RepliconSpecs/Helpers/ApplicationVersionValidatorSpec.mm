#import <Cedar/Cedar.h>
#import "ApplicationVersionValidator.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorKeys.h"
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ApplicationVersionValidatorSpec)

describe(@"ApplicationVersionValidator", ^{
    __block ApplicationVersionValidator *subject;
    __block id <BSInjector,BSBinder> injector;
    __block NSBundle *bundle;


    beforeEach(^{
        injector = [InjectorProvider injector];
        bundle = nice_fake_for([NSBundle class]);
        [injector bind:InjectorKeyMainBundle toInstance:bundle];
        subject = [injector getInstance:[ApplicationVersionValidator class]];
    });

    describe(@"isVersion:olderThanVersion:", ^{

        it(@"should not treat as version upgrade", ^{
            [subject isVersion:@"1.0.71.1" olderThanVersion:@"1.0.71.1"] should be_falsy;
        });

        it(@"should treat  version upgrade", ^{
            [subject isVersion:@"1.0.70.13" olderThanVersion:@"1.0.71.1"] should be_truthy;
        });

        it(@"should not treat as version upgrade", ^{
            [subject isVersion:@"1.0.72.0" olderThanVersion:@"1.0.71.1"] should be_falsy;
        });

        it(@"should not treat as version upgrade", ^{
            [subject isVersion:@"2.0.70.15" olderThanVersion:@"1.0.71.1"] should be_falsy;
        });

        it(@"should  treat as version upgrade", ^{
            [subject isVersion:@"1.0.69.15" olderThanVersion:@"1.0.71.1"] should be_truthy;
        });

        it(@"should  treat as version upgrade", ^{
            [subject isVersion:@"1.0.69" olderThanVersion:@"1.0.71.1"] should be_truthy;
        });

        it(@"should not treat as version upgrade", ^{
            [subject isVersion:@"1.0.72.0" olderThanVersion:@"1.0.71.1"] should be_falsy;
        });

    });

    describe(@"needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:", ^{

        __block BOOL needsUpdate;

        beforeEach(^{
            bundle stub_method(@selector(infoDictionary)).and_return(@{@"CFBundleVersion":@"1.0.71.0"});
        });

        describe(@"when older version is 1.0.71.1", ^{

            beforeEach(^{
                needsUpdate = [subject needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:@"1.0.71.1"];
            });

            it(@"should update the version and user details", ^{
                needsUpdate should be_truthy;
            });
        });

        describe(@"when older version is nil", ^{

            beforeEach(^{
                needsUpdate = [subject needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:nil];
            });

            it(@"should update the version and user details", ^{
                needsUpdate should be_truthy;
            });
        });

        describe(@"when older version is 1.0.71.0", ^{

            beforeEach(^{
                needsUpdate = [subject needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:@"1.0.71.0"];
            });

            it(@"should update the version and user details", ^{
                needsUpdate should be_falsy;
            });

        });
    });
});

SPEC_END
