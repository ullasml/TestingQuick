
#import <Foundation/Foundation.h>

@class ClientType;
@class ProjectType;
@class TaskType;
@class UserPermissionsStorage;
@class ReporteePermissionsStorage;
@class Activity;

@interface PunchValidator : NSObject

@property(nonatomic,readonly) UserPermissionsStorage *userPermissionStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionStorage:(UserPermissionsStorage *)userPermissionStorage reporteePermissionStorage:(ReporteePermissionsStorage *)reporteePermissionStorage;

- (NSError *)validatePunchWithProjectType:(ProjectType *)project
                                 taskType:(TaskType *)task;

- (NSError *)validateManualPunchForPunchWithProjectType:(ProjectType *)project
                                               taskType:(TaskType *)task
                                                userUri:(NSString *)userUri;

- (NSError *)validatePunchWithClientType:(ClientType*)clientType
                             ProjectType:(ProjectType *)project
                                taskType:(TaskType *)task;

- (NSError *)validatePunchWithClientType:(ClientType*)client
                             projectType:(ProjectType *)project
                                taskType:(TaskType *)task
                            activityType:(Activity *)activity
                                 userUri:(NSString*)userUri;

@end
