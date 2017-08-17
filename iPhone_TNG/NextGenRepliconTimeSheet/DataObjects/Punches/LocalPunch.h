#import <Foundation/Foundation.h>
#import "PunchActionTypes.h"
#import "Punch.h"
#import "Constants.h"
#import "Enum.h"


@class CLLocation;
@class BreakType;
@class Activity;
@class ProjectType;
@class ClientType;
@class TaskType;


@interface LocalPunch : NSObject <Punch>

@property (nonatomic, assign) BOOL isTimeEntryAvailable;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

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
                                   date:(NSDate *)date;

@end
