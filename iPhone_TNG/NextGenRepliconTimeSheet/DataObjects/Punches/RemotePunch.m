#import "RemotePunch.h"
#import "BreakType.h"
#import <CoreLocation/CoreLocation.h>
#import "Activity.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "Enum.h"


@interface RemotePunch ()

@property (nonatomic) NSDate *date;
@property (nonatomic) NSDate *lastSyncTime;
@property (nonatomic, assign) PunchActionType actionType;
@property (nonatomic, assign) PunchSyncStatus punchSyncStatus;
@property (nonatomic, assign) PunchPairStatus nextPunchPairStatus;
@property (nonatomic, assign) PunchPairStatus previousPunchPairStatus;
@property (nonatomic, assign) PunchActionType previousPunchActionType;
@property (nonatomic, assign) SourceOfPunch sourceOfPunch;
@property (nonatomic) CLLocation *location;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) BreakType *breakType;
@property (nonatomic) Activity *activity;
@property (nonatomic) ProjectType *project;
@property (nonatomic) ClientType *client;
@property (nonatomic) TaskType *task;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic, copy) NSArray *oefTypesArray;
@property (nonatomic, copy) NSString *requestID;
@property (nonatomic, assign) BOOL syncedWithServer;
@property (nonatomic, assign) BOOL isTimeEntryAvailable;
@property (nonatomic, copy) NSArray *violations;
@property (nonatomic, copy) NSArray *auditHistoryInfoArray;
@property (nonatomic, assign) NSInteger nonActionedValidationsCount;
@property (nonatomic, copy) NSDateComponents *duration;
@property (nonatomic, assign) BOOL isMissingPunch;

@end


@implementation RemotePunch

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
                previousPunchActionType:(PunchActionType)previousPunchActionType 
{
    self = [super init];
    if (self) {
        self.date = date;
        self.lastSyncTime = lastSyncTime;
        self.activity = activity;
        self.project = project;
        self.client = client;
        self.task = task;
        self.actionType = actionType;
        self.punchSyncStatus = punchSyncStatus;
        self.location = location;
        self.address = address;
        self.imageURL = imageURL;
        self.breakType = breakType;
        self.uri = uri;
        self.userURI = userURI;
        self.oefTypesArray = oefTypesArray;
        self.requestID = requestID;
        self.syncedWithServer = syncedWithServer;
        self.isTimeEntryAvailable = isTimeEntryAvailable;
        self.nonActionedValidationsCount =  nonActionedValidations;
        self.violations = violations;
        self.auditHistoryInfoArray =  auditHstory;
        self.sourceOfPunch = sourceOfPunch;
        self.duration = duration;
        self.previousPunchPairStatus =  previousPunchStatus;
        self.nextPunchPairStatus =  nextPunchStatus;
        self.isMissingPunch =  isMissingPunch;
        self.previousPunchActionType = previousPunchActionType;
    }

    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)isEqual:(RemotePunch *)otherPunch
{
    if(![otherPunch isKindOfClass:[self class]]) {
        return NO;
    }
    BOOL datesEqual = (!otherPunch.date && !self.date) || [otherPunch.date compare:self.date] == NSOrderedSame;
    BOOL actionsEqual = (otherPunch.actionType == self.actionType);
    BOOL addressesEqual = (!otherPunch.address && !self.address) || ([self.address isEqualToString:otherPunch.address]);
    BOOL breakTypeEqual = (!otherPunch.breakType && !self.breakType) || ([self.breakType isEqual:otherPunch.breakType]);
    BOOL activityEqual = (!otherPunch.activity && !self.activity) || ([self.activity isEqual:otherPunch.activity]);
    BOOL projectEqual = (!otherPunch.project && !self.project) || ([self.project isEqual:otherPunch.project]);
    BOOL clientEqual = (!otherPunch.client && !self.client) || ([self.client isEqual:otherPunch.client]);
    BOOL taskEqual = (!otherPunch.task && !self.task) || ([self.task isEqual:otherPunch.task]);
    BOOL uriEqual = (!otherPunch.uri && !self.uri) || ([self.uri isEqual:otherPunch.uri]);
    BOOL userURIEqual = (!otherPunch.userURI && !self.userURI) || ([self.userURI isEqual:otherPunch.userURI]);
    self.oefTypesArray = self.oefTypesArray == nil ? @[]:self.oefTypesArray;
    otherPunch.oefTypesArray = otherPunch.oefTypesArray == nil ? @[]:otherPunch.oefTypesArray;
    BOOL oefTypesEqual = (!otherPunch.oefTypesArray && !self.oefTypesArray) || ([self.oefTypesArray isEqual:otherPunch.oefTypesArray]);
    BOOL punchSyncStatusEqual = (otherPunch.punchSyncStatus == self.punchSyncStatus);
    BOOL lastSyncTimeEqual = (!otherPunch.lastSyncTime && !self.lastSyncTime) || ((otherPunch.lastSyncTime && self.lastSyncTime) && [otherPunch.lastSyncTime compare:self.lastSyncTime] == NSOrderedSame);
    BOOL nextPunchPairStatusEqual = (!otherPunch.nextPunchPairStatus && !self.nextPunchPairStatus) || (otherPunch.nextPunchPairStatus == self.nextPunchPairStatus);
    BOOL previousPunchPairStatusEqual = (!otherPunch.previousPunchPairStatus && !self.previousPunchPairStatus) || (otherPunch.previousPunchPairStatus == self.previousPunchPairStatus);
    BOOL durationEqual = (!otherPunch.duration && !self.duration) || [self isSameDurationComponents:otherPunch.duration other:self.duration];
    BOOL nonActionedValidationsCountEqual = (!otherPunch.nonActionedValidationsCount && !self.nonActionedValidationsCount) || (otherPunch.nonActionedValidationsCount == self.nonActionedValidationsCount);
    
    return datesEqual &&
    actionsEqual &&
    addressesEqual &&
    breakTypeEqual &&
    uriEqual &&
    userURIEqual &&
    activityEqual &&
    projectEqual &&
    clientEqual &&
    taskEqual &&
    oefTypesEqual &&
    punchSyncStatusEqual &&
    lastSyncTimeEqual&&
    nextPunchPairStatusEqual&&
    previousPunchPairStatusEqual &&
    durationEqual &&
    nonActionedValidationsCountEqual;
}

- (NSString *)description
{
    NSDictionary *actionMapping =
    @{@(PunchActionTypePunchIn): @"Punch In",
      @(PunchActionTypePunchOut): @"Punch Out",
      @(PunchActionTypeStartBreak): @"Start Break",
      @(PunchActionTypeTransfer): @"Transfer",
      @(PunchActionTypeUnknown): @"Unknown",
      };
    return [NSString stringWithFormat:@"<%@>:\r action: %@ \r breakType: %@ \r date: %@ \r location: %@ \r address: %@ \r ImageURL: %@ \r uri: %@ \r userURI: %@ \r activity: %@ project:%@  client:%@ task:%@ oefTypesArray:%@ \r punchSyncStatus: %@ \r lastSyncTime: %@ \r requestID: %@ \r syncWithServer: %d \r isTimeEntryAvailable:%d \r sourceOfPunch:%lu \r violations:%@ \r auditHstory:%@ \r nonActionedValidationsCount:%ld \r duration:%@ \r isMissingPunch: %d \r previousPunchActionType: %@",
            NSStringFromClass([self class]),
            actionMapping[@(self.actionType)],
            self.breakType,
            self.date,
            self.location,
            self.address,
            self.imageURL,
            self.uri,
            self.userURI,
            self.activity,
            self.project,
            self.client,
            self.task,
            self.oefTypesArray,
            @(self.punchSyncStatus),
            self.lastSyncTime,
            self.requestID,
            self.syncedWithServer,
            self.isTimeEntryAvailable,
            (unsigned long)self.sourceOfPunch,
            self.violations,
            self.auditHistoryInfoArray,
            self.nonActionedValidationsCount,
            self.duration,
            self.isMissingPunch,
            actionMapping[@(self.previousPunchActionType)]];
}

#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{
    NSDate *date = [decoder decodeObjectForKey:@"date"];
    PunchActionType action = [[decoder decodeObjectForKey:@"actionType"] unsignedIntegerValue];
    CLLocation *location = [decoder decodeObjectForKey:@"location"];
    NSString *address = [decoder decodeObjectForKey:@"address"];
    BreakType *breakType = [decoder decodeObjectForKey:@"breakType"];
    Activity *activity = [decoder decodeObjectForKey:@"activity"];
    ProjectType *project = [decoder decodeObjectForKey:@"project"];
    ClientType *client = [decoder decodeObjectForKey:@"client"];
    TaskType *task = [decoder decodeObjectForKey:@"task"];
    NSURL *imageURL = [decoder decodeObjectForKey:@"imageURL"];
    NSString *uri = [decoder decodeObjectForKey:@"uri"];
    NSString *userURI = [decoder decodeObjectForKey:@"userURI"];
    NSMutableArray *oefTypesArray = [decoder decodeObjectForKey:@"oefTypesArray"];
    PunchSyncStatus punchSyncStatus = [[decoder decodeObjectForKey:@"punchSyncStatus"] unsignedIntegerValue];
    PunchPairStatus nextPunchPairStatus = [[decoder decodeObjectForKey:@"nextPunchPairStatus"] unsignedIntegerValue];
    PunchPairStatus previousPunchPairStatus = [[decoder decodeObjectForKey:@"previousPunchPairStatus"] unsignedIntegerValue];
    PunchActionType previousPunchActionType = [[decoder decodeObjectForKey:@"previousPunchActionType"] unsignedIntegerValue];
    SourceOfPunch sourceOfPunch = [[decoder decodeObjectForKey:@"sourceOfPunch"] unsignedIntegerValue];

    NSDateComponents *duration = [decoder decodeObjectForKey:@"duration"];

    NSDate *lastSyncTime = [decoder decodeObjectForKey:@"lastSyncTime"];
    NSString *requestID = [decoder decodeObjectForKey:@"requestID"];
    BOOL syncWithServer = [[decoder decodeObjectForKey:@"sync_with_server"]boolValue];
    BOOL isTimeEntryAvailable = [[decoder decodeObjectForKey:@"is_time_entry_available"] boolValue];
    NSMutableArray *violations = [decoder decodeObjectForKey:@"violations"];
    NSMutableArray *auditHstory = [decoder decodeObjectForKey:@"auditHstory"];
    NSInteger nonActionedValidations = [[decoder decodeObjectForKey:@"nonActionedValidationsCount"]unsignedIntegerValue];
    BOOL isMissingPunch = [[decoder decodeObjectForKey:@"isMissingPunch"]boolValue];


    return [self initWithPunchSyncStatus:punchSyncStatus
                  nonActionedValidations:nonActionedValidations
                     previousPunchStatus:previousPunchPairStatus
                         nextPunchStatus:nextPunchPairStatus
                           sourceOfPunch:sourceOfPunch
                              actionType:action
                           oefTypesArray:oefTypesArray
                            lastSyncTime:lastSyncTime
                                 project:project
                             auditHstory:auditHstory
                               breakType:breakType
                                location:location
                              violations:violations
                               requestID:requestID
                                activity:activity
                                duration:duration
                                  client:client
                                 address:address
                                 userURI:userURI
                                imageURL:imageURL
                                    date:date
                                    task:task
                                     uri:uri
                    isTimeEntryAvailable:isTimeEntryAvailable
                        syncedWithServer:syncWithServer
                          isMissingPunch:isMissingPunch
                 previousPunchActionType:previousPunchActionType ];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.duration forKey:@"duration"];
    [coder encodeObject:@(self.actionType) forKey:@"actionType"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.breakType forKey:@"breakType"];
    [coder encodeObject:self.activity forKey:@"activity"];
    [coder encodeObject:self.project forKey:@"project"];
    [coder encodeObject:self.client forKey:@"client"];
    [coder encodeObject:self.task forKey:@"task"];
    [coder encodeObject:self.imageURL forKey:@"imageURL"];
    [coder encodeObject:self.uri forKey:@"uri"];
    [coder encodeObject:self.userURI forKey:@"userURI"];
    [coder encodeObject:self.oefTypesArray forKey:@"oefTypesArray"];
    [coder encodeObject:@(self.punchSyncStatus) forKey:@"punchSyncStatus"];
    [coder encodeObject:@(self.nextPunchPairStatus) forKey:@"nextPunchPairStatus"];
    [coder encodeObject:@(self.previousPunchPairStatus) forKey:@"previousPunchPairStatus"];
    [coder encodeObject:@(self.previousPunchActionType) forKey:@"previousPunchActionType"];
    [coder encodeObject:self.lastSyncTime forKey:@"lastSyncTime"];
    [coder encodeObject:self.requestID forKey:@"requestID"];
    [coder encodeObject:[NSNumber numberWithBool:self.syncedWithServer] forKey:@"sync_with_server"];
    [coder encodeObject:[NSNumber numberWithBool:self.isTimeEntryAvailable] forKey:@"is_time_entry_available"];
    [coder encodeObject:@(self.sourceOfPunch) forKey:@"sourceOfPunch"];
    [coder encodeObject:self.violations forKey:@"violations"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.nonActionedValidationsCount] forKey:@"nonActionedValidationsCount"];
    [coder encodeObject:self.auditHistoryInfoArray forKey:@"auditHstory"];
    [coder encodeObject:[NSNumber numberWithBool:self.isMissingPunch] forKey:@"isMissingPunch"];
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return [[RemotePunch alloc] initWithPunchSyncStatus:self.punchSyncStatus
                                 nonActionedValidations:self.nonActionedValidationsCount
                                    previousPunchStatus:self.previousPunchPairStatus
                                        nextPunchStatus:self.nextPunchPairStatus
                                          sourceOfPunch:self.sourceOfPunch
                                             actionType:self.actionType
                                          oefTypesArray:[self.oefTypesArray copy]
                                           lastSyncTime:self.lastSyncTime
                                                project:self.project
                                            auditHstory:[self.auditHistoryInfoArray copy]
                                              breakType:self.breakType
                                               location:[self.location copy]
                                             violations:[self.violations copy]
                                              requestID:self.requestID
                                               activity:self.activity
                                               duration:[self.duration copy]
                                                 client:self.client
                                                address:[self.address copy]
                                                userURI:[self.userURI copy]
                                               imageURL:[self.imageURL copy]
                                                   date:[self.date copy]
                                                   task:self.task
                                                    uri:[self.uri copy]
                                   isTimeEntryAvailable:self.isTimeEntryAvailable
                                       syncedWithServer:self.syncedWithServer
                                         isMissingPunch:self.isMissingPunch
                                previousPunchActionType:self.previousPunchActionType];

}

#pragma mark - Private
-(BOOL)isSameDurationComponents:(NSDateComponents*)dateComponents other:(NSDateComponents*)otherDateComponents
{
    if (dateComponents.hour == otherDateComponents.hour && dateComponents.minute == otherDateComponents.minute && dateComponents.second == otherDateComponents.second) {
        return YES;
    }
    return NO;
}


@end
