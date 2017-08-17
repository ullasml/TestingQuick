#import <Cedar/Cedar.h>
#import "FrameworkImport.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GATrackerSpec)

describe(@"when GATracker is called", ^{
    __block GATracker <CedarDouble> *subject;
    __block id<BSBinder, BSInjector> injector;
    __block id<GAITracker> tracker;
    __block TAGDataLayer *tagDataLayer;
    beforeEach(^{
        injector = [InjectorProvider injector];
        subject = [injector getInstance:[GATracker class]];
        spy_on(subject);

        tracker = nice_fake_for(@protocol(GAITracker));
        subject stub_method(@selector(getTrackerByType:)).and_return(tracker);

        tagDataLayer = nice_fake_for([TAGDataLayer class]);
        subject stub_method(@selector(productDataLayer)).and_return(tagDataLayer);
    });

    describe(@"trackUIEvent:forTracker:", ^{

        beforeEach(^{
            [subject trackUIEvent:@"TEST SPEC" forTracker:TrackerEngineering];
        });

        it(@"should have received correct event", ^{
            NSMutableDictionary *event =
            [[GAIDictionaryBuilder createEventWithCategory:@"ui"
                                                    action:[@"TEST SPEC" lowercaseString]
                                                     label:nil
                                                     value:nil] build];
            tracker should have_received(@selector(send:)).with(event);
        });


    });

    describe(@"trackScreenView:forTracker:", ^{

        beforeEach(^{
            [subject trackScreenView:@"TEST SPEC" forTracker:TrackerEngineering];
        });

        it(@"should have received correct event", ^{
            NSMutableDictionary *event = [[GAIDictionaryBuilder createScreenView] build];
            tracker should have_received(@selector(send:)).with(event);
        });
        
        
    });

    describe(@"setUserUri:companyName:username:platform:", ^{

        context(@"when credentails are  available", ^{
            beforeEach(^{
                [subject setUserUri:@"user-uri" companyName:@"cname" username:@"username" platform:@"gen3"];
            });
            it(@"should have received correct event for username", ^{
                //NSInteger usernameCustomDimentionIndex = [subject dimensionIndexForName:@"username" forTracker:TrackerEngineering];
                //NSString *unameCustomDimension = [GAIFields customDimensionForIndex:usernameCustomDimentionIndex];

                //tracker should have_received(@selector(set:value:)).with(unameCustomDimension,@"cname>username");
                tagDataLayer should have_received(@selector(push:)).with(@{@"company": @"cname", @"userName": @"cname>username", @"repliconPlatformVersion": @"gen3", @"userID": @"user-uri"});
            });

        });


        context(@"when credentails are not available", ^{
            beforeEach(^{
                [subject setUserUri:nil companyName:nil username:nil platform:@"gen3"];
            });
            it(@"should have received correct event for username", ^{
//                NSInteger usernameCustomDimentionIndex = [subject dimensionIndexForName:@"username" forTracker:TrackerEngineering];
//                NSString *unameCustomDimension = [GAIFields customDimensionForIndex:usernameCustomDimentionIndex];

                tagDataLayer should have_received(@selector(push:)).with(@{@"company": @"na", @"userName": @"na", @"repliconPlatformVersion": @"gen3"});
            });

        });

        
    });

    describe(@"trackNonFatalError:description withErrorID:errorID", ^{
        beforeEach(^{
            subject.engineeringTracker = nice_fake_for(@protocol(GAITracker));

            [subject trackNonFatalError:@"description" withErrorID:@"errorID" withErrorType:@"technical"];
        });
        it(@"should have received send event", ^{
            NSMutableDictionary *event = [[GAIDictionaryBuilder createExceptionWithDescription:@"description"
                                                                                     withFatal:[NSNumber numberWithBool:NO]] build];
            subject.engineeringTracker should have_received(@selector(send:)).with(event);

            NSInteger uniqueIdCustomDimentionIndex = [subject dimensionIndexForName:@"uniqueid" forTracker:TrackerEngineering];
            NSString *uniqueIdCustomDimention = [GAIFields customDimensionForIndex:uniqueIdCustomDimentionIndex];

            subject.engineeringTracker should have_received(@selector(set:value:)).with(uniqueIdCustomDimention, @"errorID");

            subject.engineeringTracker should have_received(@selector(set:value:)).with(uniqueIdCustomDimention, nil);
        });
    });

    describe(@"trackCrash:exception", ^{
        beforeEach(^{
            subject.engineeringTracker = nice_fake_for(@protocol(GAITracker));
            NSException *exception = [[NSException alloc] init];
            [subject trackCrash:exception];
        });
        it(@"should have received send event", ^{
            NSException *exception = [[NSException alloc] init];
            NSMutableDictionary *event = [[GAIDictionaryBuilder createExceptionWithDescription:exception.debugDescription
                                                                                     withFatal:[NSNumber numberWithBool:YES]] build];
            subject.engineeringTracker should have_received(@selector(send:)).with(event);
        });
    });

    describe(@"trackUIEvent:forTracker:", ^{
        beforeEach(^{
            [subject trackUIEvent:@"testEvent" forTracker:TrackerProduct];
        });
        it(@"should have push event", ^{
            subject.productDataLayer should have_received(@selector(push:)).with(@{@"event": @"GAEvent", @"eventCategory": @"ui", @"eventAction": @"testevent", @"eventLabel": [NSNull null], @"eventValue": @"0"});
        });
    });

    describe(@"trackScreenView:forTracker:", ^{
        beforeEach(^{
            [subject trackScreenView:@"testScreenView" forTracker:TrackerProduct];
        });
        it(@"should have push screen view", ^{
            subject.productDataLayer should have_received(@selector(push:)).with(@{@"event": @"openScreen", @"screenName": @"testscreenview"});
        });
    });

});

SPEC_END
