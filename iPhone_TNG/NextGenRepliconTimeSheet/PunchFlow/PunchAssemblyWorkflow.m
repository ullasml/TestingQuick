#import <MacTypes.h>
#import "PunchAssemblyWorkflow.h"
#import <KSDeferred/KSDeferred.h>
#import "Geolocation.h"
#import "Geolocator.h"
#import "UserPermissionsStorage.h"
#import "OfflineLocalPunch.h"
#import "PunchAssemblyGuard.h"
#import "ManualPunch.h"
#import "LocalPunch.h"
#import "Enum.h"
#import "PunchOutboxStorage.h"


@interface PunchAssemblyWorkflow()

@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) PunchAssemblyGuard *punchAssemblyGuard;
@property (nonatomic) Geolocator *geolocator;
@property (nonatomic) PunchOutboxStorage *punchOutboxStorage;
@end


@implementation PunchAssemblyWorkflow

- (instancetype)initWithPunchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                       punchAssemblyGuard:(PunchAssemblyGuard *)punchAssemblyGuard
                               geolocator:(Geolocator *)geolocator
                       punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage

{
    self = [super init];
    if (self) {
        self.punchRulesStorage = punchRulesStorage;
        self.punchAssemblyGuard = punchAssemblyGuard;
        self.geolocator = geolocator;
        self.punchOutboxStorage = punchOutboxStorage;
    }
    return self;
}

- (KSPromise *)assembleIncompletePunch:(LocalPunch *)incompletePunch
           serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                              delegate:(id<PunchAssemblyWorkflowDelegate>)delegate {

    KSDeferred *punchDeferred = [[KSDeferred alloc] init];


    [[self.punchAssemblyGuard shouldAssemble] then:^id(id value) {

        KSDeferred *imageDeferred = [self imageDeferredForDelegate:delegate];
        KSDeferred *geoLocationDeferred = [self geolocationDeferred];

        [self assemblePunchWithGeolocationPromise:geoLocationDeferred.promise
                                    punchDeferred:punchDeferred
                                  incompletePunch:incompletePunch
                                     imagePromise:imageDeferred.promise];

        id (^informDelegate)() = ^id{
            [delegate punchAssemblyWorkflow:self
        willEventuallyFinishIncompletePunch:incompletePunch
                      assembledPunchPromise:punchDeferred.promise
                serverDidFinishPunchPromise:serverDidFinishPunchPromise];
            return nil;
        };
        [imageDeferred.promise then:informDelegate error:nil];

        if (![self.punchRulesStorage selfieRequired]) {
            [imageDeferred resolveWithValue:nil];
        }
        if (![self.punchRulesStorage geolocationRequired]) {
            [geoLocationDeferred resolveWithValue:nil];
        }

        return nil;
    } error:^id(NSError *error) {
        [punchDeferred rejectWithError:nil];

        NSArray *errors = error.userInfo[PunchAssemblyGuardChildErrorsKey];
        [delegate punchAssemblyWorkflow:self
       didFailToAssembleIncompletePunch:incompletePunch
                                 errors:errors];
        return nil;
    }];


    return punchDeferred.promise;
}

- (KSPromise *)assembleManualIncompletePunch:(LocalPunch *)incompletePunch
           serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                              delegate:(id<PunchAssemblyWorkflowDelegate>)delegate {
    
    KSDeferred *punchDeferred = [[KSDeferred alloc] init];
    
    id (^informDelegate)() = ^id{
        [delegate punchAssemblyWorkflow:self
    willEventuallyFinishIncompletePunch:incompletePunch
                  assembledPunchPromise:punchDeferred.promise
            serverDidFinishPunchPromise:serverDidFinishPunchPromise];
        return nil;
    };

    [punchDeferred.promise then:informDelegate error:nil];
    
    [punchDeferred resolveWithValue:incompletePunch];
    
    return punchDeferred.promise;
}

#pragma mark - Private

- (KSDeferred *)imageDeferredForDelegate:(id<PunchAssemblyWorkflowDelegate>)delegate
{
    KSDeferred *imageDeferred = [[KSDeferred alloc] init];
    if ([self.punchRulesStorage selfieRequired])
    {
        imageDeferred.promise = [delegate punchAssemblyWorkflowNeedsImage];
    }
    return imageDeferred;
}

- (KSDeferred *)geolocationDeferred {
    KSDeferred *geoLocationDeferred = [[KSDeferred alloc] init];
    if ([self.punchRulesStorage geolocationRequired])
    {
        geoLocationDeferred.promise = [self.geolocator mostRecentGeolocationPromise];
    }

    return geoLocationDeferred;
}

- (void)assemblePunchWithGeolocationPromise:(KSPromise *)geolocationPromise
                              punchDeferred:(KSDeferred *)punchDeferred
                            incompletePunch:(id<Punch>)incompletePunch
                               imagePromise:(KSPromise *)imagePromise
{
    KSPromise *joinedPromise = [KSPromise when:@[imagePromise, geolocationPromise]];

    [joinedPromise then:^id(id value) {
        Geolocation *geolocation = geolocationPromise.value;

        id <Punch> finishedPunch;
        if (incompletePunch.manual)
        {
            finishedPunch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:incompletePunch.actionType lastSyncTime:nil breakType:incompletePunch.breakType location:geolocation.location project:incompletePunch.project requestID:incompletePunch.requestID activity:incompletePunch.activity client:incompletePunch.client oefTypes:incompletePunch.oefTypesArray address:geolocation.address userURI:incompletePunch.userURI image:imagePromise.value task:incompletePunch.task date:incompletePunch.date];
        }
        else if (incompletePunch.offline)
        {
            finishedPunch = [[OfflineLocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:incompletePunch.actionType lastSyncTime:nil breakType:incompletePunch.breakType location:geolocation.location project:incompletePunch.project requestID:incompletePunch.requestID activity:incompletePunch.activity client:incompletePunch.client oefTypes:incompletePunch.oefTypesArray address:geolocation.address userURI:incompletePunch.userURI image:imagePromise.value task:incompletePunch.task date:incompletePunch.date];
        }
        else
        {
            finishedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:incompletePunch.actionType lastSyncTime:nil breakType:incompletePunch.breakType location:geolocation.location project:incompletePunch.project requestID:incompletePunch.requestID activity:incompletePunch.activity client:incompletePunch.client oefTypes:incompletePunch.oefTypesArray address:geolocation.address userURI:incompletePunch.userURI image:imagePromise.value task:incompletePunch.task date:incompletePunch.date];

            [self.punchOutboxStorage storeLocalPunch:finishedPunch];
        }

        

        [punchDeferred resolveWithValue:finishedPunch];

        return nil;
    } error:nil];
}

@end
