#import "PunchRepository.h"
#import "JSONClient.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestBuilder.h"
#import "Util.h"
#import "GUIDProvider.h"
#import "LocalPunch.h"
#import "RemotePunchDeserializer.h"
#import "Constants.h"
#import "PunchRequestProvider.h"
#import "RequestPromiseClient.h"
#import "RemotePunchListDeserializer.h"
#import "RemotePunch.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "TimeLinePunchesStorage.h"
#import "PunchCardStorage.h"
#import "PunchCardObject.h"
#import "Guid.h"
#import "PunchOutboxStorage.h"
#import "FailedPunchStorage.h"
#import "PunchNotificationScheduler.h"
#import <Blindside/BSInjector.h>
#import "DateProvider.h"
#import "TimeLinePunchesSummary.h"
#import "DayTimeSummary.h"
#import "ViolationsStorage.h"
#import "AuditHistoryStorage.h"

@interface PunchRepository ()

@property (nonatomic) PunchOutboxQueueCoordinator *punchOutboxQueueCoordinator;
@property (nonatomic) RemotePunchListDeserializer *punchListDeserializer;
@property (nonatomic) PunchRequestProvider *punchRequestProvider;
@property (nonatomic) RemotePunchDeserializer *punchDeserializer;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) id<RequestPromiseClient> client;
@property (nonatomic) TimeLinePunchesStorage *timeLinePunchesStorage;
@property (nonatomic) NSHashTable *observers;
@property (nonatomic) PunchCardStorage *punchCardStorage;
@property (nonatomic) GUIDProvider *guidProvider;
@property (nonatomic) PunchOutboxStorage *punchOutboxStorage;
@property (nonatomic) FailedPunchStorage *failedPunchStorage;
@property (nonatomic) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) id<BSInjector> injector;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) ViolationsStorage *violationsStorage;
@property (nonatomic) AuditHistoryStorage *auditHistoryStorage;
@property (nonatomic) NSUserDefaults *defaults;

@end


@implementation PunchRepository

- (instancetype)initWithPunchOutboxQueueCoordinator:(PunchOutboxQueueCoordinator *)punchOutboxQueueCoordinator
                         punchNotificationScheduler:(PunchNotificationScheduler *)punchNotificationScheduler
                              punchListDeserializer:(RemotePunchListDeserializer *)punchListDeserializer
                             timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
                               punchRequestProvider:(PunchRequestProvider *)punchRequestProvider
                                auditHistoryStorage:(AuditHistoryStorage *)auditHistoryStorage
                                  punchDeserializer:(RemotePunchDeserializer *)punchDeserializer
                                 punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage
                                 failedPunchStorage:(FailedPunchStorage *)failedPunchStorage
                                  violationsStorage:(ViolationsStorage *)violationsStorage
                                   punchCardStorage:(PunchCardStorage *)punchCardStorage
                                             client:(id <RequestPromiseClient>)client
                                       guidProvider:(GUIDProvider *)guidProvider
                                        userSession:(id <UserSession>)userSession
                                           defaults:(NSUserDefaults *)defaults
                                       dateProvider:(DateProvider *)dateProvider
                                      dateFormatter:(NSDateFormatter *)dateFormatter {
    self = [super init];
    if (self)
    {
        self.punchOutboxQueueCoordinator = punchOutboxQueueCoordinator;
        self.punchNotificationScheduler = punchNotificationScheduler;
        self.timeLinePunchesStorage = timeLinePunchesStorage;
        self.punchListDeserializer = punchListDeserializer;
        self.punchRequestProvider = punchRequestProvider;
        self.auditHistoryStorage = auditHistoryStorage;
        self.failedPunchStorage = failedPunchStorage;
        self.violationsStorage = violationsStorage;
        self.punchOutboxStorage = punchOutboxStorage;
        self.punchDeserializer = punchDeserializer;
        self.punchCardStorage = punchCardStorage;
        self.guidProvider = guidProvider;
        self.client = client;
        self.dateProvider = dateProvider;
        self.punchOutboxQueueCoordinator.delegate = self;
        self.observers = [NSHashTable weakObjectsHashTable];
        self.userSession = userSession;
        self.dateFormatter = dateFormatter;
        self.defaults = defaults;
    }
    return self;
}

- (void)addObserver:(id<PunchRepositoryObserver>)observer
{
    [self.observers addObject:observer];
}

- (KSPromise *)persistPunch:(LocalPunch *)punch
{
    [self serailizeAndStorePunchCardFromPunch:punch];
    [self.punchOutboxStorage storeLocalPunch:punch];
    return [self.punchOutboxQueueCoordinator sendPunch:punch];
}

- (KSPromise *)fetchMostRecentPunchForUserUri:(NSString *)userUri
{
    id<Punch> mostRecentPunch = [self.timeLinePunchesStorage mostRecentPunchForUserUri:userUri];
    if (mostRecentPunch)
    {
        [self notifyObserversWithPunch:mostRecentPunch];
    }
    
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:userUri];
    FlowType flowType = isSameUser ? UserFlowContext : SupervisorFlowContext;
    if(flowType==SupervisorFlowContext)
    {
         return [self punchesForDate:[self.dateProvider date] userURI:userUri];
    }
    else
    {
         return [self punchesForDateAndMostRecentLastTwoPunch:[self.dateProvider date]];
    }
}


- (KSPromise *)fetchMostRecentPunchFromServerForUserUri:(NSString *)userUri
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:userUri];
    FlowType flowType = isSameUser ? UserFlowContext : SupervisorFlowContext;
    if(flowType==SupervisorFlowContext)
    {
        return [self punchesForDate:[self.dateProvider date] userURI:userUri];
    }
    else
    {
        return [self punchesForDateAndMostRecentLastTwoPunch:[self.dateProvider date]];
    }

}

- (KSPromise *)deletePunchWithPunchAndFetchMostRecentPunch:(RemotePunch*)punch
{

    [self.timeLinePunchesStorage deleteOldRemotePunch:punch];

    NSURLRequest *request = [self.punchRequestProvider deletePunchRequestWithPunchUri:punch.uri];
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];
    return [jsonPromise then:^id(id value) {
        return [self fetchMostRecentPunchForUserUri:punch.userURI];
    } error:nil];
}


- (KSPromise *)updatePunch:(NSArray *)remotePunchesArray {

    for (RemotePunch *punch in remotePunchesArray)
    {
        [self.timeLinePunchesStorage deleteOldRemotePunch:punch];
        [self.timeLinePunchesStorage storeRemotePunch:punch];
        [self.punchOutboxStorage updateSyncStatusToPendingAndSave:punch];
    }

    
    KSDeferred *deferred = [[KSDeferred alloc] init];
    
    NSURLRequest *updatePunchRequest = [self.punchRequestProvider requestToUpdatePunch:remotePunchesArray];
    KSPromise *jsonPromise = [self.client promiseWithRequest:updatePunchRequest];
    
    return [jsonPromise then:^id(NSDictionary *jsonResponseDictionary) {

        NSArray *errors;
        NSString *userUri = self.userSession.currentUserURI;

        if([jsonResponseDictionary[@"d"] respondsToSelector:@selector(objectForKey:)])
        {
            errors =  jsonResponseDictionary[@"d"][@"erroredPunches"];
        }

        if (errors)
        {
            NSMutableArray *mutablePunches = [remotePunchesArray mutableCopy];
            for (NSDictionary *errorDictionary in errors)
            {
                NSString *errorDisplayText = errorDictionary[@"displayText"];
                [self.punchNotificationScheduler scheduleCurrentFireDateNotificationWithAlertBody:errorDisplayText];
                for (id<Punch>punch in remotePunchesArray)
                {
                    if ([errorDictionary[@"parameterCorrelationId"] isEqualToString:punch.requestID])
                    {
                        [self.punchOutboxStorage deletePunch:punch];
                        [mutablePunches removeObject:punch];
                        break;
                    }
                }

                for (id<Punch>punch in mutablePunches)
                {
                   [self.timeLinePunchesStorage updateSyncStatusToRemoteAndSaveWithPunch:punch withRemoteUri:nil];
                }
            }

            for (id<Punch>punch in remotePunchesArray)
            {
                userUri = punch.userURI;
            }

            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: jsonResponseDictionary[@"d"][@"errors"]};
            NSError *error = [NSError errorWithDomain:@"PunchCreatorErrorDomain" code:0 userInfo:userInfo];
            [deferred rejectWithError:error];

        }
        else
        {
            [deferred resolveWithValue:remotePunchesArray];
            for (id<Punch>punch in remotePunchesArray)
            {
                [self.timeLinePunchesStorage updateSyncStatusToRemoteAndSaveWithPunch:punch withRemoteUri:nil];
                userUri = punch.userURI;
            }
            
        }
        return [self fetchMostRecentPunchForUserUri:userUri];
    } error:^id(NSError *error) {
        NSString *alertBody = RPLocalizedString(PunchesWereNotSavedErrorNotificationMsg, @"");
        NSString *userUri = self.userSession.currentUserURI;
        [self.punchNotificationScheduler scheduleNotificationWithAlertBody:alertBody];
        [deferred rejectWithError:error];
        for (RemotePunch *punch in remotePunchesArray)
        {
             [self.failedPunchStorage updateStatusOfRemotePunchToUnsubmitted:punch];
            userUri = punch.userURI;
        }

        [self fetchMostRecentPunchForUserUri:userUri];
        return error;
    }];

}

- (KSPromise *) recalculateScriptDataForuserUri:(NSString *)userURI withDateDict:(NSDictionary *)dateDict
{
    NSURLRequest *request = [self.punchRequestProvider requestToRecalculateScriptDataForuser:userURI withDateDict:dateDict];
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];
    return [jsonPromise then:^id(id value) {
        return value;
    } error:^id(NSError *error) {
        return error;
    }];
}


#pragma mark - <PunchesForDateFetcher>

- (KSPromise *)punchesForDate:(NSDate *)date userURI:(NSString *)userURI
{
    NSURLRequest *request = [self.punchRequestProvider requestForPunchesWithDate:date userURI:userURI];
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    KSPromise *todaysPunchesPromise = [jsonPromise then:^id(NSDictionary *jsonDictionary) {
        [self.auditHistoryStorage deleteAllRows];
        [self.violationsStorage deleteAllRows];
        return [self getUpdatedTimeLinePunchesSummaryForDictionary:jsonDictionary andDate:date userUri:userURI deleteOnlyDatePunches:YES];
    } error:^id(NSError *error)
                                       {
                                           NSArray *filteredPunches = [self.timeLinePunchesStorage allPunchesForDay:date userUri:userURI];
                                           TimeLinePunchesSummary *timeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:NULL
                                                                                                                                   timeLinePunches:filteredPunches
                                                                                                                                        allPunches:[self.timeLinePunchesStorage recentPunchesForUserUri:userURI]];
                                           
                                           return timeLinePunchesSummary;
                                       }];

    return todaysPunchesPromise;
}

- (KSPromise *)punchesForDateAndMostRecentLastTwoPunch:(NSDate *)date
{
    NSURLRequest *request = [self.punchRequestProvider requestForPunchesWithLastTwoMostRecentPunchWithDate:date];
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    KSPromise *todaysPunchesPromise = [jsonPromise then:^id(NSArray *jsonArray){
        [self.auditHistoryStorage deleteAllRows];
        [self.violationsStorage deleteAllRows];
        if ([jsonArray count]>0) {
            NSDictionary *violations = jsonArray[0][@"violations"];
            if (violations) {
                NSInteger totalViolationMessagesCount = [violations[@"totalViolationMessagesCount"] integerValue];
                [self.defaults setObject:[NSNumber numberWithInteger:totalViolationMessagesCount] forKey:@"totalViolationMessagesCount"];
            }
        }
        return [self getUpdatedTimeLinePunchesSummaryForDictionary:jsonArray andDate:date userUri:self.userSession.currentUserURI deleteOnlyDatePunches:NO];
    }  error:^id(NSError *error)
    {
        NSArray *filteredPunches = [self.timeLinePunchesStorage allPunchesForDay:date userUri:self.userSession.currentUserURI];
        TimeLinePunchesSummary *timeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:NULL
                                                                                                timeLinePunches:filteredPunches
                                                                                                     allPunches:[self.timeLinePunchesStorage recentPunchesForUserUri:self.userSession.currentUserURI]];

        return timeLinePunchesSummary;
    }];

    return todaysPunchesPromise;
}

-(void)storeAllPunches:(NSArray *)allPunches userUri:(NSString *)userUri
{
    [self.timeLinePunchesStorage deleteAllPreviousPunches:userUri];

    id<Punch> mostRecentPunch = [self.timeLinePunchesStorage mostRecentPunchForUserUri:userUri];
    if (mostRecentPunch)
    {
        if ([mostRecentPunch respondsToSelector:@selector(uri)])
        {
            [self.timeLinePunchesStorage storeRemotePunch:mostRecentPunch];
        }
        else
        {
            [self.punchOutboxStorage storeLocalPunch:mostRecentPunch];
        }

    }

    int count = 0;
    for (RemotePunch *punch in allPunches) {
        if (punch.actionType != PunchActionTypeUnknown )
        {
            if (count == allPunches.count-1)
            {
                if ([mostRecentPunch isEqual:punch])
                {
                    [self.timeLinePunchesStorage deleteOldRemotePunch:mostRecentPunch];
                }
            }

            [self.timeLinePunchesStorage storeRemotePunch:punch];
        }
        count++;
    }
}

-(void)storeAllPunches:(NSArray *)allPunches userUri:(NSString *)userUri forDate:(NSDate *)date
{
    [self.timeLinePunchesStorage deleteAllPunchesForDate:date];

    for (RemotePunch *punch in allPunches) {
        if (punch.actionType != PunchActionTypeUnknown )
        {
            [self.timeLinePunchesStorage storeRemotePunch:punch];

        }
    }
}

#pragma mark - <PunchOutboxQueueCoordinatorDelegate>

- (void)punchOutboxQueueCoordinatorDidSyncPunches:(PunchOutboxQueueCoordinator *)punchOutboxQueueCoordinator
{
    for (id<PunchRepositoryObserver> observer in self.observers)
    {
        [observer punchRepositoryDidSyncPunches:self];
    }

    id<Punch> mostRecentPunch = self.timeLinePunchesStorage.mostRecentPunch;
    if (mostRecentPunch)
    {
        [self notifyObserversWithPunch:mostRecentPunch];
    }
}

- (void)punchOutboxQueueCoordinatorDidThrowInvalidPunchError:(PunchOutboxQueueCoordinator *)punchOutboxQueueCoordinator withPunch:(id<Punch>)punch {

    [self updatePunchCard:punch];
}

#pragma mark - Private

- (void)notifyObserversWithPunch:(id<Punch>)punch
{
    for (id<PunchRepositoryObserver> observer in self.observers)
    {
         [observer punchRepository:self didUpdateMostRecentPunch:punch];
    }
}

#pragma mark - Private

-(void)serailizeAndStorePunchCardFromPunch:(id <Punch>)punch
{
    if (punch.actionType == PunchActionTypePunchIn || punch.actionType == PunchActionTypeTransfer) {
        NSString *uri = self.guidProvider.guid;
        PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                             initWithClientType:punch.client
                                                                    projectType:punch.project
                                                                  oefTypesArray:punch.oefTypesArray
                                                                      breakType:NULL
                                                                       taskType:punch.task
                                                                       activity:NULL
                                                                            uri:uri];
        
        NSString *userUri_ = punch.userURI;
        punchCardObject.userUri = (IsNotEmptyString(userUri_)) ? userUri_ : @"";
        [self.punchCardStorage storePunchCard:punchCardObject];
    }
}

-(TimeLinePunchesSummary *)getUpdatedTimeLinePunchesSummaryForDictionary:(id)jsonData andDate:(NSDate *)date userUri:(NSString *)useruri deleteOnlyDatePunches:(BOOL)deleteOnlyDate
{
    NSMutableArray *todaysPunches = [@[]mutableCopy];
    NSMutableArray *invalidCPTs = [@[]mutableCopy];
    NSArray *allPunches = nil;
    
    if ([jsonData isKindOfClass:[NSArray class]]) {
        allPunches = [self.punchListDeserializer deserializeWithArray:jsonData];
    }
    else{
        allPunches = [self.punchListDeserializer deserialize:jsonData];
    }
    
    [self.violationsStorage storePunchViolations:allPunches];
    
    NSString *presentDate = [self.dateFormatter stringFromDate:date];
    for (RemotePunch *punch in allPunches) {
        NSString *punchDate = [self.dateFormatter stringFromDate:punch.date];
        if ([punchDate isEqualToString:presentDate]) {
            [todaysPunches addObject:punch];
        }

        if(!punch.isTimeEntryAvailable) {
            [invalidCPTs addObject:punch];
        }
    }

    [self updateInvalidCPTFromPunchCardUserTable:invalidCPTs];

    NSMutableArray *filteredPunches = [[NSMutableArray alloc] init];
    for (RemotePunch *punch in todaysPunches) {
        if (punch.actionType != PunchActionTypeUnknown ) {
            [filteredPunches addObject:punch];
        }
    }


    if (deleteOnlyDate)
    {
        [self storeAllPunches:allPunches userUri:useruri forDate:date];
    }

    else
    {
        [self storeAllPunches:allPunches userUri:useruri];
    }



    TimeLinePunchesSummary *timeLinePunchesSummary = [[TimeLinePunchesSummary alloc] initWithDayTimeSummary:nil
                                                                                            timeLinePunches:filteredPunches
                                                                                                 allPunches:[self.timeLinePunchesStorage recentPunchesForUserUri:useruri]];

    return timeLinePunchesSummary;
}


#pragma mark - Helper Method

- (void)updateInvalidCPTFromPunchCardUserTable:(NSMutableArray *)invalidCPTs {

    for(RemotePunch *punch in invalidCPTs) {
        [self updatePunchCard:punch];
    }
}

- (void)updatePunchCard:(id<Punch>)punch {

    PunchCardObject *punchCardObject = [self.punchCardStorage getPunchCardObjectWithClientUri:punch.client.uri projectUri:punch.project.uri taskUri:punch.task.uri];

    if(!punchCardObject) {
        NSLog(@"no punch with specified combination");
        return;
    }
    
    punchCardObject.isValidPunchCard = punch.isTimeEntryAvailable;

    [self.punchCardStorage storePunchCard:punchCardObject];
}

@end
