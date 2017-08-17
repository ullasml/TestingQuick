#import <Cedar/Cedar.h>
#import "BaseSyncOperationManager.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "TimesheetSyncOperationManager.h"
#import "TimerProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(BaseSyncOperationManagerSpec)

xdescribe(@"BaseSyncOperationManager", ^{
    __block BaseSyncOperationManager *subject;
    __block TimesheetSyncOperationManager *timesheetSyncOperationManager;
    __block id<BSBinder, BSInjector> injector;
    __block TimerProvider *timerProvider;

    beforeEach(^{

        injector = [InjectorProvider injector];
        
        timesheetSyncOperationManager = nice_fake_for([TimesheetSyncOperationManager class]);
        [injector bind:[TimesheetSyncOperationManager class] toInstance:timesheetSyncOperationManager];

        timerProvider = nice_fake_for([TimerProvider class]);
        [injector bind:[TimerProvider class] toInstance:timerProvider];

        subject = [injector getInstance:[BaseSyncOperationManager class]];
    });


    it(@"timesheetSyncOperationManager should be correctly assigned", ^{
        subject.timesheetSyncOperationManager should be_same_instance_as(timesheetSyncOperationManager);
    });

    
    describe(@"startSync", ^{
        __block NSTimer *timer;
        beforeEach(^{
            timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:subject
                                                   selector:@selector(startSync)
                                                   userInfo:nil
                                                    repeats:NO];
            timerProvider stub_method(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo
                                                :repeats:)).and_return(timer);
            [subject startSync];
        });

        it(@"Invalidating the timer", ^{
            subject.startOfflineSyncingTimer.isValid should be_falsy;
        });

        context(@"should start timesheetSyncOperationManager pending sync", ^{
            beforeEach(^{
                __block volatile bool loadComplete = false;
                dispatch_async(dispatch_get_main_queue(), ^{

                    CFRunLoopStop(CFRunLoopGetCurrent());

                    loadComplete = true;

                });


                NSDate* startTime = [NSDate date];
                while ( !loadComplete )
                {


                    NSDate* nextTry = [NSDate dateWithTimeIntervalSinceNow:0.1];
                    [[NSRunLoop currentRunLoop] runUntilDate:nextTry];
                    
                    if ( [nextTry timeIntervalSinceDate:startTime]/* some appropriate time interval here */ )
                        NSLog(@"");
                }
            });

            it(@"timesheetSyncOperationManager have received correct selector", ^{
                timesheetSyncOperationManager should have_received(@selector(startPendingQueueSync:)).with(subject);
            });

            it(@"should set up a timer that runs every minute", ^{
                [(id<CedarDouble>)timerProvider sent_messages].count should equal(1);
                timerProvider should have_received(@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:)).with(900.0, subject, @selector(startSync), nil, NO);
            });
        });

    });
});

SPEC_END
