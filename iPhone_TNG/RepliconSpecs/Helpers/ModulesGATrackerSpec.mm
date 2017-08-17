#import <Cedar/Cedar.h>
#import "ModulesGATracker.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "FrameworkImport.h"
#import "UserPermissionsStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ModulesGATrackerSpec)

describe(@"ModulesGATracker", ^{
    __block ModulesGATracker *subject;
    __block GATracker *tracker;
    __block id<BSInjector, BSBinder> injector;
    __block UserPermissionsStorage* userPermissionsStorage;
    beforeEach(^{

        injector = [InjectorProvider injector];

        tracker = nice_fake_for([GATracker class]);
        [injector bind:[GATracker class] toInstance:tracker];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];

        subject = [injector getInstance:[ModulesGATracker class]];
    });

    describe(@"sendGAEventForModule:", ^{
        context(@"when module is punch history", ^{
            beforeEach(^{
                [subject sendGAEventForModule:11];
            });
            it(@"should received event for GA Tracker", ^{
                tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_punch_history", TrackerProduct);
            });

        });

        context(@"when module is timesheets", ^{
            context(@"when astro flow", ^{
                context(@"--when simple astro flow", ^{
                    beforeEach(^{
                        [subject sendGAEventForModule:1];
                    });
                    it(@"should received event for GA Tracker", ^{
                        tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_timesheets_punch", TrackerProduct);
                    });
                });
                context(@"--when astro into projects", ^{
                    beforeEach(^{
                        [subject sendGAEventForModule:2];
                    });
                    it(@"should received event for GA Tracker", ^{
                        tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_timesheets_punch", TrackerProduct);
                    });
                });
                context(@"--when astro into activities", ^{
                    beforeEach(^{
                        [subject sendGAEventForModule:3];
                    });
                    it(@"should received event for GA Tracker", ^{
                        tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_timesheets_punch", TrackerProduct);
                    });
                });



            });
            context(@"when non-astro user", ^{

                context(@"when user has time punch access", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasTimePunchAccess)).and_return(YES);
                        [subject sendGAEventForModule:4];
                    });
                    it(@"should received event for GA Tracker", ^{
                        tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_timesheets_punch", TrackerProduct);
                    });
                });
                context(@"when user has no time punch access", ^{
                    beforeEach(^{
                        userPermissionsStorage stub_method(@selector(hasTimePunchAccess)).and_return(NO);
                        [subject sendGAEventForModule:4];
                    });
                    it(@"should received event for GA Tracker", ^{
                        tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_timesheets", TrackerProduct);
                    });
                });

            });

        });

        context(@"when module is expenses", ^{
            beforeEach(^{
                [subject sendGAEventForModule:7];
            });
            it(@"should received event for GA Tracker", ^{
                tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_expenses", TrackerProduct);
            });
        });
        context(@"when module is schedule", ^{
            beforeEach(^{
                [subject sendGAEventForModule:5];
            });
            it(@"should received event for GA Tracker", ^{
                tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_schedule", TrackerProduct);
            });
        });
        context(@"when module is time punches", ^{
            beforeEach(^{
                [subject sendGAEventForModule:12];
            });
            it(@"should received event for GA Tracker", ^{
                tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"team_time_punches", TrackerProduct);
            });
        });
        context(@"when module is dashboard", ^{
            beforeEach(^{
                [subject sendGAEventForModule:6];
            });
            it(@"should received event for GA Tracker", ^{
                tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"team_dashboard", TrackerProduct);
            });
        });
        context(@"when module is settings", ^{
            beforeEach(^{
                [subject sendGAEventForModule:9];
            });
            it(@"should received event for GA Tracker", ^{
                tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"settings", TrackerProduct);
            });
        });


        context(@"when trying to send two same events back to back", ^{
            __block BOOL firstReturnValue = NO;
            beforeEach(^{
                firstReturnValue = [subject sendGAEventForModule:7];
            });
            it(@"should have received only one event for GA Tracker", ^{
                tracker should have_received(@selector(trackScreenView:forTracker:)).with(@"my_replicon_expenses", TrackerProduct);
                firstReturnValue should equal(YES);
                BOOL secondReturnValue = [subject sendGAEventForModule:7];
                secondReturnValue should equal(NO);
                
            });
            
        });
    });

});

SPEC_END
