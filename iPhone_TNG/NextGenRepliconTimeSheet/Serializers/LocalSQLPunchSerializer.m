#import "LocalSQLPunchSerializer.h"
#import "LocalPunch.h"
#import "BreakType.h"
#import "Constants.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Activity.h"



@implementation LocalSQLPunchSerializer

- (NSDictionary *)serializePunchForStorage:(LocalPunch *)localPunch
{

    NSMutableDictionary *punchDictionary = [NSMutableDictionary dictionary];
    
    NSDate *punchDate = [localPunch date];
    
    if (punchDate) {
        NSDictionary *punchDateDictionary = @{@"date": punchDate};
        [punchDictionary addEntriesFromDictionary:punchDateDictionary];
    }
    
    NSString *punchActionType = [self punchActionTypeString:[localPunch actionType]];
    
    if (punchActionType) {
        NSDictionary *punchActionTypeDictionary = @{@"action_type": punchActionType};
        [punchDictionary addEntriesFromDictionary:punchActionTypeDictionary];
    }
    
    NSString *userUri = [[localPunch userURI] mutableCopy];
    
    if (userUri) {
        NSDictionary *userUriDictionary = @{@"user_uri": userUri};
        [punchDictionary addEntriesFromDictionary:userUriDictionary];
    }


    if ([localPunch breakType]) {
        NSDictionary *breakTypeDictionary = @{@"break_type_name": [[localPunch breakType] name],
                                              @"break_type_uri": [[localPunch breakType] uri]};
        [punchDictionary addEntriesFromDictionary:breakTypeDictionary];

    }

    if ([localPunch location]) {
        NSDictionary *locationDictionary = @{@"location_latitude": @([localPunch location].coordinate.latitude),
                                             @"location_longitude": @([localPunch location].coordinate.longitude),
                                             @"location_horizontal_accuracy": @([localPunch location].horizontalAccuracy)};
        [punchDictionary addEntriesFromDictionary:locationDictionary];
    }
    BOOL isClientValueAvailable = ([localPunch client] && (localPunch.client.uri != nil && ![localPunch.client.uri isKindOfClass:[NSNull class]]));
    if (isClientValueAvailable) {
        NSDictionary *clientTypeDictionary = @{@"client_name": localPunch.client.name,
                                               @"client_uri": localPunch.client.uri};
        [punchDictionary addEntriesFromDictionary:clientTypeDictionary];
    }
    BOOL isProjectValueAvailable = ([localPunch project] && (localPunch.project.uri != nil && ![localPunch.project.uri isKindOfClass:[NSNull class]]));
    if (isProjectValueAvailable) {
        NSDictionary *projectTypeDictionary = @{@"project_name": localPunch.project.name,
                                                @"project_uri": localPunch.project.uri};
        [punchDictionary addEntriesFromDictionary:projectTypeDictionary];
    }
    BOOL isTaskValueAvailable = ([localPunch task] && (localPunch.task.uri != nil && ![localPunch.task.uri isKindOfClass:[NSNull class]]));
    if (isTaskValueAvailable) {
        NSDictionary *taskTypeDictionary = @{@"task_name": localPunch.task.name,
                                             @"task_uri": localPunch.task.uri};
        [punchDictionary addEntriesFromDictionary:taskTypeDictionary];
    }
    BOOL isActivityValueAvailable = ([localPunch activity] && (localPunch.activity.uri != nil && ![localPunch.activity.uri isKindOfClass:[NSNull class]]));
    if (isActivityValueAvailable) {
        NSDictionary *activityTypeDictionary = @{@"activity_name": localPunch.activity.name,
                                             @"activity_uri": localPunch.activity.uri};
        [punchDictionary addEntriesFromDictionary:activityTypeDictionary];
    }


    if ([localPunch address]) {
        [punchDictionary addEntriesFromDictionary:@{@"address": [localPunch address]}];
    }

    if ([localPunch image] != (id)[NSNull null]) {
        NSData *imageData = UIImagePNGRepresentation([localPunch image]);
        [punchDictionary setValue:imageData forKey:@"image"];
    }

    
    PunchSyncStatus punchSyncStatus = localPunch.punchSyncStatus;
    
    NSDictionary *punchSyncStatusDictionary = @{@"punchSyncStatus": @(punchSyncStatus)};
    [punchDictionary addEntriesFromDictionary:punchSyncStatusDictionary];

    if (localPunch.lastSyncTime) {
        NSDictionary *lastSyncTimeDictionary = @{@"lastSyncTime": localPunch.lastSyncTime};
        [punchDictionary addEntriesFromDictionary:lastSyncTimeDictionary];
    }


    NSNumber *offlineValue = [NSNumber numberWithBool:localPunch.offline];
    [punchDictionary setValue:offlineValue forKey:@"offline"];
    
    NSString *requestID = [[localPunch requestID] mutableCopy];
    
    if (requestID) {
        NSDictionary *requestIDDictionary = @{@"request_id": requestID};
        [punchDictionary addEntriesFromDictionary:requestIDDictionary];
    }

    return punchDictionary;
}

- (NSDictionary *)serializePunchForDeletion:(LocalPunch *)localPunch
{
    return  @{@"user_uri": localPunch.userURI,
              @"action_type": [self punchActionTypeString:localPunch.actionType],
              @"date": localPunch.date};
}

#pragma mark - Private

- (NSString *) punchActionTypeString:(PunchActionType) punchActionType
{
    switch (punchActionType) {
        case PunchActionTypePunchIn:
            return PUNCH_ACTION_URI_IN;

        case PunchActionTypePunchOut:
            return PUNCH_ACTION_URI_OUT;

        case PunchActionTypeStartBreak:
            return PUNCH_ACTION_URI_BREAK;
            break;
        case PunchActionTypeTransfer:
            return PUNCH_ACTION_URI_TRANSFER;

        default:
            return @"PunchActionTypeUnknown";
            break;
    }
}
@end
