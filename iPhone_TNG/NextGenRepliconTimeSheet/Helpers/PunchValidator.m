#import "PunchValidator.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "UserPermissionsStorage.h"
#import "Constants.h"
#import "ReporteePermissionsStorage.h"
#import "ClientType.h"
#import "Activity.h"
#import "ClientType.h"

typedef enum {
  PunchIntoNone = 0,
  PunchIntoProject = 1,
  PunchIntoActivities = 2,
  PunchIntoProjectSupervisor = 3,
  PunchIntoActivitiesSupervisor = 4,
} UserType;

@interface PunchValidator ()
@property(nonatomic) UserPermissionsStorage *userPermissionStorage;
@property(nonatomic) ReporteePermissionsStorage *reporteePermissionsStorage;
@end

@implementation PunchValidator

- (instancetype)initWithUserPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                    reporteePermissionStorage:(ReporteePermissionsStorage *)reporteePermissionStorage {
    self = [super init];
    if (self)
    {
        self.userPermissionStorage = userPermissionStorage;
        self.reporteePermissionsStorage = reporteePermissionStorage;
    }
    return self;
}

- (NSError *)validatePunchWithProjectType:(ProjectType *)project
                                 taskType:(TaskType *)task
{
    NSError *error= nil;
    if ([self.userPermissionStorage isProjectTaskSelectionRequired])
    {
        if ([self.userPermissionStorage hasProjectAccess]) {
            if (project.name == nil) {
                return [self errorWithDomain:@"" message:InvalidProjectSelectedError];
                
            }
        }

        if (task.name == nil) {
            return [self errorWithDomain:@"" message:InvalidTaskSelectedError];
            
        }
    }
    return error;
}

- (NSError *)validatePunchWithActivity:(Activity *)activity

{
    NSError *error= nil;
    if([self.userPermissionStorage isActivitySelectionRequired]) {
        
        if([self.userPermissionStorage hasActivityAccess]) {
            if(activity.name == nil) {
                return [self errorWithDomain:@"" message: RPLocalizedString(InvalidActivitySelectedError, nil)];
            }
        }
    }
    return error;
}

- (NSError *)validateManualPunchForPunchWithActivity:(Activity *)activity
                                                userUri:(NSString *)userUri
{
    NSError *error= nil;
    if ([self.reporteePermissionsStorage isReporteeActivitySelectionRequired:userUri])
    {
        if ([self.reporteePermissionsStorage canAccessActivityUserWithUri:userUri]) {
            if (activity.name == nil) {
               return [self errorWithDomain:@"" message: RPLocalizedString(InvalidActivitySelectedError, nil)];
            }
        }
    }
    return error;
}

- (NSError *)validateManualPunchForPunchWithProjectType:(ProjectType *)project
                                               taskType:(TaskType *)task
                                                userUri:(NSString *)userUri
{
    NSError *error= nil;
    if ([self.reporteePermissionsStorage isReporteeProjectTaskSelectionRequired:userUri])
    {
        if ([self.reporteePermissionsStorage canAccessProjectUserWithUri:userUri]) {
            if (project.name == nil) {
                return [self errorWithDomain:@"" message:InvalidProjectSelectedError];
            }
        }
        
        if (task.name == nil) {
            return [self errorWithDomain:@"" message:InvalidTaskSelectedError];
        }
    }
    return error;
}

- (NSError *)validatePunchWithClientType:(ClientType*)clientType
                             ProjectType:(ProjectType *)project
                                 taskType:(TaskType *)task
{
    NSError *error= nil;
    if ([self.userPermissionStorage hasClientAccess])
    {
        if (clientType.name == nil && project.name == nil && task.name == nil) {
            return [self errorWithDomain:@"" message:clientProjectTaskSelectionErrorMsg];
        }
    }
    
    if (project.name == nil && task.name != nil) {
        return [self errorWithDomain:@"" message:InvalidProjectSelectedError];
    }
    
    BOOL isProjectAndTaskNil = (project.name == nil && task.name == nil);
    if (isProjectAndTaskNil && [self.userPermissionStorage isProjectTaskSelectionRequired])
    {
        return [self errorWithDomain:@"" message:projectAndTaskSelectionErrorMsg];
    }
    else{
        if (project.name == nil)
        {
            return [self errorWithDomain:@"" message:InvalidProjectSelectedError];
        }
        else if ([self.userPermissionStorage isProjectTaskSelectionRequired] && task.name==nil)
        {
            return [self errorWithDomain:@"" message:InvalidTaskSelectedError];
        }
        else if (isProjectAndTaskNil) {
            return [self errorWithDomain:@"" message:InvalidProjectSelectedError];
        }
    }
    return error;
}

- (NSError *)validatePunchWithClientType:(ClientType*)client
                            projectType:(ProjectType *)project
                               taskType:(TaskType *)task
                           activityType:(Activity *)activity
                                userUri:(NSString*)userUri {
    NSError *error= nil;
    
    UserType userType = [self getUserTypeWithUserUri:userUri];
    
    switch (userType) {
            
        case PunchIntoProject:
            error = [self validatePunchWithProjectType:project taskType:task];
            break;
            
        case PunchIntoActivities:
            error = [self validatePunchWithActivity:activity];
            break;
        case PunchIntoProjectSupervisor:
            error = [self validateManualPunchForPunchWithProjectType:project taskType:task userUri:userUri];
            break;
        case PunchIntoActivitiesSupervisor:
            error = [self validateManualPunchForPunchWithActivity:activity userUri:userUri];
            break;
            
        default:
            break;
    }
    return error;
}

#pragma mark - Helper Methods

-(NSError *)errorWithDomain:(NSString *)domain message:(NSString *)message
{
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey: message};
    NSError *error = [[NSError alloc] initWithDomain:domain code:500 userInfo:userInfo];
    return error;
}

- (UserType)getUserTypeWithUserUri:(NSString *)userUri {
    
    UserType userType = PunchIntoNone;
    
    if(!IsNotEmptyString(userUri)) { // User Context
        
        if([self.userPermissionStorage hasProjectAccess] && ![self.userPermissionStorage hasActivityAccess]) {
            userType = PunchIntoProject;
        }
        else if (![self.userPermissionStorage hasProjectAccess] && [self.userPermissionStorage hasActivityAccess]) {
            userType = PunchIntoActivities;
        }
    }
    else { // Supervisor Context
        
        if([self.reporteePermissionsStorage canAccessProjectUserWithUri:userUri] && ![self.reporteePermissionsStorage canAccessActivityUserWithUri:userUri]) {
            
            userType = PunchIntoProjectSupervisor;
        }
        else if (![self.reporteePermissionsStorage canAccessProjectUserWithUri:userUri] && [self.reporteePermissionsStorage canAccessActivityUserWithUri:userUri]) {
            
            userType = PunchIntoActivitiesSupervisor;
        }
    }

    return userType;
}



@end
