#import "RemoteSQLPunchSerializer.h"
#import "RemotePunch.h"
#import "Constants.h"
#import "BreakType.h"
#import <CoreLocation/CoreLocation.h>
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Activity.h"


@interface RemoteSQLPunchSerializer ()

@property (nonatomic) NSCalendar *calendar;

@end


@implementation RemoteSQLPunchSerializer

- (instancetype)initWithCalendar:(NSCalendar *)calendar {
    self = [super init];
    if (self)
    {
        self.calendar = calendar;
    }
    return self;
}


- (NSMutableDictionary *)serializePunchForStorage:(RemotePunch *)remotePunch
{
    NSMutableDictionary *punchDictionary = [@{@"action_type": [self punchActionTypeString:remotePunch.actionType],
                                              @"user_uri": remotePunch.userURI,
                                              @"date": remotePunch.date,
                                              @"uri": remotePunch.uri} mutableCopy];
    if (remotePunch.breakType) {
        NSDictionary *breakTypeDictionary = @{@"break_type_name": remotePunch.breakType.name,
                                              @"break_type_uri": remotePunch.breakType.uri};
        [punchDictionary addEntriesFromDictionary:breakTypeDictionary];
    }
    BOOL isClientValueAvailable = ([remotePunch client] && (remotePunch.client.uri != nil && ![remotePunch.client.uri isKindOfClass:[NSNull class]]));

    if (isClientValueAvailable) {
        NSDictionary *clientTypeDictionary = @{@"client_name": remotePunch.client.name,
                                              @"client_uri": remotePunch.client.uri};
        [punchDictionary addEntriesFromDictionary:clientTypeDictionary];
    }
    BOOL isProjectValueAvailable = ([remotePunch project] && (remotePunch.project.uri != nil && ![remotePunch.project.uri isKindOfClass:[NSNull class]]));
    if (isProjectValueAvailable) {
        NSDictionary *projectTypeDictionary = @{@"project_name": remotePunch.project.name,
                                              @"project_uri": remotePunch.project.uri};
        [punchDictionary addEntriesFromDictionary:projectTypeDictionary];
    }
    BOOL isTaskValueAvailable = ([remotePunch task] && (remotePunch.task.uri != nil && ![remotePunch.task.uri isKindOfClass:[NSNull class]]));
    if (isTaskValueAvailable) {
        NSDictionary *taskTypeDictionary = @{@"task_name": remotePunch.task.name,
                                              @"task_uri": remotePunch.task.uri};
        [punchDictionary addEntriesFromDictionary:taskTypeDictionary];
    }
    BOOL isActivityValueAvailable = ([remotePunch activity] && (remotePunch.activity.uri != nil && ![remotePunch.activity.uri isKindOfClass:[NSNull class]]));
    if (isActivityValueAvailable) {
        NSDictionary *activityTypeDictionary = @{@"activity_name": remotePunch.activity.name,
                                                 @"activity_uri": remotePunch.activity.uri};
        [punchDictionary addEntriesFromDictionary:activityTypeDictionary];
    }
    if (remotePunch.imageURL) {
        NSDictionary *imageDictionary = @{@"image_url": remotePunch.imageURL.absoluteString};
        [punchDictionary addEntriesFromDictionary:imageDictionary];
    }

    if (remotePunch.location) {
        NSDictionary *locationDictionary = @{@"location_latitude": @(remotePunch.location.coordinate.latitude),
                                             @"location_longitude": @(remotePunch.location.coordinate.longitude),
                                             @"location_horizontal_accuracy": @(remotePunch.location.horizontalAccuracy)};
        [punchDictionary addEntriesFromDictionary:locationDictionary];
    }

    if (remotePunch.address) {
        NSDictionary *addressDictionary = @{@"address": remotePunch.address};
        [punchDictionary addEntriesFromDictionary:addressDictionary];
    }

    if (remotePunch.previousPunchActionType) {
        NSDictionary *previousPunchActionTypeDictionary = @{@"previousPunchActionType":  [self punchActionTypeString:remotePunch.previousPunchActionType]};
        [punchDictionary addEntriesFromDictionary:previousPunchActionTypeDictionary];
    }

    PunchSyncStatus punchSyncStatus = remotePunch.punchSyncStatus;
    
    if (punchSyncStatus) {
        NSDictionary *punchSyncStatusDictionary = @{@"punchSyncStatus": @(punchSyncStatus)};
        [punchDictionary addEntriesFromDictionary:punchSyncStatusDictionary];
    }

    NSDictionary *syncServerDictionary = @{@"sync_with_server": [NSNumber numberWithBool:remotePunch.syncedWithServer]};
    [punchDictionary addEntriesFromDictionary:syncServerDictionary];


    NSDictionary *isTimeEntryAvailableDict = @{@"is_time_entry_available":[NSNumber numberWithBool:remotePunch.isTimeEntryAvailable]};
    [punchDictionary addEntriesFromDictionary:isTimeEntryAvailableDict];

    NSDictionary *lastSyncTimeDictionary = @{@"lastSyncTime": [NSNull null]};
    [punchDictionary addEntriesFromDictionary:lastSyncTimeDictionary];

    NSString *requestID = [[remotePunch requestID] mutableCopy];

    if (requestID) {
        NSDictionary *requestIDDictionary = @{@"request_id": requestID};
        [punchDictionary addEntriesFromDictionary:requestIDDictionary];
    }
    
    PunchPairStatus previousPunchPairStatus = remotePunch.previousPunchPairStatus;
    
    NSDictionary *previousPunchPairStatusDictionary = @{@"previousPunchPairStatus": @(previousPunchPairStatus)};
    [punchDictionary addEntriesFromDictionary:previousPunchPairStatusDictionary];
    
    PunchPairStatus nextPunchPairStatus = remotePunch.nextPunchPairStatus;
    
    NSDictionary *nextPunchPairStatusDictionary = @{@"nextPunchPairStatus": @(nextPunchPairStatus)};
    [punchDictionary addEntriesFromDictionary:nextPunchPairStatusDictionary];
    
    NSInteger nonActionedValidationsCount = remotePunch.nonActionedValidationsCount;
    
    NSDictionary *nonActionedValidationsCountDictionary = @{@"nonActionedValidationsCount": [NSNumber numberWithInteger:nonActionedValidationsCount]};
    [punchDictionary addEntriesFromDictionary:nonActionedValidationsCountDictionary];
    
    SourceOfPunch sourceOfPunch = remotePunch.sourceOfPunch;
    
    NSDictionary *sourceOfPunchDictionary = @{@"sourceOfPunch": @(sourceOfPunch)};
    [punchDictionary addEntriesFromDictionary:sourceOfPunchDictionary];
    
    NSDateComponents *durationCompoenets = remotePunch.duration;
    
    if (durationCompoenets) {
        NSDate *duration = [self dateFromComponents:durationCompoenets];
        NSDictionary *durationDictionary = @{@"duration": duration};
        [punchDictionary addEntriesFromDictionary:durationDictionary];
    }

    return punchDictionary;
}


#pragma mark - Private

-(NSDate*)dateFromComponents:(NSDateComponents*)duration{
    NSInteger hour = duration.hour;
    NSInteger minute = duration.minute;
    NSInteger second = duration.second;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    [components setDay:1];
    [components setMonth:1];
    [components setYear:1970];
    
    return  [self.calendar dateFromComponents:components];
}


- (NSString *) punchActionTypeString:(PunchActionType) punchActionType
{
    switch (punchActionType) {
        case PunchActionTypePunchIn:
            return PUNCH_ACTION_URI_IN;

        case PunchActionTypePunchOut:
            return PUNCH_ACTION_URI_OUT;

        case PunchActionTypeStartBreak:
            return PUNCH_ACTION_URI_BREAK;

        case PunchActionTypeTransfer:
            return PUNCH_ACTION_URI_TRANSFER;

        case PunchActionTypeResumeWork:
            return PUNCH_ACTION_URI_TRANSFER;

        case PunchActionTypeUnknown:
            return @"PunchActionTypeUnknown";
    }
}

@end
