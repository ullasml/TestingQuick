#import "PunchesForDateFetcher.h"
#import "PunchOutboxQueueCoordinator.h"
#import "UserSession.h"

@class PunchOutboxQueueCoordinator;
@class RemotePunchListDeserializer;
@class RemotePunchDeserializer;
@class PunchRequestProvider;
@class RemotePunch;
@class LocalPunch;
@class KSPromise;
@class TimeLinePunchesStorage;
@class DateProvider;

@protocol PunchRepositoryObserver;
@protocol RequestPromiseClient;
@protocol Punch;
@class PunchCardStorage;
@class GUIDProvider;
@class PunchOutboxStorage;
@class FailedPunchStorage;
@class PunchNotificationScheduler;
@class ViolationsStorage;
@class AuditHistoryStorage;


@interface PunchRepository : NSObject <PunchesForDateFetcher, PunchOutboxQueueCoordinatorDelegate>

@property (nonatomic, readonly) PunchOutboxQueueCoordinator *punchOutboxQueueCoordinator;
@property (nonatomic, readonly) RemotePunchListDeserializer *punchListDeserializer;
@property (nonatomic, readonly) PunchRequestProvider *punchRequestProvider;
@property (nonatomic, readonly) RemotePunchDeserializer *punchDeserializer;
@property (nonatomic, readonly) PunchCardStorage *punchCardStorage;
@property (nonatomic, readonly) FailedPunchStorage *failedPunchStorage;
@property (nonatomic, readonly) PunchOutboxStorage *punchOutboxStorage;
@property (nonatomic, readonly) id<RequestPromiseClient> client;
@property (nonatomic, readonly) GUIDProvider *guidProvider;
@property (nonatomic, readonly) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) TimeLinePunchesStorage *timeLinePunchesStorage;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) ViolationsStorage *violationsStorage;
@property (nonatomic, readonly) AuditHistoryStorage *auditHistoryStorage;
@property (nonatomic, readonly) NSUserDefaults *defaults;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;


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
                                      dateFormatter:(NSDateFormatter *)dateFormatter;

- (void)addObserver:(id<PunchRepositoryObserver>)observer;

- (KSPromise *)persistPunch:(LocalPunch *)punch;

- (KSPromise *)fetchMostRecentPunchForUserUri:(NSString *)userUri;

- (KSPromise *)fetchMostRecentPunchFromServerForUserUri:(NSString *)userUri;

- (KSPromise *)deletePunchWithPunchAndFetchMostRecentPunch:(RemotePunch*)punch;

- (KSPromise *)updatePunch:(NSArray *)remotePunchesArray;

- (KSPromise *)recalculateScriptDataForuserUri:(NSString *)userURI withDateDict:(NSDictionary *)dateDict;

@end


@protocol PunchRepositoryObserver <NSObject>

- (void)punchRepositoryDidDiscoverFirstTimeUse:(PunchRepository *)punchRepository;

- (void)punchRepository:(PunchRepository *)punchRepository didUpdateMostRecentPunch:(id<Punch>)mostRecentPunch;

- (void)punchRepositoryDidSyncPunches:(PunchRepository *)punchRepository;

- (void)punchRepository:(PunchRepository *)punchRepository handleInvalidCPTWithPunch:(id<Punch>)punch;

@end
