#import "UserPermissionsStorage.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"


@interface UserPermissionsStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;
@property (nonatomic) id<UserSession> userSession;

@end


static NSString *const UserPermissionsGeolocationRequired               = @"geolocation_required";
static NSString *const UserPermissionsCanEditTimePunch                  = @"can_edit_time_punch";
static NSString *const UserPermissionsIsAstroPunchUser                  = @"is_astro_punch_user";
static NSString *const UserPermissionsBreaksRequired                    = @"breaks_required";
static NSString *const UserPermissionsSelfieRequired                    = @"selfie_required";
static NSString *const UserPermissionsCanViewPayDetails                 = @"can_view_pay_details";
static NSString *const UserPermissionsCanApproveTimesheets              = @"can_approve_timesheets";
static NSString *const UserPermissionsCanApproveExpenses                = @"can_approve_expenses";
static NSString *const UserPermissionsCanApproveTimeoffs                = @"can_approve_timeoffs";
static NSString *const UserPermissionsCanViewTeamPunch                  = @"can_view_team_punch";
static NSString *const UserPermissionsHasProjectAccess                  = @"project_access";
static NSString *const UserPermissionsHasClientAccess                   = @"client_access";
static NSString *const UserPermissionsHasActivityAccess                 = @"activity_access";
static NSString *const UserPermissionsProjectTaskSelectionRequired      = @"project_task_selection_required";
static NSString *const UserPermissionsHasTimesheetAccess                = @"has_Timesheet_Access";
static NSString *const UserPermissionsCanEditNonTimeFields              = @"canEditNonTimeFields";
static NSString *const UserPermissionsIsExpensesProjectMandatory        = @"isExpensesProjectMandatory";
static NSString *const UserPermissionsActivitySelectionRequired         = @"activity_selection_required";
static NSString *const UserPermissionsHasTimePunchAccess                = @"hasTimePunchAccess";
static NSString *const UserPermissionsCanViewTeamTimesheet              = @"canViewTeamTimesheet";
static NSString *const UserPermissionsIsSimpleInOutWidget               = @"isSimpleInOutWidget";
static NSString *const UserPermissionsCanEditTimesheet                  = @"can_edit_timesheet";
static NSString *const UserPermissionsCanEditTeamTimePunch              = @"can_edit_team_time_punch";
static NSString *const UserPermissionsIsWidgetPlatformSupported         = @"isWidgetPlatformSupported";
static NSString *const UserPermissionsHasManualTimePunchAccess          = @"hasManualTimePunchAccess";

@implementation UserPermissionsStorage

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

- (void)persistIsExpensesProjectMandatory:(NSNumber *)isExpensesProjectMandatory
                isWidgetPlatformSupported:(NSNumber *)isWidgetPlatformSupported
                     canApproveTimesheets:(NSNumber *)canApproveTimesheets
                     canEditNonTimeFields:(NSNumber *)canEditNonTimeFields
                      geolocationRequired:(NSNumber *)geolocationRequired
                       canApproveExpenses:(NSNumber *)canApproveExpenses
                       canApproveTimeoffs:(NSNumber *)canApproveTimeoffs
                      isActivityMandatory:(NSNumber *)isActivityMandatory
                       isProjectMandatory:(NSNumber *)isProjectMandatory
                       hasTimesheetAccess:(NSNumber *)hasTimesheetAccess
                        hasActivityAccess:(NSNumber *)hasActivityAccess
                         hasProjectAccess:(NSNumber *)hasProjectAccess
                          hasClientAccess:(NSNumber *)hasClientAccess
                         canEditTimePunch:(NSNumber *)canEditTimePunch
                         isAstroPunchUser:(NSNumber *)isAstroPunchUser
                        canViewPayDetails:(NSNumber *)canViewPayDetails
                         canViewTeamPunch:(NSNumber *)canViewTeamPunch
                           breaksRequired:(NSNumber *)breaksRequired
                           selfieRequired:(NSNumber *)selfieRequired
                       hasTimePunchAccess:(NSNumber *)hasTimePunchAccess
                     canViewTeamTimesheet:(NSNumber *)canViewTeamTimesheet
                         canEditTimesheet:(NSNumber *)canEditTimesheet
                     canEditTeamTimePunch:(NSNumber *)canEditTeamTimePunch 
                      isSimpleInOutWidget:(NSNumber *)isSimpleInOutWidget
                 hasManualTimePunchAccess:(NSNumber *)hasManualTimePunchAccess{
    NSMutableDictionary *userPermissionsDictionary = [@{
                                                        UserPermissionsGeolocationRequired: geolocationRequired,
                                                        UserPermissionsCanEditTimePunch: canEditTimePunch,
                                                        UserPermissionsIsAstroPunchUser: isAstroPunchUser,
                                                        UserPermissionsBreaksRequired: breaksRequired,
                                                        UserPermissionsSelfieRequired: selfieRequired,
                                                        UserPermissionsCanViewPayDetails: canViewPayDetails,
                                                        UserPermissionsCanApproveTimesheets:canApproveTimesheets,
                                                        UserPermissionsCanApproveExpenses:canApproveExpenses,
                                                        UserPermissionsCanApproveTimeoffs:canApproveTimeoffs,
                                                        UserPermissionsCanViewTeamPunch:canViewTeamPunch,
                                                        UserPermissionsHasProjectAccess: hasProjectAccess,
                                                        UserPermissionsHasClientAccess: hasClientAccess,
                                                        UserPermissionsHasActivityAccess: hasActivityAccess,
                                                        UserPermissionsActivitySelectionRequired : isActivityMandatory,
                                                        UserPermissionsProjectTaskSelectionRequired:isProjectMandatory,
                                                        UserPermissionsHasTimesheetAccess:hasTimesheetAccess,
                                                        UserPermissionsCanEditNonTimeFields:canEditNonTimeFields,
                                                        UserPermissionsIsExpensesProjectMandatory:isExpensesProjectMandatory,
                                                        UserPermissionsHasTimePunchAccess:hasTimePunchAccess,
                                                        UserPermissionsCanViewTeamTimesheet:canViewTeamTimesheet,
                                                        UserPermissionsCanEditTimesheet:canEditTimesheet,
                                                        UserPermissionsCanEditTeamTimePunch:canEditTeamTimePunch,
                                                        UserPermissionsIsSimpleInOutWidget:isSimpleInOutWidget,
                                                        UserPermissionsIsWidgetPlatformSupported:isWidgetPlatformSupported,
                                                        UserPermissionsHasManualTimePunchAccess:hasManualTimePunchAccess
                                                        } mutableCopy];
    [userPermissionsDictionary addEntriesFromDictionary:[self currentUserFilter]];

    NSDictionary *currentUserFilter = [self currentUserFilter];
    NSDictionary *resultSet = [self.sqliteStore readLastRowWithArgs:currentUserFilter];
    if (resultSet) {
        [self.sqliteStore updateRow:userPermissionsDictionary whereClause:nil];
    } else {
        [self.sqliteStore insertRow:userPermissionsDictionary];
    }
}

- (BOOL)geolocationRequired
{
    return [self readUserPermission:UserPermissionsGeolocationRequired];
}

- (BOOL)breaksRequired
{
    return [self readUserPermission:UserPermissionsBreaksRequired];
}

- (BOOL)selfieRequired
{
    return [self readUserPermission:UserPermissionsSelfieRequired];
}

- (BOOL)canEditTimePunch
{
    return [self readUserPermission:UserPermissionsCanEditTimePunch];
}

- (BOOL)isAstroPunchUser
{
    return [self readUserPermission:UserPermissionsIsAstroPunchUser];
}

- (BOOL)canViewPayDetails
{
    return [self readUserPermission:UserPermissionsCanViewPayDetails];
}

- (BOOL)canApproveTimesheets
{
    return [self readUserPermission:UserPermissionsCanApproveTimesheets];
}

- (BOOL)canApproveExpenses
{
    return [self readUserPermission:UserPermissionsCanApproveExpenses];
}

- (BOOL)canApproveTimeoffs
{
    return [self readUserPermission:UserPermissionsCanApproveTimeoffs];
}

- (BOOL)canViewTeamPunch
{
    return [self readUserPermission:UserPermissionsCanViewTeamPunch];
}

- (BOOL)hasProjectAccess
{
    return [self readUserPermission:UserPermissionsHasProjectAccess];
}

- (BOOL)hasClientAccess
{
    return [self readUserPermission:UserPermissionsHasClientAccess];
}

- (BOOL)isProjectTaskSelectionRequired
{
    return [self readUserPermission:UserPermissionsProjectTaskSelectionRequired];
}

- (BOOL)hasTimesheetAccess
{
    return [self readUserPermission:UserPermissionsHasTimesheetAccess];
}

- (BOOL)canEditNonTimeFields
{
    return [self readUserPermission:UserPermissionsCanEditNonTimeFields];
}
                                                
- (BOOL)isExpensesProjectMandatory
{
    return [self readUserPermission:UserPermissionsIsExpensesProjectMandatory];
}

- (BOOL)hasActivityAccess
{
    return [self readUserPermission:UserPermissionsHasActivityAccess];
}

- (BOOL)isActivitySelectionRequired
{
    return [self readUserPermission:UserPermissionsActivitySelectionRequired];
}

- (BOOL)hasTimePunchAccess
{
    return [self readUserPermission:UserPermissionsHasTimePunchAccess];
}

- (BOOL)canViewTeamTimesheet
{
    return [self readUserPermission:UserPermissionsCanViewTeamTimesheet];
}

- (BOOL)isSimpleInOutWidget
{
    return [self readUserPermission:UserPermissionsIsSimpleInOutWidget];
}

- (BOOL)canEditTimesheet
{
    return [self readUserPermission:UserPermissionsCanEditTimesheet];
}

- (BOOL)canEditTeamTimePunch
{
    return [self readUserPermission:UserPermissionsCanEditTeamTimePunch];
}

- (BOOL)isWidgetPlatformSupported
{
    return [self readUserPermission:UserPermissionsIsWidgetPlatformSupported];
}
- (BOOL)hasManualTimePunchAccess
{
    return [self readUserPermission:UserPermissionsHasManualTimePunchAccess];
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (BOOL)readUserPermission:(NSString *)permissionName
{
    NSDictionary *currentUserFilter = [self currentUserFilter];
    NSDictionary *resultsDictionary = [self.sqliteStore readLastRowWithArgs:currentUserFilter];
    id permissionValue = resultsDictionary[permissionName];
    if (permissionValue != nil && ![permissionValue  isKindOfClass:[NSNull class]]) {
        return [resultsDictionary[permissionName] boolValue];
    }
    return NO;
}

- (NSDictionary *)currentUserFilter
{
    CLS_LOG(@"-------userSession === %d---------",[self.userSession validUserSession]);
    return @{@"user_uri": [self.userSession currentUserURI]};
}

@end
