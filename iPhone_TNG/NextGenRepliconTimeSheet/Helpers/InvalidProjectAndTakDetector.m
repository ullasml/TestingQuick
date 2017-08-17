#import "InvalidProjectAndTakDetector.h"
#import "PunchCardStorage.h"
#import "LocalPunch.h"
#import "RemotePunch.h"
#import "TimeLinePunchesStorage.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "PunchCardObject.h"
#import "Constants.h"

@interface InvalidProjectAndTakDetector()

@property (nonatomic) PunchCardStorage *punchCardStorage;
@property (nonatomic) TimeLinePunchesStorage *timeLinePunchesStorage;

@end

@implementation InvalidProjectAndTakDetector

- (instancetype)initWithTimeLinePunchesStorage:(TimeLinePunchesStorage*)timeLinePunchesStorage
                              punchCardStorage:(PunchCardStorage *)punchCardStorage {
    
    self = [super init];
    if(self) {
        self.punchCardStorage = punchCardStorage;
        self.timeLinePunchesStorage = timeLinePunchesStorage;
    }
    return self;
}

-(void)validatePunchAndUpdate:(id<Punch>)punch withError:(NSDictionary*)error
{
    NSString *failureUri = error[@"failureUri"];
    if (failureUri != nil && failureUri != (id)[NSNull null]) {
        if ([failureUri isEqualToString:invalidProjectFailureUri]) {
            id<Punch> invalidPunch = [self updateStorageIfInvalidPunch:punch];
            if([invalidPunch isKindOfClass:[LocalPunch class]]) {
                LocalPunch *localPunch = invalidPunch;
                localPunch.isTimeEntryAvailable = NO;
                invalidPunch = localPunch;
                [self updatePunchCard:invalidPunch];
            }
        }
    }
}

#pragma mark - Private

- (void)updatePunchCard:(id<Punch>)punch {
    
    PunchCardObject *punchCardObject = [self.punchCardStorage getPunchCardObjectWithClientUri:punch.client.uri projectUri:punch.project.uri taskUri:punch.task.uri];
    
    if(!punchCardObject) {
        NSLog(@"no punch with specified combination");
        return;
    }
    
    punchCardObject.isValidPunchCard = punch.isTimeEntryAvailable;
    
    [self.punchCardStorage storePunchCard:punchCardObject];
}


- (id<Punch>)updateStorageIfInvalidPunch:(id<Punch>)punch {
    
    id<Punch> punchFromDB = [[self.timeLinePunchesStorage recentTwoPunches] firstObject];
    
    
    if([[self getClient:punch.client] isEqualToString:[self getClient:punchFromDB.client]] && [[self getProject:punch.project] isEqualToString:[self getProject:punchFromDB.project]] && [[self getTask:punch.task] isEqualToString:[self getTask:punch.task]]) {
        
        if([punchFromDB isKindOfClass:[RemotePunch class]]) {
            RemotePunch *remotePunchFromDB = punchFromDB;
            
            RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:punchFromDB.punchSyncStatus
                                                             nonActionedValidations:0
                                                                previousPunchStatus:remotePunchFromDB.previousPunchPairStatus
                                                                    nextPunchStatus:remotePunchFromDB.nextPunchPairStatus
                                                                      sourceOfPunch:remotePunchFromDB.sourceOfPunch
                                                                         actionType:remotePunchFromDB.actionType
                                                                      oefTypesArray:remotePunchFromDB.oefTypesArray
                                                                       lastSyncTime:remotePunchFromDB.lastSyncTime
                                                                            project:remotePunchFromDB.project
                                                                        auditHstory:nil
                                                                          breakType:remotePunchFromDB.breakType
                                                                           location:remotePunchFromDB.location
                                                                         violations:nil
                                                                          requestID:remotePunchFromDB.requestID
                                                                           activity:remotePunchFromDB.activity
                                                                           duration:nil
                                                                             client:remotePunchFromDB.client
                                                                            address:remotePunchFromDB.address
                                                                            userURI:remotePunchFromDB.userURI
                                                                           imageURL:remotePunchFromDB.imageURL
                                                                               date:remotePunchFromDB.date
                                                                               task:remotePunchFromDB.task
                                                                                uri:remotePunchFromDB.uri
                                                               isTimeEntryAvailable:NO
                                                                   syncedWithServer:remotePunchFromDB.syncedWithServer
                                                                     isMissingPunch:NO
                                                            previousPunchActionType:remotePunchFromDB.previousPunchActionType];
            punchFromDB = remotePunch;
            
            [self.timeLinePunchesStorage storeRemotePunch:remotePunch];
        }
        return punchFromDB;
    }
    
    return punch;
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
