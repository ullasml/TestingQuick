#import "SingleTimesheetDeserializer.h"
#import "AstroUserDetector.h"
#import "Timesheet.h"
#import "AstroAwareTimesheet.h"
#import "Constants.h"
#import "UserPermissionsStorage.h"

@interface SingleTimesheetDeserializer ()

@property (nonatomic) AstroUserDetector *astroUserDetector;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@end


@implementation SingleTimesheetDeserializer

- (instancetype)initWithAstroUserDetector:(AstroUserDetector *)astroUserDetector
                    userPermissionStorage:(UserPermissionsStorage *)userPermissionStorage {
    self = [super init];
    if (self) {
        self.astroUserDetector = astroUserDetector;
        self.userPermissionsStorage = userPermissionStorage;
    }
    return self;
}

- (AstroAwareTimesheet *)deserialize:(NSDictionary *)timesheetDictionary
{
    NSDictionary *responseDictionary = timesheetDictionary[@"d"];
    NSDictionary *capabilitiesDictionary = responseDictionary[@"capabilities"];
    NSString *timesheetFormat = capabilitiesDictionary[@"timesheetFormat"];
    NSDictionary *approvalDetails = responseDictionary[@"approvalDetails"];
    NSDictionary *timesheet = approvalDetails[@"timesheet"];
    NSString *timesheetURI = timesheet[@"uri"];
    NSMutableDictionary *timePunchCapabilities = capabilitiesDictionary[@"timePunchCapabilities"];
    if (timePunchCapabilities!=nil && ![timePunchCapabilities isKindOfClass:[NSNull class]])
    {
        timePunchCapabilities=[capabilitiesDictionary[@"timePunchCapabilities"]mutableCopy];
        [timePunchCapabilities setObject:[timePunchCapabilities objectForKey:@"canViewTeamTimePunch"] forKey:@"hasTimePunchAccess"];
    }
    
    BOOL hasPayRollSymmary = NO;
    if (capabilitiesDictionary!=nil && ![capabilitiesDictionary isKindOfClass:[NSNull class]]) {
        NSArray *widgetTimesheetCapabilitiesArray = capabilitiesDictionary[@"widgetTimesheetCapabilities"];
        if (widgetTimesheetCapabilitiesArray!=nil && ![widgetTimesheetCapabilitiesArray isKindOfClass:[NSNull class]]) {
            for (int index = 0; index<[widgetTimesheetCapabilitiesArray count]; index++) {
                NSDictionary *widgetDict = [widgetTimesheetCapabilitiesArray objectAtIndex:index];
                if ([widgetDict[@"policyKeyUri"] isEqualToString:PAYSUMMARY_WIDGET_URI]) {
                    hasPayRollSymmary = widgetDict[@"policyValue"][@"bool"];
                }
            }
        }
    }

    BOOL isAstroUser = [self.astroUserDetector isAstroUserWithCapabilities:capabilitiesDictionary timePunchCapabilities:timePunchCapabilities isWidgetPlatformSupported:self.userPermissionsStorage.isWidgetPlatformSupported];
    TimesheetAstroUserType userType = isAstroUser ? TimesheetAstroUserTypeAstro : TimesheetAstroUserTypeNonAstro;

    return [[AstroAwareTimesheet alloc] initWithTimesheetAstroUserType:userType format:timesheetFormat uri:timesheetURI timesheetDictionary:timesheetDictionary hasPayRollSummary:hasPayRollSymmary];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
