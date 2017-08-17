
#import "PunchIntoProjectControllerProvider.h"
#import <KSDeferred/KSPromise.h>
#import "LocalPunch.h"
#import "AddressControllerPresenterProvider.h"
#import <Blindside/BSInjector.h>
#import "ProjectPunchInController.h"
#import "ProjectOnBreakController.h"
#import "ProjectPunchOutController.h"
#import "ProjectCreatePunchCardController.h"
#import "PunchCardObject.h"


@interface PunchIntoProjectControllerProvider ()

@property (nonatomic) AddressControllerPresenterProvider *addressControllerPresenterProvider;
@property (nonatomic, weak) id<BSInjector> injector;

@end


@implementation PunchIntoProjectControllerProvider

- (instancetype)initWithAddressControllerPresenterProvider:(AddressControllerPresenterProvider *)addressControllerPresenterProvider
{
    self = [super init];
    if (self)
    {
        self.addressControllerPresenterProvider = addressControllerPresenterProvider;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (UIViewController *)punchControllerWithDelegate:(id)delegate
                      serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                            assembledPunchPromise:(KSPromise *)assembledPunchPromise
                                  punchCardObject:(PunchCardObject *)punchCardObject
                                            punch:(LocalPunch *)punch
                                   punchesPromise:(KSPromise *)punchesPromise
{
    if (!punch || punch.actionType == PunchActionTypePunchOut)
    {
        ProjectPunchInController *punchInController = [self.injector getInstance:[ProjectPunchInController class]];
        [punchInController setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise
                                                       delegate:delegate
                                                punchCardObject:punchCardObject
                                                 punchesPromise:punchesPromise];
        return punchInController;
    }
    else if (punch.actionType == PunchActionTypeStartBreak)
    {
        AddressControllerPresenter *addressControllerPresenter = [self.addressControllerPresenterProvider provideInstanceWith:assembledPunchPromise];

        ProjectOnBreakController *onBreakController = [self.injector getInstance:[ProjectOnBreakController class]];

        [onBreakController setupWithAddressControllerPresenter:addressControllerPresenter
                                   serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                                      delegate:delegate
                                                         punch:punch
                                                punchesPromise:punchesPromise];
        return onBreakController;
    }
    else if ((punch.actionType == PunchActionTypePunchIn || punch.actionType == PunchActionTypeTransfer))
    {
        if(!([punch respondsToSelector:@selector(isTimeEntryAvailable)]) || ([punch respondsToSelector:@selector(isTimeEntryAvailable)] && punch.isTimeEntryAvailable)) {
            
            AddressControllerPresenter *addressControllerPresenter = [self.addressControllerPresenterProvider provideInstanceWith:assembledPunchPromise];

            ProjectPunchOutController *punchOutController = [self.injector getInstance:[ProjectPunchOutController class]];

            [punchOutController setupWithAddressControllerPresenter:addressControllerPresenter
                                        serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                                           delegate:delegate
                                                              punch:punch
                                                     punchesPromise:punchesPromise];
            return punchOutController;
        }
    }

    ProjectPunchInController *punchInController = [self.injector getInstance:[ProjectPunchInController class]];
    [punchInController setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise
                                                   delegate:delegate
                                            punchCardObject:punchCardObject
                                             punchesPromise:punchesPromise];
    return punchInController;
}

@end

