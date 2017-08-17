
#import "ReporteePermissionsStorage.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"

@interface ReporteePermissionsStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) id<UserSession> userSession;

@end


static NSString *const ReporteeCanAccessProject                  = @"project_access";
static NSString *const ReporteeCanAccessClient                   = @"client_access";
static NSString *const ReporteeCanAccessActivity                 = @"activity_access";
static NSString *const ReporteeCanAccessBreak                    = @"break_access";
static NSString *const ReporteeIsPunchIntoProjectsUser           = @"isPunchIntoProjectsUser";
static NSString *const ReporteeSubmittedTimesheetUri             = @"timesheet_uri";
static NSString *const ReporteeProjectTaskSelectionRequired      = @"project_task_selection_required";
static NSString *const ReporteeActivitySelectionRequired         = @"activity_selection_required";

@implementation ReporteePermissionsStorage

- (instancetype)initWithSQLiteStore:(SQLiteTableStore *)sqliteStore
                        userSession:(id<UserSession>)userSession
{
    self = [super init];
    if (self) {
        self.sqliteStore = sqliteStore;
        self.userSession = userSession;
    }

    return self;
}

- (void)persistCanAccessProject:(NSNumber *)canAccessProject
                canAccessClient:(NSNumber *)canAccessClient
              canAccessActivity:(NSNumber *)canAccessActivity
   projectTaskSelectionRequired:(NSNumber *)projectTaskSelectionRequired
      activitySelectionRequired:(NSNumber *)activitySelectionRequired
                    isPunchIntoProjectUser:(NSNumber *)isPunchIntoProjectUser
                        userUri:(NSString *)userUri
                 canAccessBreak:(NSNumber *)canAccessBreak
{
    NSDictionary *userPermissionsDictionary = @{@"user_uri": userUri,
                                                ReporteeCanAccessProject:canAccessProject,
                                                ReporteeCanAccessClient:canAccessClient,
                                                ReporteeCanAccessActivity:canAccessActivity,
                                                ReporteeIsPunchIntoProjectsUser:isPunchIntoProjectUser,
                                                ReporteeProjectTaskSelectionRequired:projectTaskSelectionRequired,
                                                ReporteeActivitySelectionRequired:activitySelectionRequired,
                                                ReporteeCanAccessBreak:canAccessBreak
                                                };
    
    NSDictionary *currentUserFilter = [self currentUserFilterForUserWithUri:userUri];
    NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:currentUserFilter];
    if (resultSet) {
        [self.sqliteStore updateRow:userPermissionsDictionary whereClause:@{@"user_uri": userUri}];
    } else {
        [self.sqliteStore insertRow:userPermissionsDictionary];
    }
}

- (BOOL)canAccessProjectUserWithUri:(NSString *)userUri
{
    return [self readUserPermission:ReporteeCanAccessProject forUserWithUri:userUri];
}

- (BOOL)canAccessClientUserWithUri:(NSString *)userUri
{
    return [self readUserPermission:ReporteeCanAccessClient forUserWithUri:userUri];
}

- (BOOL)canAccessActivityUserWithUri:(NSString *)userUri
{
    return [self readUserPermission:ReporteeCanAccessActivity forUserWithUri:userUri];
}

- (BOOL)canAccessBreaksUserWithUri:(NSString *)userUri
{
    return [self readUserPermission:ReporteeCanAccessBreak forUserWithUri:userUri];
}

- (BOOL)isReporteePunchIntoProjectsUserWithUri:(NSString *)userUri
{
    return [self readUserPermission:ReporteeIsPunchIntoProjectsUser forUserWithUri:userUri];
}

- (BOOL)isReporteeProjectTaskSelectionRequired:(NSString *)userUri
{
    return [self readUserPermission:ReporteeProjectTaskSelectionRequired forUserWithUri:userUri];
}

- (BOOL)isReporteeActivitySelectionRequired:(NSString *)userUri
{
    return [self readUserPermission:ReporteeActivitySelectionRequired forUserWithUri:userUri];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (BOOL)readUserPermission:(NSString *)permissionName forUserWithUri:(NSString *)userUri
{
    NSDictionary *currentUserFilter = [self currentUserFilterForUserWithUri:userUri];
    NSDictionary *resultsDictionary = [self.sqliteStore readLastRowWithArgs:currentUserFilter];
    return [resultsDictionary[permissionName] boolValue];
}

- (NSDictionary *)currentUserFilterForUserWithUri:(NSString *)userUri
{
    return @{@"user_uri": userUri};
}

@end
