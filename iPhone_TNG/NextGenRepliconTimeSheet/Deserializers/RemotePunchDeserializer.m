#import "RemotePunchDeserializer.h"
#import "LocalPunch.h"
#import <CoreLocation/CoreLocation.h>
#import <MacTypes.h>
#import "BreakType.h"
#import "RemotePunch.h"
#import "PunchActionTypeDeserializer.h"
#import "Activity.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "OEFDeserializer.h"
#import "Enum.h"
#import "GUIDProvider.h"
#import "ViolationsDeserializer.h"
#import "DateTimeComponentDeserializer.h"


@interface RemotePunchDeserializer ()

@property (nonatomic) PunchActionTypeDeserializer *punchActionTypeDeserializer;
@property (nonatomic) DateTimeComponentDeserializer *dateTimeComponentDeserializer;
@property (nonatomic) ViolationsDeserializer *violationsDeserializer;
@property (nonatomic) OEFDeserializer *oefDeserializer;
@property (nonatomic) GUIDProvider *guidProvider;
@property (nonatomic) NSCalendar *calendar;

@end


@implementation RemotePunchDeserializer

- (instancetype)initWithPunchActionTypeDeserializer:(PunchActionTypeDeserializer *)punchActionTypeDeserializer
                      dateTimeComponentDeserializer:(DateTimeComponentDeserializer *)dateTimeComponentDeserializer
                             violationsDeserializer:(ViolationsDeserializer *)violationsDeserializer
                                    oefDeserializer:(OEFDeserializer *)oefDeserializer
                                       guidProvider:(GUIDProvider *)guidProvider
                                           calendar:(NSCalendar *)calendar {
    self = [super init];
    if (self) {
        self.punchActionTypeDeserializer = punchActionTypeDeserializer;
        self.dateTimeComponentDeserializer = dateTimeComponentDeserializer;
        self.violationsDeserializer = violationsDeserializer;
        self.oefDeserializer = oefDeserializer;
        self.guidProvider = guidProvider;
        self.calendar = calendar;
    }

    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (RemotePunch *)deserialize:(NSDictionary *)punchDictionary
{
    if([punchDictionary isEqual:[NSNull null]]) {
        return nil;
    }

    NSDictionary *punchTimeDictionary = punchDictionary[@"punchTime"];

    BreakType *breakType;
    Activity *activity;
    ProjectType *project;
    ClientType *client;
    TaskType *task;

   NSNumber *isTimeEntryAvailableObj = punchDictionary[@"isTimeEntryAvailable"];

    BOOL isTimeEntryAvailable = (isTimeEntryAvailableObj != nil) ?[isTimeEntryAvailableObj boolValue] : YES;

    NSDictionary *punchInAttributes = punchDictionary[@"punchInAttributes"];
    if (punchInAttributes != (id)[NSNull null]) {
        NSDictionary *activityDictionary = punchInAttributes[@"activity"];
        if (activityDictionary != nil && activityDictionary != (id)[NSNull null]) {
            NSString *uri = activityDictionary[@"uri"];
            NSString *name = activityDictionary[@"displayText"];
            activity = [[Activity alloc] initWithName:name uri:uri];
        }
        NSDictionary *clientDictionary = punchInAttributes[@"client"];
        NSDictionary *projectDictionary = punchInAttributes[@"project"];
        NSDictionary *taskDictionary = punchInAttributes[@"task"];

        BOOL isClientAvailable = (clientDictionary != nil && clientDictionary != (id)[NSNull null]);
        BOOL isProjectAvailable = (projectDictionary != nil && projectDictionary != (id)[NSNull null]);
        BOOL isTaskAvailable = (taskDictionary != nil && taskDictionary != (id)[NSNull null]);

        if (isClientAvailable) {
            NSString *uri = clientDictionary[@"uri"];
            NSString *name = clientDictionary[@"displayText"];
            client = [[ClientType alloc] initWithName:name uri:uri];
        }
        if (isProjectAvailable) {
            NSString *uri = projectDictionary[@"uri"];
            NSString *name = projectDictionary[@"displayText"];
            project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:isTaskAvailable
                                                           isTimeAllocationAllowed:NO
                                                                     projectPeriod:nil
                                                                        clientType:client
                                                                              name:name
                                                                               uri:uri];
        }
        if (isTaskAvailable) {
            NSString *uri = taskDictionary[@"uri"];
            NSString *name = taskDictionary[@"displayText"];
            task = [[TaskType alloc] initWithProjectUri:project.uri
                                             taskPeriod:nil
                                                   name:name
                                                    uri:uri];
        }
    }

    NSDictionary *punchStartBreakAttributesDictionary = punchDictionary[@"punchStartBreakAttributes"];
    if (punchStartBreakAttributesDictionary != (id)[NSNull null]) {
        NSDictionary *breakTypeDictionary = punchStartBreakAttributesDictionary[@"breakType"];
        NSString *uri = breakTypeDictionary[@"uri"];
        NSString *name = breakTypeDictionary[@"displayText"];
        breakType = [[BreakType alloc] initWithName:name uri:uri];
    }

    
    NSDate *date = [self dateFromDictionary:punchTimeDictionary];

    NSDictionary *geolocation = punchDictionary[@"geolocation"];
    CLLocation *location;
    NSString *address;
    if (geolocation && geolocation != (id)[NSNull null]) {
        CLLocationDegrees latitude = [geolocation[@"gps"][@"latitudeInDegrees"] doubleValue];
        CLLocationDegrees longitude = [geolocation[@"gps"][@"longitudeInDegrees"] doubleValue];
        CLLocationAccuracy accuracy = [geolocation[@"gps"][@"accuracyInMeters"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:accuracy verticalAccuracy:-1 timestamp:[NSDate date]];
        if (geolocation[@"address"] != (id)[NSNull null]) {
            address = geolocation[@"address"];
        }
    }

    NSString *actionURI = punchDictionary[@"actionUri"];
    PunchActionType actionType = [self.punchActionTypeDeserializer deserialize:actionURI];

    NSURL *imageURL;
    NSDictionary *thumbnailDictionary = punchDictionary[@"auditImage"];
    if (thumbnailDictionary != (id)[NSNull null]) {
        imageURL = [NSURL URLWithString:thumbnailDictionary[@"imageLink"][@"href"]];
    }

    NSString *uri = punchDictionary[@"uri"];
    NSString *userURI = punchDictionary[@"user"][@"uri"];
    
    SourceOfPunch sourceOfPunch = UnknownSourceOfPunch;
    NSDictionary *timePunchAgent = punchDictionary[@"timePunchAgent"];
    if (timePunchAgent != nil && timePunchAgent != (id)[NSNull null]) {
        NSString *sourceOfPunchUri = timePunchAgent[@"agentTypeUri"];
        if (sourceOfPunchUri != nil && sourceOfPunchUri != (id)[NSNull null]) {
            sourceOfPunch = [self deserializeSourceForPunch:sourceOfPunchUri];
        }
    }
    
    PunchPairStatus previousPunchStatus = [self deserializePunchPairStatusForPunch:punchDictionary[@"previousPunchStatus"]];
    PunchPairStatus nextPunchStatus = [self deserializePunchPairStatusForPunch:punchDictionary[@"nextPunchStatus"]];
    NSString *previouPunchActionURI = punchDictionary[@"previousPunchActionUri"];
    PunchActionType previousPunchActionType = [self.punchActionTypeDeserializer deserialize:previouPunchActionURI];
    
    NSDateComponents *punchDurationComponents = [self.dateTimeComponentDeserializer deserializeDateTime:punchDictionary[@"totalHours"]];
    NSDictionary *extensionFieldsDictionary = punchDictionary[@"extensionFields"];
    NSString *punchActionTypeStr = [self.punchActionTypeDeserializer getPunchActionTypeString:actionType];
    NSMutableArray *oefTypesArray = [self.oefDeserializer deserializeMostRecentPunch:extensionFieldsDictionary punchActionType:punchActionTypeStr];
    NSArray *violations = [NSArray array];
    violations = [self.violationsDeserializer deserializeViolationsFromPunchValidationResult:punchDictionary];
    NSInteger nonActionedValidationsCount = [punchDictionary[@"nonActionedValidationsCount"] integerValue];
    return [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                 nonActionedValidations:nonActionedValidationsCount
                                    previousPunchStatus:previousPunchStatus
                                        nextPunchStatus:nextPunchStatus
                                          sourceOfPunch:sourceOfPunch
                                             actionType:actionType
                                          oefTypesArray:oefTypesArray
                                           lastSyncTime:nil
                                                project:project
                                            auditHstory:nil
                                              breakType:breakType
                                               location:location
                                             violations:violations
                                              requestID:[self.guidProvider guid]
                                               activity:activity
                                               duration:punchDurationComponents
                                                 client:client
                                                address:address
                                                userURI:userURI
                                               imageURL:imageURL
                                                   date:date
                                                   task:task
                                                    uri:uri
                                   isTimeEntryAvailable:isTimeEntryAvailable
                                       syncedWithServer:YES
                                         isMissingPunch:NO
                                previousPunchActionType:previousPunchActionType ];
}


- (SourceOfPunch)deserializeSourceForPunch:(NSString *)actionURI
{
    if ([actionURI isEqualToString:VIA_WEB]) {
        return Web;
    }
    else if ([actionURI isEqualToString:VIA_CLOUDCLOCK]) {
        return CloudClock;
    }
    else if ([actionURI isEqualToString:VIA_MOBILE]) {
        return Mobile;
    }
    else{
        return UnknownSourceOfPunch;
    }
}

- (PunchPairStatus)deserializePunchPairStatusForPunch:(NSString *)actionURI
{
    if (actionURI != nil && actionURI != (id)[NSNull null] && actionURI.length > 0) {
        NSDictionary *actionMap = @{
                                    @"urn:replicon:punch-timeline-pair-status:present": @(Present),
                                    @"urn:replicon:punch-timeline-pair-status:missing": @(Missing),
                                    @"urn:replicon:punch-timeline-pair-status:ticking": @(Ticking),
                                    };
        return [actionMap[actionURI] unsignedIntegerValue];
    }
    return Unknown;
    
}

-(NSDate*)dateFromDictionary:(NSDictionary*)punchTimeDictionary{
    NSNumber *day = punchTimeDictionary[@"day"];
    NSNumber *month = punchTimeDictionary[@"month"];
    NSNumber *year = punchTimeDictionary[@"year"];
    
    NSNumber *hour = punchTimeDictionary[@"hour"];
    NSNumber *minute = punchTimeDictionary[@"minute"];
    NSNumber *second = punchTimeDictionary[@"second"];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:[hour integerValue]];
    [components setMinute:[minute intValue]];
    [components setSecond:[second intValue]];
    [components setDay:[day integerValue]];
    [components setMonth:[month integerValue]];
    [components setYear:[year integerValue]];
    
    return  [self.calendar dateFromComponents:components];
}

@end
