#import "PunchHomeController.h"
#import "PunchImagePickerControllerProvider.h"
#import "ImageNormalizer.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchControllerProvider.h"
#import "RemotePunch.h"
#import "AllowAccessAlertHelper.h"
#import "Constants.h"
#import "CameraViewController.h"
#import <Blindside/BSInjector.h>
#import "UserSession.h"
#import "OEFTypeStorage.h"
#import "PunchClock.h"
#import "DelayedTodaysPunchesRepository.h"
#import "DateProvider.h"
#import "TimeLineAndRecentPunchRepository.h"
#import "TimeLinePunchesSummary.h"
#import "TimeLinePunchesStorage.h"

@interface PunchHomeController ()
@property (weak, nonatomic) IBOutlet UIView *cameraContainerView;

@property (nonatomic) PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
@property (nonatomic) PunchControllerProvider *punchControllerProvider;
@property (nonatomic) ImageNormalizer *imageNormalizer;
@property (nonatomic) PunchRepository *punchRepository;
@property (nonatomic) PunchClock *punchClock;
@property (nonatomic) AllowAccessAlertHelper *allowAccessAlertHelper;

@property (nonatomic) NSDate *mostRecentPunchDate;
@property (nonatomic) KSDeferred *imageDeferred;

@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) OEFTypeStorage *oefTypeStorage;
@property (nonatomic,weak) id<BSInjector> injector;

@property (nonatomic) id <Punch> mostRecentPunch;

@property (nonatomic) NSArray *timelinePunches;
@property (nonatomic,assign) BOOL firstTimeUser;
@property (nonatomic) TimeLinePunchesStorage *timeLinePunchesStorage;
@end


@implementation PunchHomeController

- (instancetype)initWithPunchImagePickerControllerProvider:(PunchImagePickerControllerProvider *)punchImagePickerControllerProvider
                                   punchControllerProvider:(PunchControllerProvider *)punchControllerProvider
                                    allowAccessAlertHelper:(AllowAccessAlertHelper *)allowAccessAlertHelper
                                           imageNormalizer:(ImageNormalizer *)imageNormalizer
                                           punchRepository:(PunchRepository *)punchRepository
                                            oefTypeStorage:(OEFTypeStorage *)oefTypeStorage
                                               userSession:(id <UserSession>)userSession
                                                punchClock:(PunchClock *)punchClock
                                    timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.punchImagePickerControllerProvider = punchImagePickerControllerProvider;
        self.punchControllerProvider = punchControllerProvider;
        self.allowAccessAlertHelper = allowAccessAlertHelper;
        self.imageNormalizer = imageNormalizer;
        self.punchRepository = punchRepository;
        [self.punchRepository addObserver:self];
        self.punchClock = punchClock;
        self.userSession = userSession;
        self.oefTypeStorage = oefTypeStorage;
        self.timeLinePunchesStorage = timeLinePunchesStorage;
    }
    return self;
}

- (void)fetchAndDisplayChildControllerForMostRecentPunch
{
    [self.punchRepository fetchMostRecentPunchFromServerForUserUri:self.userSession.currentUserURI];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIViewController *controller = [[UIViewController alloc] init];
    [self addChildViewController:controller];
    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];




}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController.tabBarController.tabBar setHidden:NO];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    for (UIViewController *childController in self.childViewControllers)
    {
        childController.view.frame = self.view.bounds;
    }


    KSPromise *punchesPromise = [self.punchRepository fetchMostRecentPunchForUserUri:self.userSession.currentUserURI];
    [punchesPromise then:^id (TimeLinePunchesSummary *timeLinePunchesSummary) {
        id <Punch> mostRecentPunch = timeLinePunchesSummary.allPunches.lastObject;
        if (mostRecentPunch)
        {
            self.firstTimeUser = NO;
        }
        if(((![self.mostRecentPunch isEqual:mostRecentPunch] && ![self.mostRecentPunch.requestID isEqualToString:mostRecentPunch.requestID]) || ![self.timelinePunches isEqual:timeLinePunchesSummary.timeLinePunches]) && !self.firstTimeUser)
        {
            UIViewController *oldController = self.childViewControllers.firstObject;
            UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                            serverDidFinishPunchPromise:nil
                                                                                  assembledPunchPromise:nil
                                                                                                  punch:mostRecentPunch
                                                                                         punchesPromise:punchesPromise];
            [self replaceOldController:oldController withNewController:newController];

            self.mostRecentPunch = mostRecentPunch;
            self.timelinePunches = timeLinePunchesSummary.timeLinePunches;
            if (self.mostRecentPunch == nil && self.timelinePunches.count == 0)
            {
                self.firstTimeUser = YES;
            }
        }
        else if (mostRecentPunch)
        {
            self.firstTimeUser = NO;
        }


        return nil;
    } error:^id (NSError *error) {
        return nil;
    }];

}


#pragma mark - <PunchRepositoryObserver>

- (void) punchRepositoryDidDiscoverFirstTimeUse:(PunchRepository *)punchRepository
{
    TimeLineAndRecentPunchRepository *timeLineAndRecentPunchRepository = [self.injector getInstance:[TimeLineAndRecentPunchRepository class]];
    DateProvider *dateProvider = [self.injector getInstance:[DateProvider class]];
    NSDate *date = [dateProvider date];
    KSPromise *punchesPromise = [timeLineAndRecentPunchRepository punchesPromiseWithServerDidFinishPunchPromise:nil
                                                                                              timeLinePunchFlow:CardTimeLinePunchFlowContext
                                                                                                        userUri:self.userSession.currentUserURI date:date];
    UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                    serverDidFinishPunchPromise:nil
                                                                          assembledPunchPromise:nil
                                                                                          punch:nil
                                                                                 punchesPromise:punchesPromise];
    [self replaceOldController:self.childViewControllers.firstObject
             withNewController:newController];
}

- (void)punchRepository:(PunchRepository *)punchRepository didUpdateMostRecentPunch:(id<Punch>)punch
{

    if ([punch respondsToSelector:@selector(syncedWithServer)] && punch.syncedWithServer)
    {
        DateProvider *dateProvider = [self.injector getInstance:[DateProvider class]];
        NSDate *date = [dateProvider date];
        NSArray *filteredPunches = [self.timeLinePunchesStorage allPunchesForDay:date userUri:self.userSession.currentUserURI];
        TimeLinePunchesSummary *timeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:NULL
                                                                                                timeLinePunches:filteredPunches
                                                                                                     allPunches:[self.timeLinePunchesStorage recentPunchesForUserUri:self.userSession.currentUserURI]];

        if (punch)
        {
            self.firstTimeUser = NO;
        }

        if((![self.mostRecentPunch isEqual:punch] || ![self.timelinePunches isEqual:timeLinePunchesSummary.timeLinePunches]) && !self.firstTimeUser)
        {
            UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                            serverDidFinishPunchPromise:nil
                                                                                  assembledPunchPromise:nil
                                                                                                  punch:punch
                                                                                         punchesPromise:nil];
            [self replaceOldController:self.childViewControllers.firstObject
                     withNewController:newController];
        }



        self.mostRecentPunch = punch;
        self.timelinePunches = timeLinePunchesSummary.timeLinePunches;

        id <Punch> mostRecentPunch = timeLinePunchesSummary.allPunches.lastObject;
        if (!mostRecentPunch)
        {
            self.firstTimeUser = YES;
        }
    }



}

- (void)punchRepositoryDidSyncPunches:(PunchRepository *)punchRepository
{
    KSPromise *punchesPromise = [self.punchRepository fetchMostRecentPunchForUserUri:self.userSession.currentUserURI];
    [punchesPromise then:^id (TimeLinePunchesSummary *timeLinePunchesSummary) {
        id <Punch> mostRecentPunch = timeLinePunchesSummary.allPunches.lastObject;
        if (mostRecentPunch)
        {
            self.firstTimeUser = NO;
        }
        if((![self.mostRecentPunch isEqual:mostRecentPunch] || ![self.timelinePunches isEqual:timeLinePunchesSummary.timeLinePunches]) && !self.firstTimeUser)
        {
            UIViewController *oldController = self.childViewControllers.firstObject;
            UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                            serverDidFinishPunchPromise:nil
                                                                                  assembledPunchPromise:nil
                                                                                                  punch:mostRecentPunch
                                                                                         punchesPromise:punchesPromise];
            [self replaceOldController:oldController withNewController:newController];

            self.mostRecentPunch = mostRecentPunch;
            self.timelinePunches = timeLinePunchesSummary.timeLinePunches;
            if (self.mostRecentPunch == nil && self.timelinePunches.count == 0)
            {
                self.firstTimeUser = YES;
            }
        }
        else if (mostRecentPunch)
        {
            self.firstTimeUser = NO;
        }


        return nil;
    } error:^id (NSError *error) {
        return nil;
    }];
}

#pragma mark - <PunchInControllerDelegate>

- (void)punchInControllerDidPunchIn:(PunchInController *)punchInController
{
    [self.punchClock punchInWithPunchAssemblyWorkflowDelegate:self oefData:nil];
}

#pragma mark - <PunchOutDelegate>

- (void)controllerDidPunchOut:(UIViewController *)controller
{
    [self.punchClock punchOutWithPunchAssemblyWorkflowDelegate:self oefData:nil];
}

#pragma mark - <PunchOutControllerDelegate>

- (void)punchOutControllerDidTakeBreakWithDate:(NSDate *)breakDate
                                     breakType:(BreakType *)breakType
{
    [self.punchClock takeBreakWithBreakDate:breakDate
                                  breakType:breakType
              punchAssemblyWorkflowDelegate:self];
}

#pragma mark - <OnBreakControllerDelegate>

- (void)onBreakControllerDidResumeWork:(OnBreakController *)onBreakController
{
    [self.punchClock resumeWorkWithPunchAssemblyWorkflowDelegate:self oefData:nil];
}

#pragma  mark - <PunchAssemblyWorkflowDelegate>

- (KSPromise *)punchAssemblyWorkflowNeedsImage
{
    self.imageDeferred = [[KSDeferred alloc] init];
    UIImagePickerController *punchImagePickerController = [self.punchImagePickerControllerProvider provideInstanceWithDelegate:self];
    [self presentViewController:punchImagePickerController animated:YES completion:NULL];
    return self.imageDeferred.promise;
}

- (void) punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
              assembledPunchPromise:(KSPromise *)assembledPunchPromise
        serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
{

    

    UIViewController *oldController = self.childViewControllers.firstObject;
    UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                    serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                                                          assembledPunchPromise:assembledPunchPromise
                                                                                          punch:incompletePunch punchesPromise:nil];

    [self replaceOldController:oldController withNewController:newController];

    self.mostRecentPunch = incompletePunch;

    DateProvider *dateProvider = [self.injector getInstance:[DateProvider class]];
    NSDate *date = [dateProvider date];
    NSArray *filteredPunches = [self.timeLinePunchesStorage allPunchesForDay:date userUri:self.userSession.currentUserURI];
    TimeLinePunchesSummary *timeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:NULL
                                                                                            timeLinePunches:filteredPunches
                                                                                                 allPunches:[self.timeLinePunchesStorage recentPunchesForUserUri:self.userSession.currentUserURI]];
    self.timelinePunches = timeLinePunchesSummary.timeLinePunches;

}

- (void) punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow didFailToAssembleIncompletePunch:(LocalPunch *)incompletePunch errors:(NSArray *)errors
{
    NSError *locationError;
    NSError *cameraError;

    for(NSError *error in errors)
    {
        if([error.domain isEqualToString:CameraAssemblyGuardErrorDomain])
        {
            cameraError = error;
        } else if([error.domain isEqualToString:LocationAssemblyGuardErrorDomain])
        {
            locationError = error;
        }
    }

    [self.allowAccessAlertHelper handleLocationError:locationError cameraError:cameraError];
}

#pragma mark - <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        UIImage *normalizedImage = [self.imageNormalizer normalizeImage:originalImage];
        [self.imageDeferred resolveWithValue:normalizedImage];
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)imagePickerController
{
    [self.imageDeferred rejectWithError:nil];
    [imagePickerController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Private

- (void)replaceOldController:(UIViewController *)oldController
           withNewController:(UIViewController *)newController
{
    [self addChildViewController:newController];
    newController.view.frame = self.view.bounds;
    [self.view addSubview:newController.view];
    [newController didMoveToParentViewController:self];

    [oldController willMoveToParentViewController:nil];
    [oldController.view removeFromSuperview];
    [oldController removeFromParentViewController];
}



@end
