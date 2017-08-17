#import "TabModuleNameProvider.h"
#import "Constants.h"
#import "AstroUserDetector.h"


@interface TabModuleNameProvider ()

@property (nonatomic) AstroUserDetector *astroUserDetector;

@end

@implementation TabModuleNameProvider

#pragma mark - NSObject

- (instancetype)initWithAstroUserDetector:(AstroUserDetector *)astroUserDetector
{
    self = [super init];
    if (self) {

        self.astroUserDetector = astroUserDetector;
    }
    return self;
}

- (NSArray *)tabModuleNamesWithHomeSummaryResponse:(NSDictionary *)homeSummaryResponse
                                       userDetails:(NSArray *)userDetails
                         isWidgetPlatformSupported:(BOOL)isWidgetPlatformSupported {
    NSDictionary *timePunchCapabilities = homeSummaryResponse[@"userSummary"][@"timePunchCapabilities"];
    BOOL canViewTimePunch  = [timePunchCapabilities[@"canViewTimePunch"] boolValue];
//TODO:Commenting below line because variable is unused,uncomment when using
//    BOOL canViewTeamTimePunch = [timePunchCapabilities[@"canViewTeamTimePunch"] boolValue];
    BOOL canAccessProject = [timePunchCapabilities[@"hasProjectAccess"] boolValue];
    BOOL canAccessClient = [timePunchCapabilities[@"hasClientAccess"] boolValue];
    BOOL hasActivityAccess = [timePunchCapabilities[@"hasActivityAccess"] boolValue];
    BOOL hasTimePunchAccess   = [timePunchCapabilities[@"hasTimePunchAccess"]boolValue];
    
    NSMutableArray *modulesOrderArray = [NSMutableArray array];
    if (userDetails!=nil && ![userDetails isKindOfClass:[NSNull class]] && userDetails.count > 0)
    {
        NSDictionary *userDetailsDict=[userDetails objectAtIndex:0];
        BOOL _hasTimesheetAccess        = [userDetailsDict[@"hasTimesheetAccess"]boolValue];
        BOOL _hasExpenseAccess          = [userDetailsDict[@"hasExpenseAccess"]boolValue];
        BOOL _userTimeOffApprover       = [userDetailsDict[@"isTimeOffApprover"]boolValue];
        BOOL _userTimesheetApprover     = [userDetailsDict[@"isTimesheetApprover"]boolValue];
        BOOL _userExpenseApprover       = [userDetailsDict[@"isExpenseApprover"]boolValue];
        BOOL _hasTimeoffBookingAccesss  = [userDetailsDict[@"hasTimeoffBookingAccess"]boolValue];
        BOOL _hasShiftsApprover         = [userDetailsDict[@"canViewShifts"]boolValue];
        BOOL _isAttendanceUser          = [userDetailsDict[@"hasPunchInOutAccess"]boolValue];
        BOOL _hasApprovalAccess         = NO;
        
        if (_userTimeOffApprover||_userTimesheetApprover||_userExpenseApprover)
        {
            _hasApprovalAccess=YES;
        }

        NSDictionary *userSummary = homeSummaryResponse[@"userSummary"];
        NSDictionary *timePunchCapabilities = userSummary[@"timePunchCapabilities"];
        NSDictionary * capabilities = userSummary[@"timesheetCapabilities"][@"currentCapabilities"];
        
        BOOL isAstroUser = [self.astroUserDetector isAstroUserWithCapabilities:capabilities timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:isWidgetPlatformSupported];
        
        if (_hasTimesheetAccess)
        {
            [modulesOrderArray addObject:TIMESHEETS_TAB_MODULE_NAME];
        }

        if (_isAttendanceUser)
        {
            if (isAstroUser)
            {
                BOOL _hasCustomFields = NO;
                NSDictionary *customFields = timePunchCapabilities[@"timePunchExtensionFields"];
                if ([customFields isKindOfClass:[NSNull class]]) {
                    _hasCustomFields = NO;
                }

                NSArray *customFieldValues = [customFields allValues];
                for (NSArray *extensionFieldValues in customFieldValues) {
                    if (extensionFieldValues.count > 0)
                    {
                        _hasCustomFields = YES;
                    }
                    else if (extensionFieldValues.count > 0)
                    {
                        _hasCustomFields = NO;
                    }
                }

                [modulesOrderArray removeObject:TIMESHEETS_TAB_MODULE_NAME];
                if (canAccessClient && canAccessProject && hasActivityAccess)
                {
                    [modulesOrderArray addObject:WRONG_CONFIGURATION_MODULE_NAME];
                }

                else if (canAccessClient || canAccessProject)
                {
                    [modulesOrderArray addObject:PUNCH_IN_PROJECT_MODULE_NAME];
                }
                else if (hasActivityAccess)
                {
                    [modulesOrderArray addObject:PUNCH_INTO_ACTIVITIES_MODULE_NAME];
                }
                else if(_hasCustomFields)
                {
                     [modulesOrderArray addObject:PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME];
                }
                else
                {
                    [modulesOrderArray addObject:NEW_PUNCH_WIDGET_MODULE_NAME];
                }

            }
            else
            {
                if (canAccessProject)
                {
                    [modulesOrderArray addObject:WRONG_CONFIGURATION_MODULE_NAME];
                }
                else
                {
                    if(hasTimePunchAccess){
                        [modulesOrderArray addObject:CLOCK_IN_OUT_TAB_MODULE_NAME];
                    }
                }

                if (canViewTimePunch)
                {
                    [modulesOrderArray addObject:PUNCH_HISTORY_TAB_MODULE_NAME];
                }
            }

        }
        else if (isWidgetPlatformSupported && isAstroUser && _hasTimesheetAccess)
        {
            
            [modulesOrderArray removeObject:TIMESHEETS_TAB_MODULE_NAME];
            [modulesOrderArray addObject:NEW_PUNCH_WIDGET_MODULE_NAME];
            
        }

        if (_hasTimeoffBookingAccesss)
        {

            [modulesOrderArray addObject:TIME_OFF_TAB_MODULE_NAME];
        }
        if (_hasShiftsApprover)
        {
            [modulesOrderArray addObject:SCHEDULE_TAB_MODULE_NAME];
        }

        if (_hasExpenseAccess)
        {

            [modulesOrderArray addObject:EXPENSES_TAB_MODULE_NAME];
        }
        if (_hasApprovalAccess)
        {

            [modulesOrderArray addObject:APPROVAL_TAB_MODULE_NAME];
            
        }
        
        [modulesOrderArray addObject:SETTINGS_TAB_MODULE_NAME];
    }

    return modulesOrderArray;
}

@end
