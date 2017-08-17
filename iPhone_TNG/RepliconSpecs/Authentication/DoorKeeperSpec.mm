#import <Cedar/Cedar.h>
#import "DoorKeeper.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(DoorKeeperSpec)

describe(@"DoorKeeper", ^{
    __block DoorKeeper *subject;
    __block id<DoorKeeperLogOutObserver> fakeObserverA;
    __block id<DoorKeeperLogOutObserver> fakeObserverB;

    beforeEach(^{
        fakeObserverA = nice_fake_for(@protocol(DoorKeeperLogOutObserver));
        fakeObserverB = nice_fake_for(@protocol(DoorKeeperLogOutObserver));

        subject = [[DoorKeeper alloc] init];
    });

    describe(NSStringFromSelector(@selector(logOut)), ^{

        context(@"when observers are all still hanging around", ^{
            beforeEach(^{
                [subject addLogOutObserver:fakeObserverA];
                [subject addLogOutObserver:fakeObserverA];
                [subject addLogOutObserver:fakeObserverB];
            });

            it(@"should notify its observers once that log out has occurred", ^{
                [subject logOut];

                fakeObserverA should have_received(@selector(doorKeeperDidLogOut:)).with(subject);
                [(id<CedarDouble>)fakeObserverA sent_messages].count should equal(1);
                fakeObserverB should have_received(@selector(doorKeeperDidLogOut:)).with(subject);
            });
        });

        context(@"when an observers has been released", ^{
            it(@"should notify its observers once that log out has occurred", ^{

                __weak id<DoorKeeperLogOutObserver> observer;
                @autoreleasepool {
                    observer = nice_fake_for(@protocol(DoorKeeperLogOutObserver));
                    [subject addLogOutObserver:observer];
                    [subject addLogOutObserver:fakeObserverA];
                }

                ^ { [subject logOut]; } should_not raise_exception;
                fakeObserverA should have_received(@selector(doorKeeperDidLogOut:)).with(subject);
            });
        });
    });
});

SPEC_END
