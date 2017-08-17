
#import "PunchIntoProjectHomeController.h"
#import "PunchImagePickerControllerProvider.h"
#import "ImageNormalizer.h"
#import <KSDeferred/KSDeferred.h>
#import "RemotePunch.h"
#import "AllowAccessAlertHelper.h"
#import "Constants.h"
#import "CameraViewController.h"
#import <Blindside/BSInjector.h>
#import "UserSession.h"
#import "PunchRepository.h"
#import "PunchClock.h"
#import "PunchIntoProjectControllerProvider.h"
#import "PunchCardObject.h"
#import "PunchCardStorage.h"
#import "AllPunchCardController.h"
#import "ProjectCreatePunchCardController.h"
#import "MostRecentPunchInDetector.h"
#import "UserPermissionsStorage.h"
#import "TimesheetClientProjectTaskRepository.h"
#import "MostRecentActivityPunchDetector.h"
#import "OEFTypeStorage.h"
#import "OEFCollectionPopUpViewController.h"
#import "DateProvider.h"
#import "DelayedTodaysPunchesRepository.h"
#import "TimeLinePunchesSummary.h"
#import "TimeLineAndRecentPunchRepository.h"
#import "Enum.h"
#import "GUIDProvider.h"
#import "OEFDropDownRepository.h"
#import "BookmarksHomeViewController.h"
#import "InjectorKeys.h"
#import "TimeLinePunchesStorage.h"

@interface PunchIntoProjectHomeController ()

@property (nonatomic) PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
@property (nonatomic) PunchIntoProjectControllerProvider *punchControllerProvider;
@property (nonatomic) ImageNormalizer *imageNormalizer;
@property (nonatomic) PunchRepository *punchRepository;
@property (nonatomic) PunchClock *punchClock;
@property (nonatomic) AllowAccessAlertHelper *allowAccessAlertHelper;

@property (nonatomic) NSDate *mostRecentPunchDate;
@property (nonatomic) KSDeferred *imageDeferred;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) PunchCardStorage *punchCardStorage;
@property (nonatomic) id <Punch> mostRecentPunch;
@property (nonatomic) MostRecentPunchInDetector *mostRecentPunchInDetector;
@property (nonatomic) MostRecentActivityPunchDetector *mostRecentActivityPunchDetector;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) OEFTypeStorage *oefTypeStorage;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) PunchCardObject *punchCardObject;

@property (nonatomic) NSArray *timelinePunches;

@property (weak, nonatomic) id<BSInjector> injector;

@property (nonatomic,assign) BOOL firstTimeUser;
@property (nonatomic) TimeLinePunchesStorage *timeLinePunchesStorage;
@end


@implementation PunchIntoProjectHomeController

- (instancetype)initWithPunchImagePickerControllerProvider:(PunchImagePickerControllerProvider *)punchImagePickerControllerProvider
                           mostRecentActivityPunchDetector:(MostRecentActivityPunchDetector *)mostRecentActivityPunchDetector
                                 mostRecentPunchInDetector:(MostRecentPunchInDetector *)mostRecentPunchInDetector
                                   punchControllerProvider:(PunchIntoProjectControllerProvider *)punchControllerProvider
                                    allowAccessAlertHelper:(AllowAccessAlertHelper *)allowAccessAlertHelper
                                    userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                          punchCardStorage:(PunchCardStorage *)punchCardStorage
                                           imageNormalizer:(ImageNormalizer *)imageNormalizer
                                           punchRepository:(PunchRepository *)punchRepository
                                            oefTypeStorage:(OEFTypeStorage *)oefTypeStorage
                                               userSession:(id <UserSession>)userSession
                                              dateProvider:(DateProvider *)dateProvider
                                                punchClock:(PunchClock *)punchClock
                                    timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.punchImagePickerControllerProvider = punchImagePickerControllerProvider;
        self.mostRecentPunchInDetector = mostRecentPunchInDetector;
        self.mostRecentActivityPunchDetector = mostRecentActivityPunchDetector;
        self.punchControllerProvider = punchControllerProvider;
        self.allowAccessAlertHelper = allowAccessAlertHelper;
        self.userPermissionsStorage = userPermissionsStorage;
        self.imageNormalizer = imageNormalizer;
        self.punchRepository = punchRepository;
        self.punchCardStorage = punchCardStorage;
        [self.punchRepository addObserver:self];
        self.punchClock = punchClock;
        self.userSession = userSession;
        self.oefTypeStorage = oefTypeStorage;
        self.dateProvider = dateProvider;
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

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    [self setExtendedLayoutIncludesOpaqueBars:YES];

    self.title = RPLocalizedString(TimeSheetLabelText, TimeSheetLabelText);
    
    UIViewController *controller = [[UIViewController alloc] init];
    [self addChildViewController:controller];
    controller.view.frame = self.view.bounds;
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    self.navigationItem.leftBarButtonItem = [self focusCreateCreateBookmarksButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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

        [self updatePunchCardUIToDefaultIfPenultimatePunchCPTisInvalid:timeLinePunchesSummary];

        if(((![self.mostRecentPunch isEqual:mostRecentPunch] && ![self.mostRecentPunch.requestID isEqualToString:mostRecentPunch.requestID]) || ![self.timelinePunches isEqual:timeLinePunchesSummary.timeLinePunches]) && !self.firstTimeUser)
        {

            UIViewController *oldController = self.childViewControllers.firstObject;
            UIViewController  *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                             serverDidFinishPunchPromise:nil
                                                                                   assembledPunchPromise:nil
                                                                                         punchCardObject:self.punchCardObject
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
    KSPromise *punchesPromise = [timeLineAndRecentPunchRepository punchesPromiseWithServerDidFinishPunchPromise:nil timeLinePunchFlow:CardTimeLinePunchFlowContext userUri:self.userSession.currentUserURI date:self.dateProvider.date];
    UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                    serverDidFinishPunchPromise:nil
                                                                          assembledPunchPromise:nil
                                                                                punchCardObject:self.punchCardObject
                                                                                          punch:nil
                                                                                 punchesPromise:punchesPromise];
    [self replaceOldController:self.childViewControllers.firstObject
             withNewController:newController];
}

- (void)punchRepository:(PunchRepository *)punchRepository didUpdateMostRecentPunch:(id<Punch>)punch
{

    if ([punch respondsToSelector:@selector(syncedWithServer)] && punch.syncedWithServer)
    {
        NSArray *filteredPunches = [self.timeLinePunchesStorage allPunchesForDay:self.dateProvider.date userUri:self.userSession.currentUserURI];
        TimeLinePunchesSummary *timeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:NULL
                                                                                                timeLinePunches:filteredPunches
                                                                                                     allPunches:[self.timeLinePunchesStorage recentPunchesForUserUri:self.userSession.currentUserURI]];

        if (punch)
        {
            self.firstTimeUser = NO;
        }

        [self updatePunchCardUIToDefaultIfPenultimatePunchCPTisInvalid:timeLinePunchesSummary];


        if((![self.mostRecentPunch isEqual:punch] || ![self.timelinePunches isEqual:timeLinePunchesSummary.timeLinePunches]) && !self.firstTimeUser)
        {
            UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                            serverDidFinishPunchPromise:nil
                                                                                  assembledPunchPromise:nil
                                                                                        punchCardObject:self.punchCardObject
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

- (void)punchRepository:(PunchRepository *)punchRepository handleInvalidCPTWithPunch:(id<Punch>)punch {
    if([punch respondsToSelector:@selector(isTimeEntryAvailable)] && ![punch isTimeEntryAvailable]) {

        PunchCardObject *cardObject = [[PunchCardObject alloc] initWithClientType:nil projectType:nil oefTypesArray:punch.oefTypesArray breakType:punch.breakType taskType:nil activity:nil uri:nil];

        UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                        serverDidFinishPunchPromise:nil
                                                                              assembledPunchPromise:nil
                                                                                    punchCardObject:cardObject
                                                                                              punch:punch
                                                                                     punchesPromise:nil];
        [self replaceOldController:self.childViewControllers.firstObject
                 withNewController:newController];
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

        [self updatePunchCardUIToDefaultIfPenultimatePunchCPTisInvalid:timeLinePunchesSummary];

        if((![self.mostRecentPunch isEqual:mostRecentPunch] || ![self.timelinePunches isEqual:timeLinePunchesSummary.timeLinePunches]) && !self.firstTimeUser)
        {

            UIViewController *oldController = self.childViewControllers.firstObject;
            UIViewController  *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                             serverDidFinishPunchPromise:nil
                                                                                   assembledPunchPromise:nil
                                                                                         punchCardObject:self.punchCardObject
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

#pragma mark - <ProjectPunchInControllerDelegate>

- (void)projectPunchInController:(ProjectPunchInController *)punchCardController didIntendToPunchWithObject:(PunchCardObject *)punchCardObject
{
    [self.punchClock punchInWithPunchAssemblyWorkflowDelegate:self clientType:punchCardObject.clientType projectType:punchCardObject.projectType taskType:punchCardObject.taskType activity:punchCardObject.activity oefTypesArray:punchCardObject.oefTypesArray];

}

- (void)projectPunchInController:(ProjectPunchInController *)punchCardController
    didUpdatePunchCardWithObject:(PunchCardObject *)punchCardObject
{
    self.punchCardObject = punchCardObject;

}

#pragma mark - <ProjectPunchOutControllerDelegate>

- (void)controllerDidPunchOut:(UIViewController *)controller
{
    if ([self isOEFEnabled:PunchActionTypePunchOut]) {
        [self navigateToOEFCollectionPopupView:PunchActionTypePunchOut];
    }
    else{
        [self.punchClock punchOutWithPunchAssemblyWorkflowDelegate:self oefData:nil];
    }
}

#pragma mark - <ProjectPunchOutControllerDelegate>

- (void)projectPunchOutControllerDidTakeBreakWithDate:(NSDate *)breakDate
                                     breakType:(BreakType *)breakType
{
    [self.punchClock takeBreakWithBreakDate:breakDate
                                  breakType:breakType
              punchAssemblyWorkflowDelegate:self];
}

- (void)projectPunchOutControllerDidTakeBreak
{
    [self navigateToOEFCollectionPopupView:PunchActionTypeStartBreak];
}

- (void)projectPunchOutControllerDidTransfer:(ProjectPunchOutController*)projectPunchOutController
{
    [self navigateToTransferFlow];
}

#pragma mark - <OnBreakControllerDelegate>

- (void)projectonBreakControllerDidResumeWork:(ProjectOnBreakController *)onBreakController
{
    if ([self isOEFEnabled:PunchActionTypeTransfer]) {
        [self navigateToOEFCollectionPopupView:PunchActionTypeResumeWork];
    }
    else if (!self.userPermissionsStorage.hasActivityAccess && !self.userPermissionsStorage.hasProjectAccess){
        [self.punchClock resumeWorkWithPunchAssemblyWorkflowDelegate:self oefData:nil];
    }
    else{
        id <Punch> punch = [self getPunchBasedOnAccessType];
        if (punch){
             [self navigateToResumeFlowWithPunch:punch];
        }
        else
        {
            if (self.userPermissionsStorage.hasActivityAccess)
                [self userDidTapTransferUsingActivity:nil];
            else
                [self userDidTapToSeeTransferPunchCards:nil];
        }
    }
}

- (id<Punch>)getPunchBasedOnAccessType {
    id <Punch> punch =nil;
    if (self.userPermissionsStorage.hasActivityAccess) {
        punch = [self.mostRecentActivityPunchDetector mostRecentActivityPunch];
    }
    else
    {
        punch = [self.mostRecentPunchInDetector mostRecentPunchIn];
    }

    return punch;
}

#pragma mark - <AllPunchCardControllerDelegate>
-(void)allPunchCardController:(AllPunchCardController *)allPunchCardController
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
        assembledPunchPromise:(KSPromise *)assembledPunchPromise
  serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
{

    UIViewController *oldController = self.childViewControllers.firstObject;
    UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                    serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                                                          assembledPunchPromise:assembledPunchPromise
                                                                                punchCardObject:self.punchCardObject
                                                                                          punch:incompletePunch
                                                                                 punchesPromise:nil];

    [self replaceOldController:oldController withNewController:newController];

    self.mostRecentPunch = incompletePunch;

    NSArray *filteredPunches = [self.timeLinePunchesStorage allPunchesForDay:self.dateProvider.date userUri:self.userSession.currentUserURI];
    TimeLinePunchesSummary *timeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:NULL
                                                                                            timeLinePunches:filteredPunches
                                                                                                 allPunches:[self.timeLinePunchesStorage recentPunchesForUserUri:self.userSession.currentUserURI]];
    self.timelinePunches = timeLinePunchesSummary.timeLinePunches;
    
}

#pragma mark - <BookmarksHomeViewControllerDelegate>
- (void)bookmarksHomeViewController:(BookmarksHomeViewController *)bookmarksHomeViewController
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
              assembledPunchPromise:(KSPromise *)assembledPunchPromise
        serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise;
{
    self.mostRecentPunch = incompletePunch;
    UIViewController *oldController = self.childViewControllers.firstObject;
    UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                    serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                                                          assembledPunchPromise:assembledPunchPromise
                                                                                punchCardObject:self.punchCardObject
                                                                                          punch:incompletePunch
                                                                                 punchesPromise:nil];
    
    [self replaceOldController:oldController withNewController:newController];
}

- (void)bookmarksHomeViewController:(BookmarksHomeViewController *)bookmarksHomeViewController
                    updatePunchCard:(PunchCardObject*)punchCardObject
{
    self.punchCardObject = punchCardObject;
    UIViewController *oldController = self.childViewControllers.firstObject;
    UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                    serverDidFinishPunchPromise:nil
                                                                          assembledPunchPromise:nil
                                                                                punchCardObject:self.punchCardObject
                                                                                          punch:self.mostRecentPunch
                                                                                 punchesPromise:nil];
    
    [self replaceOldController:oldController withNewController:newController];
}

#pragma  mark - <PunchAssemblyWorkflowDelegate>

- (KSPromise *)punchAssemblyWorkflowNeedsImage
{
    self.imageDeferred = [[KSDeferred alloc] init];
    UIImagePickerController *punchImagePickerController = [self.punchImagePickerControllerProvider provideInstanceWithDelegate:self];
    [self presentViewController:punchImagePickerController animated:YES completion:NULL];
    return self.imageDeferred.promise;
}

- (void)      punchAssemblyWorkflow:(PunchAssemblyWorkflow *)workflow
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
              assembledPunchPromise:(KSPromise *)assembledPunchPromise
        serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
{

    UIViewController *oldController = self.childViewControllers.firstObject;
    UIViewController *newController = [self.punchControllerProvider punchControllerWithDelegate:self
                                                                    serverDidFinishPunchPromise:serverDidFinishPunchPromise
                                                                          assembledPunchPromise:assembledPunchPromise
                                                                                punchCardObject:self.punchCardObject
                                                                                          punch:incompletePunch
                                                                                 punchesPromise:nil];

    [self replaceOldController:oldController withNewController:newController];

    self.mostRecentPunch = incompletePunch;

    NSArray *filteredPunches = [self.timeLinePunchesStorage allPunchesForDay:self.dateProvider.date userUri:self.userSession.currentUserURI];
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

    UIScrollView *oldScrollView = (UIScrollView *)[oldController.view viewWithTag:9999];
    CGPoint oldContentOffset = oldScrollView.contentOffset;


    [self addChildViewController:newController];
    newController.view.frame = self.view.bounds;
    [self.view addSubview:newController.view];
    [newController didMoveToParentViewController:self];

    [oldController willMoveToParentViewController:nil];
    [oldController.view removeFromSuperview];
    [oldController removeFromParentViewController];

    UIScrollView *newScrollView = (UIScrollView *)[newController.view viewWithTag:9999];
    [newScrollView setContentOffset:oldContentOffset animated:NO];


}

-(IBAction)focusBookmarkAction:(id)sender
{
    BookmarksHomeViewController *bookmarksHomeViewController = [self.injector getInstance:[BookmarksHomeViewController class]];
    [bookmarksHomeViewController setupWithDelegate:self];
    [self.navigationController pushViewController:bookmarksHomeViewController animated:YES];
}

-(UIBarButtonItem *)focusCreateCreateBookmarksButton
{
    BOOL hasActivityAccess = [self.userPermissionsStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionsStorage hasProjectAccess];
    BOOL shouldShowRightBarbutton= (!hasActivityAccess && hasProjectAccess);
    UIBarButtonItem *leftBarButtonItem = !shouldShowRightBarbutton ? nil : [self createBookmarksButton];
    return  leftBarButtonItem;
}

-(UIBarButtonItem *)createBookmarksButton
{
    UIImage *bookmarksBtnImage = [UIImage imageNamed:@"bookmarks"];
    UIButton *bookmarksBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bookmarksBtn setBackgroundImage:bookmarksBtnImage forState:UIControlStateNormal];
    bookmarksBtn.frame = CGRectMake(0.0, 0.0, bookmarksBtnImage.size.width,   bookmarksBtnImage.size.height);
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bookmarksBtn];
    [bookmarksBtn addTarget:self action:@selector(focusBookmarkAction:) forControlEvents:UIControlEventTouchUpInside];
    return  leftBarButtonItem;
}

-(IBAction)userDidTapToSeeTransferPunchCards:(id)sender
{
    AllPunchCardController *allPunchCardsController = [self.injector getInstance:[AllPunchCardController class]];
    [allPunchCardsController setUpWithDelegate:self
                                controllerType:TransferPunchCardsControllerType
                               punchCardObject:nil
                                      flowType:TransferWorkFlowType];
    [self.navigationController pushViewController:allPunchCardsController animated:YES];
}

- (PunchCardObject *)getPunchCardObjectFromPunch: (id<Punch>)punch{
    PunchCardObject *punchCard = nil;

    if(![punch isTimeEntryAvailable]) {

        PunchCardObject *emptyPunchCard = [[PunchCardObject alloc] initWithClientType:nil projectType:nil oefTypesArray:punch.oefTypesArray breakType:punch.breakType taskType:nil activity:nil uri:nil];

        punchCard = emptyPunchCard;

    } else {

        punchCard = [[PunchCardObject alloc] initWithClientType:punch.client projectType:punch.project oefTypesArray:punch.oefTypesArray breakType:punch.breakType taskType:punch.task activity:punch.activity uri:nil];
    }

    punchCard.isValidPunchCard = [punch isTimeEntryAvailable];

    return punchCard;
}

- (void)userDidTapOnResumeWorkFlowWithPunch:(id<Punch>)punch {

    PunchCardObject *punchCard = [self getPunchCardObjectFromPunch:punch];

    AllPunchCardController *allPunchCardsController = [self.injector getInstance:[AllPunchCardController class]];
    [allPunchCardsController setUpWithDelegate:self
                                controllerType:TransferPunchCardsControllerType
                               punchCardObject:punchCard
                                      flowType:ResumeWorkFlowType];
    [self.navigationController pushViewController:allPunchCardsController animated:YES];

}

-(IBAction)userDidTapTransferUsingActivity:(id)sender
{
    if ([self isOEFEnabled:PunchActionTypeTransfer]) {
        [self navigateToOEFCollectionPopupView:PunchActionTypeTransfer];
    }
    else
    {
        [self.view endEditing:YES];
        SelectionController *selectionController = [self.injector getInstance:InjectorKeySelectionControllerForPunchModule];
        [selectionController setUpWithSelectionScreenType:ActivitySelection
                                          punchCardObject:nil
                                                 delegate:self];
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:selectionController animated:YES];
    }
}

-(BOOL)isOEFEnabled:(PunchActionType)punchActionType
{
    NSArray *oefTypes =  [self.oefTypeStorage getAllOEFSForCollectAtTimeOfPunch:punchActionType];
    if ([oefTypes count]>0) {
        return YES;
    }
    return NO;
}

-(void)navigateToOEFCollectionPopupView:(PunchActionType)punchActionType
{
    OEFCollectionPopUpViewController *oefCollectionPopUpViewController = [self.injector getInstance:[OEFCollectionPopUpViewController class]];
    [oefCollectionPopUpViewController setupWithOEFCollectionPopUpViewControllerDelegate:self punchActionType:punchActionType];
    [self.navigationController pushViewController:oefCollectionPopUpViewController animated:YES];
}

- (void)navigateToTransferFlow
{
    if (self.userPermissionsStorage.hasActivityAccess) {
        [self userDidTapTransferUsingActivity:nil];
    }
    else{
        [self userDidTapToSeeTransferPunchCards:nil];
    }
}

- (void)navigateToResumeFlowWithPunch:(id<Punch>) punch {
    if (self.userPermissionsStorage.hasActivityAccess) {
        [self navigateToOEFCollectionPopupView:PunchActionTypeResumeWork];
    } else {
        [self userDidTapOnResumeWorkFlowWithPunch:punch];
    }
}

#pragma mark - <SelectionControllerDelegate>

-(id <ClientProjectTaskRepository> )selectionControllerNeedsClientProjectTaskRepository
{
    TimesheetClientProjectTaskRepository *timesheetClientProjectTaskRepository = [self.injector getInstance:[TimesheetClientProjectTaskRepository class]];
    [timesheetClientProjectTaskRepository setUpWithUserUri:self.userSession.currentUserURI];
    return timesheetClientProjectTaskRepository;
}


-(void)selectionController:(SelectionController *)selectionController didChooseActivity:(Activity *)activity
{
    BOOL isValidActivity = (activity.uri != nil && activity.uri != (id)[NSNull null] && activity.uri.length >0);
    Activity *deserializedActivity = isValidActivity ? activity:nil;
    [self.punchClock resumeWorkWithActivityAssemblyWorkflowDelegate:self activity:deserializedActivity oefTypesArray:nil];
}

#pragma mark - <OEFCollectionPopUpViewControllerDelegate>

- (void)oefCollectionPopUpViewController:(OEFCollectionPopUpViewController *)punchCardController
                       didIntendToUpdate:(PunchCardObject *)punchCardObject
                         punchActionType:(PunchActionType)punchActionType
{
    if (punchActionType == PunchActionTypeStartBreak) {
        [self.punchClock takeBreakWithBreakDateAndOEF:[self.dateProvider date]
                                            breakType:punchCardObject.breakType
                                              oefData:punchCardObject.oefTypesArray
                        punchAssemblyWorkflowDelegate:self];
    }
    else if(punchActionType == PunchActionTypeTransfer || punchActionType == PunchActionTypeResumeWork)
    {
        if (self.userPermissionsStorage.hasActivityAccess) {
            Activity *activity = punchCardObject.activity;
            BOOL isValidActivity = (activity.uri != nil && activity.uri != (id)[NSNull null] && activity.uri.length >0);
            Activity *deserializedActivity = isValidActivity ? activity:nil;
            [self.punchClock resumeWorkWithActivityAssemblyWorkflowDelegate:self activity:deserializedActivity oefTypesArray:punchCardObject.oefTypesArray];
        }
        else{
            [self.punchClock resumeWorkWithPunchProjectAssemblyWorkflowDelegate:self clientType:punchCardObject.clientType projectType:punchCardObject.projectType taskType:punchCardObject.taskType oefTypesArray:punchCardObject.oefTypesArray];
        }
    }
    else
    {
        [self.punchClock punchOutWithPunchAssemblyWorkflowDelegate:self oefData:punchCardObject.oefTypesArray];
    }
}


#pragma mark - Update Punchcard

- (void)updatePunchCardUIToDefaultIfPenultimatePunchCPTisInvalid:(TimeLinePunchesSummary *)timeLinePunchesSummary {
    PunchCardObject *penultimatePunchCard = [[self.punchCardStorage getPunchCards] firstObject];
    NSArray *recentPunches = [self.timeLinePunchesStorage recentPunches];
    for(id<Punch> punch in recentPunches) {
        if([[self getClient:penultimatePunchCard.clientType] isEqualToString:[self getClient:punch.client]] && [[self getProject:penultimatePunchCard.projectType] isEqualToString:[self getProject:punch.project]] && [[self getTask:penultimatePunchCard.taskType] isEqualToString:[self getTask:punch.task]] && [punch respondsToSelector:@selector(isTimeEntryAvailable)] && !punch.isTimeEntryAvailable) {

            penultimatePunchCard.isValidPunchCard = punch.isTimeEntryAvailable;

            [self.punchCardStorage storePunchCard:penultimatePunchCard];

            break;
        }
    }
}


- (NSString *)getClient:(ClientType*)client {
    NSString *client_ = @"";
    if(IsValidString(client.name)) {
        client_ = client.name;
    }
    return client_;
}

- (NSString *)getProject:(ProjectType*)project {
    NSString *project_ = @"";
    if(IsValidString(project.name)) {
        project_ = project.name;
    }
    return project_;
}

- (NSString *)getTask:(TaskType*)task {
    NSString *task_ = @"";
    if(IsValidString(task.name)) {
        task_ = task.name;
    }
    return task_;
}



@end

