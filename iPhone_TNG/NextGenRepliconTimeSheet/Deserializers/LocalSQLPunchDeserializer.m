#import "LocalSQLPunchDeserializer.h"
#import "PunchActionTypeDeserializer.h"
#import <CoreLocation/CoreLocation.h>
#import <MacTypes.h>
#import "BreakType.h"
#import "LocalPunch.h"
#import "RemotePunch.h"
#import "OfflineLocalPunch.h"
#import "TaskType.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "PunchOEFStorage.h"
#import "Activity.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchOEFStorage.h"
#import "ViolationsStorage.h"


@interface LocalSQLPunchDeserializer ()

@property (nonatomic) PunchActionTypeDeserializer *punchActionTypeDeserializer;
@property (nonatomic) ViolationsStorage *violationsStorage;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSCalendar *calendar;

@end

@implementation LocalSQLPunchDeserializer


- (instancetype)initWithPunchActionTypeDeserializer:(PunchActionTypeDeserializer*)punchActionTypeDeserializer
                                  violationsStorage:(ViolationsStorage *)violationsStorage
                                      DateFormatter:(NSDateFormatter *)dateFormatter
                                           calendar:(NSCalendar *)calendar {
    self = [super init];
    if (self)
    {
        self.punchActionTypeDeserializer = punchActionTypeDeserializer;
        self.violationsStorage = violationsStorage;
        self.dateFormatter = dateFormatter;
        self.calendar = calendar;
    }
    return self;
}

- (NSArray *)deserializeLocalSQLPunches:(NSArray *)localSQLPunchDictionaries punchOEFStorage:(PunchOEFStorage *)punchOEFStorage
{
    NSMutableArray *localPunches = [[NSMutableArray alloc] initWithCapacity:localSQLPunchDictionaries.count];
    for (NSDictionary *localPunchDictionary in localSQLPunchDictionaries) {
        LocalPunch *localPunch = [self deserializeSingleLocalSQLPunch:localPunchDictionary punchOEFStorage:punchOEFStorage];
        [localPunches addObject:localPunch];
    }
    return localPunches;
}

- (LocalPunch *)deserializeSingleLocalSQLPunch:(NSDictionary *)localSQLPunchDictionary punchOEFStorage:(PunchOEFStorage *)punchOEFStorage
{
    NSString *actionTypeString = localSQLPunchDictionary[@"action_type"];
    NSString *userUriString = localSQLPunchDictionary[@"user_uri"];
    NSString *punchDateString = localSQLPunchDictionary[@"date"];
    NSString *lastSyncTimeString = localSQLPunchDictionary[@"lastSyncTime"];
    NSDate *date = [self.dateFormatter dateFromString:punchDateString];
    NSString *address = [self addressWithDictionary:localSQLPunchDictionary];

    UIImage *image;
    NSData *imageData = localSQLPunchDictionary[@"image"];
    if (imageData && imageData != (id)[NSNull null]) {
        image = [UIImage imageWithData:imageData scale:[[UIScreen mainScreen] scale]];
    }

    BreakType *breakType = [self breakTypeWithDictionary:localSQLPunchDictionary];
    ClientType *clientType = [self clientTypeWithDictionary:localSQLPunchDictionary];
    ProjectType *projectType = [self projectTypeWithDictionary:localSQLPunchDictionary];
    TaskType *taskType = [self taskTypeWithDictionary:localSQLPunchDictionary];
    Activity *activityType = [self activityTypeWithDictionary:localSQLPunchDictionary];
    PunchActionType actionType = [self.punchActionTypeDeserializer deserialize:actionTypeString];
    CLLocation *location = [self locationWithDictionary:localSQLPunchDictionary];

    PunchSyncStatus punchSyncStatus = UnsubmittedSyncStatus;

    if (localSQLPunchDictionary[@"punchSyncStatus"]!= nil && localSQLPunchDictionary[@"punchSyncStatus"] != (id)[NSNull null])
    {
        punchSyncStatus = [localSQLPunchDictionary[@"punchSyncStatus"] unsignedIntegerValue] ;
    }

    
    NSDate *lastSyncTime =  nil;
    if (lastSyncTimeString != nil && ![lastSyncTimeString isKindOfClass:[NSNull class]] && lastSyncTimeString.length>0) {
        lastSyncTime = [self.dateFormatter dateFromString:lastSyncTimeString];
    }

    NSString *requestID = localSQLPunchDictionary[@"request_id"];

    NSArray *oefTypesArray = [punchOEFStorage getPunchOEFTypesForRequestID:requestID];
    
    BOOL offline = [localSQLPunchDictionary[@"offline"] boolValue];



    LocalPunch *localPunch;
    if (offline) {
        localPunch = [[OfflineLocalPunch alloc] initWithPunchSyncStatus:punchSyncStatus actionType:actionType lastSyncTime:lastSyncTime breakType:breakType location:location project:projectType requestID:requestID activity:activityType client:clientType oefTypes:oefTypesArray address:address userURI:userUriString image:image task:taskType date:date];
    }
    else {
        localPunch = [[LocalPunch alloc] initWithPunchSyncStatus:punchSyncStatus actionType:actionType lastSyncTime:lastSyncTime breakType:breakType location:location project:projectType requestID:requestID activity:activityType client:clientType oefTypes:oefTypesArray address:address userURI:userUriString image:image task:taskType date:date];
    }

    return localPunch;
}

- (id <Punch>)deserializeSingleSQLPunch:(NSDictionary *)sqlPunchDictionary punchOEFStorage:(PunchOEFStorage *)punchOEFStorage
{
    if (!sqlPunchDictionary) {
        return nil;
    }

    id <Punch> punch;
    NSString *punchURI = sqlPunchDictionary[@"uri"];
    if (punchURI ==nil || punch == (id)[NSNull null]|| [punchURI isKindOfClass:[NSNull class]] || punchURI.length==0)
    {
        punch = [self deserializeSingleLocalSQLPunch:sqlPunchDictionary punchOEFStorage:punchOEFStorage];
    }
    else {
        BreakType *breakType = [self breakTypeWithDictionary:sqlPunchDictionary];
        ClientType *clientType = [self clientTypeWithDictionary:sqlPunchDictionary];
        ProjectType *projectType = [self projectTypeWithDictionary:sqlPunchDictionary];
        TaskType *taskType = [self taskTypeWithDictionary:sqlPunchDictionary];
        Activity *activityType = [self activityTypeWithDictionary:sqlPunchDictionary];
        CLLocation *location = [self locationWithDictionary:sqlPunchDictionary];
        NSString *userURI = sqlPunchDictionary[@"user_uri"];
        PunchActionType actionType = [self.punchActionTypeDeserializer deserialize:sqlPunchDictionary[@"action_type"]];
        NSDate *date = [self.dateFormatter dateFromString:sqlPunchDictionary[@"date"]];
        NSString *lastSyncTimeString = sqlPunchDictionary[@"lastSyncTime"];

        id imageURLStringOrNull = sqlPunchDictionary[@"image_url"];
        NSURL *imageURL;
        if (imageURLStringOrNull != [NSNull null]) {
            imageURL = [NSURL URLWithString:imageURLStringOrNull];
        }

        NSString *address = [self addressWithDictionary:sqlPunchDictionary];
        PunchSyncStatus punchSyncStatus = UnsubmittedSyncStatus;

        if (sqlPunchDictionary[@"punchSyncStatus"]!=nil && sqlPunchDictionary[@"punchSyncStatus"] != (id)[NSNull null])
        {
            punchSyncStatus = [sqlPunchDictionary[@"punchSyncStatus"] unsignedIntegerValue] ;
        }
        NSDate *lastSyncTime =  nil;
        if (lastSyncTimeString !=nil && lastSyncTimeString != (id)[NSNull null] && lastSyncTimeString.length>0) {
            lastSyncTime = [self.dateFormatter dateFromString:lastSyncTimeString];
        }

        NSString *requestID = sqlPunchDictionary[@"request_id"];
        NSArray *oefTypesArray = [punchOEFStorage getPunchOEFTypesForRequestID:requestID];

         BOOL syncWithServer = [sqlPunchDictionary[@"sync_with_server"] boolValue];

        BOOL isTimeEntryAvailable = [sqlPunchDictionary[@"is_time_entry_available"] boolValue];

        SourceOfPunch sourceOfPunch = UnknownSourceOfPunch;

        if (sqlPunchDictionary[@"sourceOfPunch"]!=nil && sqlPunchDictionary[@"sourceOfPunch"] != (id)[NSNull null])
        {
            sourceOfPunch = [sqlPunchDictionary[@"sourceOfPunch"] unsignedIntegerValue] ;
        }
        
        PunchPairStatus previousPunchPairStatus = Unknown;

        if (sqlPunchDictionary[@"previousPunchPairStatus"]!=nil && sqlPunchDictionary[@"previousPunchPairStatus"] != (id)[NSNull null])
        {
            previousPunchPairStatus = [sqlPunchDictionary[@"previousPunchPairStatus"] unsignedIntegerValue] ;
        }

        PunchPairStatus nextPunchPairStatus = Unknown;
        if (sqlPunchDictionary[@"nextPunchPairStatus"]!=nil && sqlPunchDictionary[@"nextPunchPairStatus"] != (id)[NSNull null])
        {
            nextPunchPairStatus = [sqlPunchDictionary[@"nextPunchPairStatus"] unsignedIntegerValue] ;
        }
        
        PunchActionType previousPunchActionType = PunchActionTypeUnknown ;
        if (sqlPunchDictionary[@"previousPunchActionType"] != nil && sqlPunchDictionary[@"previousPunchActionType"] != (id)[NSNull null]) {
            previousPunchActionType = [self.punchActionTypeDeserializer deserialize:sqlPunchDictionary[@"previousPunchActionType"]] ;
        }
        NSDateComponents *durationComponents = nil;
        if (sqlPunchDictionary[@"duration"]!=nil && sqlPunchDictionary[@"duration"] != (id)[NSNull null])
        {
            NSDate *durationate = [self.dateFormatter dateFromString:sqlPunchDictionary[@"duration"]];
            durationComponents =  [self dateComponentsFromDate:durationate];
        }

        NSArray *violations = [self.violationsStorage getPunchViolations:punchURI];
        
        NSInteger nonActionedValidations = 0;
        
        if (sqlPunchDictionary[@"nonActionedValidationsCount"]!=nil && sqlPunchDictionary[@"nonActionedValidationsCount"] != (id)[NSNull null]) {
            nonActionedValidations =  [sqlPunchDictionary[@"nonActionedValidationsCount"] unsignedIntegerValue] ;
        }
        
        punch = [[RemotePunch alloc] initWithPunchSyncStatus:punchSyncStatus
                                      nonActionedValidations:nonActionedValidations
                                         previousPunchStatus:previousPunchPairStatus
                                             nextPunchStatus:nextPunchPairStatus
                                               sourceOfPunch:sourceOfPunch
                                                  actionType:actionType
                                               oefTypesArray:oefTypesArray
                                                lastSyncTime:lastSyncTime
                                                     project:projectType
                                                 auditHstory:nil
                                                   breakType:breakType
                                                    location:location
                                                  violations:violations
                                                   requestID:requestID
                                                    activity:activityType
                                                    duration:durationComponents
                                                      client:clientType
                                                     address:address
                                                     userURI:userURI
                                                    imageURL:imageURL
                                                        date:date
                                                        task:taskType
                                                         uri:punchURI
                                        isTimeEntryAvailable:isTimeEntryAvailable
                                            syncedWithServer:syncWithServer
                                              isMissingPunch:NO
                                     previousPunchActionType:previousPunchActionType ];
    }

    return punch;
}

#pragma mark - Private

-(NSDateComponents*)dateComponentsFromDate:(NSDate*)date
{
    NSCalendarUnit unitFlags = NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return components;
}

- (CLLocation *)locationWithDictionary:(NSDictionary *)sqlDictionary
{
    id latitudeOrNull = sqlDictionary[@"location_latitude"];
    id longitudeOrNull = sqlDictionary[@"location_longitude"];
    id accuracyOrNull = sqlDictionary[@"location_horizontal_accuracy"];

    CLLocation *location;
    if (latitudeOrNull != [NSNull null] && longitudeOrNull != [NSNull null] && accuracyOrNull != [NSNull null]) {
        CLLocationDegrees latitude = [latitudeOrNull doubleValue];
        CLLocationDegrees longitude = [longitudeOrNull doubleValue];
        CLLocationAccuracy accuracy = [accuracyOrNull doubleValue];

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:accuracy verticalAccuracy:-1 timestamp:[NSDate date]];
    }

    return location;
}

- (BreakType *)breakTypeWithDictionary:(NSDictionary *)sqlDictionary
{
    id breakTypeNameOrNil = sqlDictionary[@"break_type_name"];
    id breakTypeURIOrNil = sqlDictionary[@"break_type_uri"];
    NSString *breakTypeNameString;
    if (breakTypeNameOrNil && breakTypeNameOrNil != (id)[NSNull null]) {
        breakTypeNameString = breakTypeNameOrNil;
    }

    NSString *breakTypeURIString;
    if (breakTypeURIOrNil && breakTypeURIOrNil != (id)[NSNull null]) {
        breakTypeURIString = breakTypeURIOrNil;
    }

    BreakType *breakType;
    if (breakTypeNameString && breakTypeURIString) {
        breakType = [[BreakType alloc] initWithName:breakTypeNameString uri:breakTypeURIString];
    }

    return breakType;
}

- (ClientType *)clientTypeWithDictionary:(NSDictionary *)sqlDictionary
{
    id clientTypeNameOrNil = sqlDictionary[@"client_name"];
    id clientTypeURIOrNil = sqlDictionary[@"client_uri"];
    NSString *clientTypeNameString;
    if (clientTypeNameOrNil && clientTypeNameOrNil != (id)[NSNull null]) {
        clientTypeNameString = clientTypeNameOrNil;
    }
    
    NSString *clientTypeURIString;
    if (clientTypeURIOrNil && clientTypeURIOrNil != (id)[NSNull null]) {
        clientTypeURIString = clientTypeURIOrNil;
    }
    
    ClientType *clientType;
    if (clientTypeNameString && clientTypeURIString) {
        clientType = [[ClientType alloc] initWithName:clientTypeNameString
                                                  uri:clientTypeURIString];
    }
    
    return clientType;
}

- (ProjectType *)projectTypeWithDictionary:(NSDictionary *)sqlDictionary
{
    id projectTypeNameOrNil = sqlDictionary[@"project_name"];
    id projectTypeURIOrNil = sqlDictionary[@"project_uri"];
    NSString *projectTypeNameString;
    if (projectTypeNameOrNil && projectTypeNameOrNil != (id)[NSNull null]) {
        projectTypeNameString = projectTypeNameOrNil;
    }
    
    NSString *projectTypeURIString;
    if (projectTypeURIOrNil && projectTypeURIOrNil != (id)[NSNull null]) {
        projectTypeURIString = projectTypeURIOrNil;
    }


    id clientTypeNameOrNil = sqlDictionary[@"client_name"];
    id clientTypeURIOrNil = sqlDictionary[@"client_uri"];
    NSString *clientTypeNameString;
    if (clientTypeNameOrNil && clientTypeNameOrNil != (id)[NSNull null]) {
        clientTypeNameString = clientTypeNameOrNil;
    }

    NSString *clientTypeURIString;
    if (clientTypeURIOrNil && clientTypeURIOrNil != (id)[NSNull null]) {
        clientTypeURIString = clientTypeURIOrNil;
    }

    ClientType *clientType;
    if (clientTypeNameString && clientTypeURIString) {
        clientType = [[ClientType alloc] initWithName:clientTypeNameString
                                                  uri:clientTypeURIString];
    }
    
    ProjectType *breakType;
    if (projectTypeNameString && projectTypeURIString) {
        breakType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                         isTimeAllocationAllowed:NO
                                                                   projectPeriod:nil
                                                                      clientType:clientType
                                                                            name:projectTypeNameString
                                                                             uri:projectTypeURIString];
    }
    
    return breakType;
}

- (TaskType *)taskTypeWithDictionary:(NSDictionary *)sqlDictionary
{
    id taskTypeNameOrNil = sqlDictionary[@"task_name"];
    id taskTypeURIOrNil = sqlDictionary[@"task_uri"];
    id projectURIOrNil = sqlDictionary[@"project_uri"];

    NSString *taskTypeNameString;
    if (taskTypeNameOrNil && taskTypeNameOrNil != (id)[NSNull null]) {
        taskTypeNameString = taskTypeNameOrNil;
    }
    
    NSString *taskTypeURIString;
    if (taskTypeURIOrNil && taskTypeURIOrNil != (id)[NSNull null]) {
        taskTypeURIString = taskTypeURIOrNil;
    }

    NSString *projectURIString;
    if (projectURIOrNil && projectURIOrNil != (id)[NSNull null]) {
        projectURIString = projectURIOrNil;
    }
    
    TaskType *taskType;
    if (taskTypeNameString && taskTypeURIString) {
        taskType = [[TaskType alloc] initWithProjectUri:projectURIOrNil
                                             taskPeriod:nil
                                                   name:taskTypeNameString
                                                    uri:taskTypeURIString];
    }
    
    return taskType;
}

- (Activity *)activityTypeWithDictionary:(NSDictionary *)sqlDictionary
{
    id activityTypeNameOrNil = sqlDictionary[@"activity_name"];
    id activityTypeURIOrNil = sqlDictionary[@"activity_uri"];
    
    NSString *activityTypeNameString;
    if (activityTypeNameOrNil && activityTypeNameOrNil != (id)[NSNull null]) {
        activityTypeNameString = activityTypeNameOrNil;
    }
    
    NSString *activityTypeURIString;
    if (activityTypeURIOrNil && activityTypeURIOrNil != (id)[NSNull null]) {
        activityTypeURIString = activityTypeURIOrNil;
    }
    
    Activity *activityType;
    if (activityTypeNameString && activityTypeURIString) {
        activityType = [[Activity alloc] initWithName:activityTypeNameString uri:activityTypeURIString];
    }
    
    return activityType;
}

- (NSString *)addressWithDictionary:(NSDictionary *)sqlDictionary
{
    id addressOrNull = sqlDictionary[@"address"];
    NSString *address;
    if (addressOrNull && addressOrNull != (id)[NSNull null]) {
        address = addressOrNull;
    }

    return address;
}



@end
