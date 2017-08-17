#import "LocalPunch.h"
#import "BreakType.h"
#import "Activity.h"
#import <CoreLocation/CoreLocation.h>
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "Enum.h"


@interface LocalPunch ()

@property (nonatomic) NSDate *date;
@property (nonatomic) PunchActionType actionType;
@property (nonatomic) CLLocation *location;
@property (nonatomic) UIImage *image;
@property (nonatomic) BreakType *breakType;
@property (nonatomic) Activity *activity;
@property (nonatomic) ProjectType *project;
@property (nonatomic) ClientType *client;
@property (nonatomic) TaskType *task;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSArray *oefTypesArray;
@property (assign, nonatomic)PunchSyncStatus punchSyncStatus;
@property (nonatomic) NSDate *lastSyncTime;
@property (nonatomic, copy) NSString *requestID;
@end


@implementation LocalPunch

- (instancetype)initWithPunchSyncStatus:(PunchSyncStatus)punchSyncStatus
                             actionType:(PunchActionType)actionType
                           lastSyncTime:(NSDate *)lastSyncTime
                              breakType:(BreakType *)breakType
                               location:(CLLocation *)location
                                project:(ProjectType *)project
                              requestID:(NSString *)requestID
                               activity:(Activity *)activity
                                 client:(ClientType *)client
                               oefTypes:(NSArray *)oefTypes
                                address:(NSString *)address
                                userURI:(NSString *)userURI
                                  image:(UIImage *)image
                                   task:(TaskType *)task
                                   date:(NSDate *)date {
    self = [super init];
    if (self) {
        self.activity = activity;
        self.project = project;
        self.client = client;
        self.task = task;
        self.actionType = actionType;
        self.breakType = breakType;
        self.location = location;
        self.userURI = userURI;
        self.address = address;
        self.image = image;
        self.date = date;
        self.oefTypesArray = oefTypes;
        self.punchSyncStatus = punchSyncStatus;
        self.lastSyncTime = lastSyncTime;
        self.requestID = requestID;
        self.isTimeEntryAvailable = YES;
    }

    return self;
}

- (BOOL)offline
{
    return NO;
}

- (BOOL)authentic
{
    return YES;
}

- (BOOL)manual
{
    return NO;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)isEqual:(LocalPunch *)otherPunch
{
    if(![otherPunch isKindOfClass:[self class]]) {
        return NO;
    }

    CLLocationCoordinate2D coordinate = self.location.coordinate;
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    CLLocationAccuracy horizontalAccuracy = self.location.horizontalAccuracy;

    CLLocationCoordinate2D otherCoordinate = otherPunch.location.coordinate;
    CLLocationDegrees otherLatitude = otherCoordinate.latitude;
    CLLocationDegrees otherLongitude = otherCoordinate.longitude;
    CLLocationAccuracy otherHorizontalAccuracy = otherPunch.location.horizontalAccuracy;

    BOOL datesEqual = (!otherPunch.date && !self.date) || ((otherPunch.date && self.date) && [otherPunch.date compare:self.date] == NSOrderedSame);
    BOOL actionsEqual = (otherPunch.actionType == self.actionType);
    BOOL latitudesEqual = (latitude == otherLatitude);
    BOOL longitudesEqual = (longitude == otherLongitude);
    BOOL horizontalAccuracyEqual = (horizontalAccuracy == otherHorizontalAccuracy);
    BOOL imagesEqual = (!otherPunch.image && !self.image) || [UIImagePNGRepresentation(otherPunch.image) isEqualToData:UIImagePNGRepresentation(self.image)];
    BOOL addressesEqual = (!otherPunch.address && !self.address) || ([self.address isEqualToString:otherPunch.address]);
    BOOL breakTypeEqual = (!otherPunch.breakType && !self.breakType) || ([self.breakType isEqual:otherPunch.breakType]);
    BOOL activityEqual = (!otherPunch.activity && !self.activity) || ([self.activity isEqual:otherPunch.activity]);
    BOOL projectEqual = (!otherPunch.project && !self.project) || ([self.project isEqual:otherPunch.project]);
    BOOL clientEqual = (!otherPunch.client && !self.client) || ([self.client isEqual:otherPunch.client]);
    BOOL taskEqual = (!otherPunch.task && !self.task) || ([self.task isEqual:otherPunch.task]);
    BOOL offlineEqual = (self.offline == otherPunch.offline);
    BOOL userURIEqual = (!otherPunch.userURI && !self.userURI) || ([self.userURI isEqual:otherPunch.userURI]);
    BOOL oefTypesEqual = (!otherPunch.oefTypesArray && !self.oefTypesArray) || ([self.oefTypesArray isEqual:otherPunch.oefTypesArray]);
    BOOL punchSyncStatusEqual = (otherPunch.punchSyncStatus == self.punchSyncStatus);
    BOOL lastSyncTimeEqual = (!otherPunch.lastSyncTime && !self.lastSyncTime) || ((otherPunch.lastSyncTime && self.lastSyncTime) && [otherPunch.lastSyncTime compare:self.lastSyncTime] == NSOrderedSame);
    BOOL requestIDEqual = (!otherPunch.requestID && !self.requestID) || ([self.requestID isEqual:otherPunch.requestID]);

    return datesEqual &&
           actionsEqual &&
           latitudesEqual &&
           longitudesEqual &&
           horizontalAccuracyEqual &&
           addressesEqual &&
           imagesEqual &&
           breakTypeEqual &&
           offlineEqual &&
           userURIEqual &&
           activityEqual &&
           projectEqual &&
           clientEqual &&
           taskEqual &&
           oefTypesEqual &&
           punchSyncStatusEqual &&
           lastSyncTimeEqual &&
           requestIDEqual;



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
    return [NSString stringWithFormat:@"<%@>:\n action: %@ \n  breakType: %@ \n  date: %@ \n  location: %@ \n address: %@ activity:%@ project:%@  client:%@ task:%@ oefTypesArray:%@ \n punchSyncStatus: %@ \n lastSyncTime: %@ \n requestID: %@", NSStringFromClass([self class]),
            actionMapping[@(self.actionType)],
            self.breakType,
            self.date,
            self.location,
            self.address,
            self.activity,
            self.project,
            self.client,
            self.task,
            self.oefTypesArray,
            @(self.punchSyncStatus),
            self.lastSyncTime,
            self.requestID];
}

#pragma mark - <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder
{
    NSDate *date = [decoder decodeObjectForKey:@"date"];
    PunchActionType action = [[decoder decodeObjectForKey:@"actionType"] unsignedIntegerValue];
    CLLocation *location = [decoder decodeObjectForKey:@"location"];
    NSString *address = [decoder decodeObjectForKey:@"address"];
    BreakType *breakType = [decoder decodeObjectForKey:@"breakType"];
    UIImage *image = [UIImage imageWithData:[decoder decodeObjectForKey:@"image"] scale:[[UIScreen mainScreen] scale]];
    NSString *userURI = [decoder decodeObjectForKey:@"userURI"];
    Activity *activity = [decoder decodeObjectForKey:@"activity"];
    ProjectType *project = [decoder decodeObjectForKey:@"project"];
    ClientType *client = [decoder decodeObjectForKey:@"client"];
    TaskType *task = [decoder decodeObjectForKey:@"task"];
    NSMutableArray *oefTypesArray = [decoder decodeObjectForKey:@"oefTypesArray"];
    PunchSyncStatus punchSyncStatus = [[decoder decodeObjectForKey:@"punchSyncStatus"] unsignedIntegerValue];;
    NSDate *lastSyncTime = [decoder decodeObjectForKey:@"lastSyncTime"];
    NSString *requestID = [decoder decodeObjectForKey:@"requestID"];
    
    return [self initWithPunchSyncStatus:punchSyncStatus
                              actionType:action
                            lastSyncTime:lastSyncTime
                               breakType:breakType
                                location:location
                                 project:project
                               requestID:requestID
                                activity:activity
                                  client:client
                                oefTypes:oefTypesArray
                                 address:address
                                 userURI:userURI
                                   image:image
                                    task:task
                                    date:date];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:@(self.actionType) forKey:@"actionType"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.breakType forKey:@"breakType"];
    [coder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"image"];
    [coder encodeObject:self.userURI forKey:@"userURI"];
    [coder encodeObject:self.activity forKey:@"activity"];
    [coder encodeObject:self.project forKey:@"project"];
    [coder encodeObject:self.client forKey:@"client"];
    [coder encodeObject:self.task forKey:@"task"];
    [coder encodeObject:self.oefTypesArray forKey:@"oefTypesArray"];
    [coder encodeObject:@(self.punchSyncStatus) forKey:@"punchSyncStatus"];
    [coder encodeObject:self.lastSyncTime forKey:@"lastSyncTime"];
    [coder encodeObject:self.requestID forKey:@"requestID"];
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return [[LocalPunch alloc]
                        initWithPunchSyncStatus:self.punchSyncStatus
                                     actionType:self.actionType
                                   lastSyncTime:self.lastSyncTime
                                      breakType:self.breakType
                                       location:[self.location copy]
                                        project:self.project
                                      requestID:self.requestID
                                       activity:self.activity
                                         client:self.client
                                       oefTypes:[self.oefTypesArray copy]
                                        address:[self.address copy]
                                        userURI:[self.userURI copy]
                                          image:[self.image copy]
                                           task:self.task
                                           date:[self.date copy]];

}

@end
