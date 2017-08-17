#import "PunchClock.h"
#import "PunchRepository.h"
#import "LocationRepository.h"
#import "DateProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "OfflineLocalPunch.h"
#import "BreakType.h"
#import "UserSession.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "ManualPunch.h"
#import "Activity.h"
#import "Enum.h"
#import "GUIDProvider.h"


@interface PunchClock ()

@property (nonatomic) PunchRepository *punchRepository;
@property (nonatomic) PunchAssemblyWorkflow *punchAssemblyWorkflow;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) GUIDProvider *guidProvider;
@end


@implementation PunchClock

- (instancetype)initWithPunchRepository:(PunchRepository *)punchRepository
                  punchAssemblyWorkflow:(PunchAssemblyWorkflow *)punchAssemblyWorkflow
                            userSession:(id <UserSession>)userSession
                           dateProvider:(DateProvider *)dateProvider
                           guidProvider:(GUIDProvider *)guidProvider {
    self = [super init];
    if (self)
    {
        self.punchRepository = punchRepository;
        self.punchAssemblyWorkflow = punchAssemblyWorkflow;
        self.dateProvider = dateProvider;
        self.userSession = userSession;
        self.guidProvider = guidProvider;
    }
    return self;
}

- (void)punchInWithPunchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate oefData:(NSArray*)oefData
{
    [self buildAndPersistPunchWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate
                                                punchActionType:PunchActionTypePunchIn
                                                        oefData:oefData];

}

- (void)punchOutWithPunchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate oefData:(NSArray*)oefData
{
    [self buildAndPersistPunchWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate
                                                punchActionType:PunchActionTypePunchOut
                                                        oefData:oefData];
}

- (void)takeBreakWithBreakDate:(NSDate *)breakDate
                     breakType:(BreakType *)breakType
 punchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate
{
    [self buildAndPersistPunchWithActionType:PunchActionTypeStartBreak punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate breakType:breakType clientType:nil projectType:nil taskType:nil activity:nil userURI:self.userSession.currentUserURI manual:NO date:breakDate oefTypesArray:nil lastSyncTime:nil];
}

- (void)takeBreakWithBreakDateAndOEF:(NSDate *)breakDate
                           breakType:(BreakType *)breakType
                             oefData:(NSArray*)oefData
       punchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate
{
    [self buildAndPersistPunchWithActionType:PunchActionTypeStartBreak punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate breakType:breakType clientType:nil projectType:nil taskType:nil activity:nil userURI:self.userSession.currentUserURI manual:NO date:breakDate oefTypesArray:oefData lastSyncTime:nil];
}

- (void)punchInWithPunchAssemblyWorkflowDelegate:(id <PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate
                                      clientType:(ClientType *)client
                                     projectType:(ProjectType *)project
                                        taskType:(TaskType *)task
                                        activity:(Activity *)activity
                                   oefTypesArray:(NSArray *)oefTypesArray {
    NSDate *date = [self.dateProvider date];
    [self buildAndPersistPunchWithActionType:PunchActionTypePunchIn punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate breakType:nil clientType:client projectType:project taskType:task activity:activity userURI:self.userSession.currentUserURI manual:NO date:date oefTypesArray:oefTypesArray lastSyncTime:nil];
}


- (void)resumeWorkWithPunchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate oefData:(NSArray*)oefData
{
    [self buildAndPersistPunchWithPunchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate
                                                punchActionType:PunchActionTypeTransfer
                                                        oefData:oefData];
}


- (void)resumeWorkWithPunchProjectAssemblyWorkflowDelegate:(id <PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate
                                                clientType:(ClientType *)client
                                               projectType:(ProjectType *)project
                                                  taskType:(TaskType *)task
                                             oefTypesArray:(NSArray *)oefTypesArray {
    NSDate *date = [self.dateProvider date];
    [self buildAndPersistPunchWithActionType:PunchActionTypeTransfer punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate breakType:nil clientType:client projectType:project taskType:task activity:nil userURI:self.userSession.currentUserURI manual:NO date:date oefTypesArray:oefTypesArray lastSyncTime:nil];
}

- (KSPromise *)punchWithManualLocalPunch:(LocalPunch *)punch punchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>) punchAssemblyWorkflowDelegate
{
    return [self buildAndPersistPunchWithActionType:punch.actionType punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate breakType:punch.breakType clientType:punch.client projectType:punch.project taskType:punch.task activity:punch.activity userURI:punch.userURI manual:YES date:punch.date oefTypesArray:punch.oefTypesArray lastSyncTime:punch.lastSyncTime];
}

- (void)resumeWorkWithActivityAssemblyWorkflowDelegate:(id <PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate
                                              activity:(Activity *)activity
                                         oefTypesArray:(NSArray *)oefTypesArray {

    NSDate *date = [self.dateProvider date];
    [self buildAndPersistPunchWithActionType:PunchActionTypeTransfer punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate breakType:nil clientType:nil projectType:nil taskType:nil activity:activity userURI:self.userSession.currentUserURI manual:NO date:date oefTypesArray:oefTypesArray lastSyncTime:nil];
    
}

#pragma mark - Private

- (KSPromise *)buildAndPersistPunchWithActionType:(PunchActionType)actionType punchAssemblyWorkflowDelegate:(id <PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate breakType:(BreakType *)breakType clientType:(ClientType *)client projectType:(ProjectType *)project taskType:(TaskType *)task activity:(Activity *)activity userURI:(NSString *)userURI manual:(BOOL)manual date:(NSDate *)date oefTypesArray:(NSArray *)oefTypesArray lastSyncTime:(NSDate *)lastSyncTime{

    KSDeferred *punchCompletedDeferred = [[KSDeferred alloc]init];
    id <Punch> incompletePunch;
    KSDeferred *serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
    KSPromise *punchPromise;
    
    if (manual)
    {
        incompletePunch = [[ManualPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:lastSyncTime breakType:breakType location:nil project:project requestID:[self.guidProvider guid] activity:activity client:client oefTypes:oefTypesArray address:nil userURI:userURI image:nil task:task date:date];
        
        
        punchPromise = [self.punchAssemblyWorkflow assembleManualIncompletePunch:incompletePunch
                                                     serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                                        delegate:punchAssemblyWorkflowDelegate];
    }
    else
    {
        incompletePunch = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:actionType lastSyncTime:lastSyncTime breakType:breakType location:nil project:project requestID:[self.guidProvider guid] activity:activity client:client oefTypes:oefTypesArray address:nil userURI:userURI image:nil task:task date:date];
        
        punchPromise = [self.punchAssemblyWorkflow assembleIncompletePunch:incompletePunch
                                               serverDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                                  delegate:punchAssemblyWorkflowDelegate];
    }

    [punchPromise then:^id(LocalPunch *punch) {
        KSPromise *serverDidFinishPunchPromise = [self.punchRepository persistPunch:punch];
        [serverDidFinishPunchPromise then:^id(id value) {
            [serverDidFinishPunchDeferred resolveWithValue:punch];
            [punchCompletedDeferred resolveWithValue:punch];
            return nil;
        } error:^id(NSError *error) {
            [punchCompletedDeferred rejectWithError:error];
            NSString *userURI_ = IsNotEmptyString(incompletePunch.userURI) ? incompletePunch.userURI : self.userSession.currentUserURI;
            [self.punchRepository fetchMostRecentPunchFromServerForUserUri:userURI_];
            return nil;
        }];
        return nil;
    } error:nil];

    return punchCompletedDeferred.promise;
}

- (void)buildAndPersistPunchWithPunchAssemblyWorkflowDelegate:(id<PunchAssemblyWorkflowDelegate>)punchAssemblyWorkflowDelegate
                                              punchActionType:(PunchActionType)punchActionType
                                                      oefData:(NSArray*)oefData
{
    NSDate *date = [self.dateProvider date];
    [self buildAndPersistPunchWithActionType:punchActionType punchAssemblyWorkflowDelegate:punchAssemblyWorkflowDelegate breakType:nil clientType:nil projectType:nil taskType:nil activity:nil userURI:self.userSession.currentUserURI manual:NO date:date oefTypesArray:oefData lastSyncTime:nil];
}


@end
