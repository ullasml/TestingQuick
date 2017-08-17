#import "PunchControllerProvider.h"

#import "OnBreakController.h"
#import "PunchInController.h"
#import "PunchOutController.h"
#import <KSDeferred/KSPromise.h>
#import "LocalPunch.h"
#import "AddressControllerPresenterProvider.h"
#import <Blindside/BSInjector.h>


@interface PunchControllerProvider ()

@property (nonatomic) AddressControllerPresenterProvider *addressControllerPresenterProvider;

@property (nonatomic, weak) id<BSInjector> injector;

@end


@implementation PunchControllerProvider

- (instancetype)initWithAddressControllerPresenterProvider:(AddressControllerPresenterProvider *)addressControllerPresenterProvider {
    self = [super init];
    if (self)
    {
        self.addressControllerPresenterProvider = addressControllerPresenterProvider;
    }
    return self;
}

- (UIViewController *)punchControllerWithDelegate:(id<PunchInControllerDelegate, PunchOutControllerDelegate, OnBreakControllerDelegate>)delegate
                      serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                            assembledPunchPromise:(KSPromise *)assembledPunchPromise
                                            punch:(LocalPunch *)punch
                                   punchesPromise:(KSPromise *)punchesPromise
{
    if (!punch || punch.actionType == PunchActionTypePunchOut)
    {
        PunchInController *punchInController = [self.injector getInstance:[PunchInController class]];

        [punchInController setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise
                                                       delegate:delegate
                                                 punchesPromise:punchesPromise];

        return punchInController;
    }
    else if (punch.actionType == PunchActionTypeStartBreak)
    {
        AddressControllerPresenter *addressControllerPresenter = [self.addressControllerPresenterProvider provideInstanceWith:assembledPunchPromise];

        OnBreakController *onBreakController = [self.injector getInstance:[OnBreakController class]];

        [onBreakController setupWithAddressControllerPresenter:addressControllerPresenter
                                   serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                                      delegate:delegate
                                                         punch:punch
                                                punchesPromise:punchesPromise];
        return onBreakController;
    }
    else if (punch.actionType == PunchActionTypePunchIn || punch.actionType == PunchActionTypeTransfer)
    {
        AddressControllerPresenter *addressControllerPresenter = [self.addressControllerPresenterProvider provideInstanceWith:assembledPunchPromise];

        PunchOutController *punchOutController = [self.injector getInstance:[PunchOutController class]];

        [punchOutController setupWithAddressControllerPresenter:addressControllerPresenter
                                    serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                                       delegate:delegate
                                                          punch:punch
                                                 punchesPromise:punchesPromise];
        return punchOutController;
    }

    PunchInController *punchInController = [self.injector getInstance:[PunchInController class]];

    [punchInController setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise delegate:delegate punchesPromise:punchesPromise];

    return punchInController;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
