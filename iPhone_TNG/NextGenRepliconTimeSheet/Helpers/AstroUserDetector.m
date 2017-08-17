#import "AstroUserDetector.h"

static NSString * const AstroPunchWidgetPolicyURI = @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry";
static NSString * const AstroPayrollWidgetPolicyURI = @"urn:replicon:policy:timesheet:widget-timesheet:payroll-summary";
static NSString * const AstroNoticeWidgetPolicyURI = @"urn:replicon:policy:timesheet:widget-timesheet:notice";
static NSString * const AstroAttestationWidgetPolicyURI = @"urn:replicon:policy:timesheet:widget-timesheet:attestation";
static NSString * const AstroTimeDistributionWidgetPolicyURI = @"urn:replicon:policy:timesheet:widget-timesheet:allocation-entry";

@implementation AstroUserDetector

- (BOOL)isAstroUserWithCapabilities:(NSDictionary *)capabilities
              timePunchCapabilities:(NSDictionary *)timePunchCapabilities
          isWidgetPlatformSupported:(BOOL)isWidgetPlatformSupported {

    NSArray *widgetTimesheetCapabilities = capabilities[@"widgetTimesheetCapabilities"];

    if ([widgetTimesheetCapabilities isEqual:(id)[NSNull null]] &&
        [timePunchCapabilities isEqual:(id)[NSNull null]]) {

        return NO;
    }
    else if ([widgetTimesheetCapabilities isEqual:(id)[NSNull null]] && timePunchCapabilities){

        return [self isAstroConfiguredUserForTimePunchCapabilities:timePunchCapabilities];
    }
    else
    {
        BOOL isAstro = [self isAstroConfiguredUserForWidgetCapabilities:widgetTimesheetCapabilities];
        if (isAstro) {
            return [self isAstroConfiguredUserForTimePunchCapabilities:timePunchCapabilities];
        }
        else
        {
            return [self isWidgetsConfiguredWithPunchToProjectsOrActivities:timePunchCapabilities widgetTimesheetCapabilities:widgetTimesheetCapabilities isWidgetPlatformSupported:isWidgetPlatformSupported];
        }

    }

    return NO;

}

#pragma mark - Private

-(BOOL)isAstroConfiguredUserForTimePunchCapabilities:(NSDictionary *)timePunchCapabilities
{
    if ([timePunchCapabilities isKindOfClass:[NSNull class]]) {
        return NO;
    }

    BOOL hasTimePunchAccess = [timePunchCapabilities[@"hasTimePunchAccess"] boolValue];
    if (!hasTimePunchAccess) {
        BOOL hasManualTimePunchAccess = [timePunchCapabilities[@"hasManualTimePunchAccess"] boolValue];
        if(hasManualTimePunchAccess){
            return YES;
        }
        return NO;

    }
    BOOL hasProjectAccess = [timePunchCapabilities[@"hasProjectAccess"] boolValue];
    BOOL hasClientAccess = [timePunchCapabilities[@"hasClientAccess"] boolValue];
    BOOL hasActivityAccess = [timePunchCapabilities[@"hasActivityAccess"] boolValue];
    if (hasActivityAccess && hasClientAccess && hasProjectAccess) {
        return YES;
    }

    NSDictionary *customFields = timePunchCapabilities[@"timePunchExtensionFields"];
    if ([customFields isKindOfClass:[NSNull class]]) {
        return YES;
    }

    NSArray *customFieldValues = [customFields allValues];
    for (NSArray *extensionFieldValues in customFieldValues) {
        if (extensionFieldValues.count > 0)
        {
            return YES;
        }

    }

    return YES;
}

-(BOOL)isWidgetsConfiguredWithPunchToProjectsOrActivities:(NSDictionary *)timePunchCapabilities widgetTimesheetCapabilities:(NSArray *)widgetTimesheetCapabilities isWidgetPlatformSupported:(BOOL)isWidgetPlatformSupported
{
    if ([timePunchCapabilities isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    BOOL hasProjectAccess = [timePunchCapabilities[@"hasProjectAccess"] boolValue];
    BOOL hasClientAccess = [timePunchCapabilities[@"hasClientAccess"] boolValue];
    BOOL hasActivityAccess = [timePunchCapabilities[@"hasActivityAccess"] boolValue];
    if (hasActivityAccess)
    {
        BOOL hasOEF = [self hasOEFConfigured:timePunchCapabilities];

        if (hasOEF)
        {
            return YES;
        }
        
        if (isWidgetPlatformSupported) {
            return YES;
        }
        else
        {
            BOOL isAstroConfiguredUserNoticeOrAttestationWidget = [self isAstroConfiguredUserNoticeOrAttestationWidget:widgetTimesheetCapabilities];
            
            if (isAstroConfiguredUserNoticeOrAttestationWidget)
            {
                return NO;
            }
            else
            {
                return YES;
            }
        }

    }
    else if(hasClientAccess && hasProjectAccess)
    {
        return YES;
    }
    else
    {
        BOOL hasOEF = [self hasOEFConfigured:timePunchCapabilities];

        if (hasOEF)
        {
            return YES;
        }

        BOOL isAstroConfiguredUserNoticeOrAttestationOrTimeDistributionWidget = [self isAstroConfiguredUserNoticeOrAttestationWidgetorTimeDistributionWidget:widgetTimesheetCapabilities isWidgetPlatformSupported:isWidgetPlatformSupported];

        if (isAstroConfiguredUserNoticeOrAttestationOrTimeDistributionWidget)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return NO;
}


-(BOOL)isAstroConfiguredUserForWidgetCapabilities:(NSArray *)widgetTimesheetCapabilities
{
    BOOL isAnyWidgetEnabled = NO;
    for (NSDictionary *nextCapability in widgetTimesheetCapabilities) {

        NSString *policyKeyUri = nextCapability[@"policyKeyUri"];
        NSDictionary * policy = nextCapability[@"policyValue"];
        BOOL policyBool = [policy[@"bool"] boolValue];
        if (policyBool)
        {
            isAnyWidgetEnabled = YES;
            if (![policyKeyUri isEqualToString:AstroPayrollWidgetPolicyURI] &&
                ![policyKeyUri isEqualToString:AstroPunchWidgetPolicyURI]) {
                return NO;
            }
        }
    }

    if (!isAnyWidgetEnabled) {
        return NO;
    }
    
    
    return YES;
}

-(BOOL)isAstroConfiguredUserNoticeOrAttestationWidget:(NSArray *)widgetTimesheetCapabilities
{
    BOOL isNoticeAttestationWidgetEnabled = NO;
    for (NSDictionary *nextCapability in widgetTimesheetCapabilities) {

        NSString *policyKeyUri = nextCapability[@"policyKeyUri"];
        NSDictionary * policy = nextCapability[@"policyValue"];
        BOOL policyBool = [policy[@"bool"] boolValue];
        if (policyBool)
        {
            if ([policyKeyUri isEqualToString:AstroNoticeWidgetPolicyURI] ||
                [policyKeyUri isEqualToString:AstroAttestationWidgetPolicyURI]) {
                return YES;
            }
        }
    }

    return isNoticeAttestationWidgetEnabled;
}

-(BOOL)isAstroConfiguredUserNoticeOrAttestationWidgetorTimeDistributionWidget:(NSArray *)widgetTimesheetCapabilities isWidgetPlatformSupported:(BOOL)isWidgetPlatformSupported
{
    BOOL isNoticeAttestationWidgetEnabled = NO;
    for (NSDictionary *nextCapability in widgetTimesheetCapabilities) {

        NSString *policyKeyUri = nextCapability[@"policyKeyUri"];
        NSDictionary * policy = nextCapability[@"policyValue"];
        BOOL policyBool = [policy[@"bool"] boolValue];
        if (policyBool)
        {
            if (!isWidgetPlatformSupported)
            {
                if ([policyKeyUri isEqualToString:AstroNoticeWidgetPolicyURI] ||
                    [policyKeyUri isEqualToString:AstroAttestationWidgetPolicyURI] ||
                    [policyKeyUri isEqualToString:AstroTimeDistributionWidgetPolicyURI]) {
                    return YES;
                }
            }
           
            else
            {
                if ([policyKeyUri isEqualToString:AstroTimeDistributionWidgetPolicyURI]) {
                    return YES;
                }
            }
        }
    }

    return isNoticeAttestationWidgetEnabled;
}

-(BOOL)hasOEFConfigured:(NSDictionary *)timePunchCapabilities
{
    NSDictionary *customFields = timePunchCapabilities[@"timePunchExtensionFields"];
    if (![customFields isKindOfClass:[NSNull class]])
    {
        NSArray *customFieldValues = [customFields allValues];
        for (NSArray *extensionFieldValues in customFieldValues) {
            if (extensionFieldValues.count > 0)
            {
                return YES;
            }

        }
    }

    return NO;
}

@end
