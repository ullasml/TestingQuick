#import "Punch.h"
#import "Enum.h"


@class CLLocation;
@class BreakType;
@class Activity;
@class ProjectType;
@class ClientType;
@class TaskType;
@class Activity;
@class PunchActionTypes;


@interface RemotePunch : NSObject <Punch>


@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSDate *lastSyncTime;
@property (nonatomic, readonly) PunchActionType actionType;
@property (nonatomic, readonly) SourceOfPunch sourceOfPunch;
@property (nonatomic, readonly) PunchSyncStatus punchSyncStatus;
@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) BreakType *breakType;
@property (nonatomic, readonly) Activity *activity;
@property (nonatomic, readonly) ProjectType *project;
@property (nonatomic, readonly) ClientType *client;
@property (nonatomic, readonly) TaskType *task;
@property (nonatomic, copy, readonly) NSString *address;
@property (nonatomic, copy, readonly) NSString *uri;
@property (nonatomic, copy, readonly) NSString *userURI;
@property (nonatomic, copy, readonly) NSArray *oefTypesArray;
@property (nonatomic, assign, readonly) BOOL syncedWithServer;
@property (nonatomic, assign, readonly) BOOL isTimeEntryAvailable;
@property (nonatomic, copy, readonly) NSArray *violations;
@property (nonatomic, copy, readonly) NSDateComponents *duration;
@property (nonatomic, copy, readonly) NSArray *auditHistoryInfoArray;
@property (nonatomic, assign, readonly) NSInteger nonActionedValidationsCount;
@property (nonatomic, readonly) PunchPairStatus nextPunchPairStatus;
@property (nonatomic, readonly) PunchPairStatus previousPunchPairStatus;
@property (nonatomic, readonly) PunchActionType previousPunchActionType;
@property (nonatomic, assign, readonly) BOOL isMissingPunch;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchSyncStatus:(PunchSyncStatus)punchSyncStatus
                 nonActionedValidations:(NSInteger)nonActionedValidations
                    previousPunchStatus:(PunchPairStatus)previousPunchStatus
                        nextPunchStatus:(PunchPairStatus)nextPunchStatus
                          sourceOfPunch:(SourceOfPunch)sourceOfPunch
                             actionType:(PunchActionType)actionType
                          oefTypesArray:(NSArray *)oefTypesArray
                           lastSyncTime:(NSDate *)lastSyncTime
                                project:(ProjectType *)project
                            auditHstory:(NSArray *)auditHstory
                              breakType:(BreakType *)breakType
                               location:(CLLocation *)location
                             violations:(NSArray *)violations
                              requestID:(NSString *)requestID
                               activity:(Activity *)activity
                               duration:(NSDateComponents *)duration
                                 client:(ClientType *)client
                                address:(NSString *)address
                                userURI:(NSString *)userURI
                               imageURL:(NSURL *)imageURL
                                   date:(NSDate *)date
                                   task:(TaskType *)task
                                    uri:(NSString *)uri
                   isTimeEntryAvailable:(BOOL)isTimeEntryAvailable
                       syncedWithServer:(BOOL)syncedWithServer
                         isMissingPunch:(BOOL)isMissingPunch
                previousPunchActionType:(PunchActionType)previousPunchActionType NS_DESIGNATED_INITIALIZER;


@end
