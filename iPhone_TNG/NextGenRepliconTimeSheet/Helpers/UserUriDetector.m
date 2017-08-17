
#import "UserUriDetector.h"

typedef NS_ENUM(NSInteger, TimesheetFormat)
{
    Standard=0,
    Inout=1,
    Widget_Inout=2,
    Widget_Punch=3,
    UnknownType
};

@implementation UserUriDetector

- (NSString *)userUriFromTimesheetLoad:(NSDictionary *)timesheetDictionary
{
    NSDictionary *responseDictionary = timesheetDictionary[@"d"];
    TimesheetFormat timesheetFormat = [self timesheetFormatForTimesheetWithDetails:responseDictionary];

    switch (timesheetFormat) {
        case Inout:
            return [self userUriFromInoutTimesheetLoad:responseDictionary];
            break;
        case Standard:
            return [self userUriFromStandardTimesheetLoad:responseDictionary];
            break;
        case Widget_Inout:
            return [self userUriFromWidgetInoutTimesheetLoad:responseDictionary];
            break;
        case Widget_Punch:
            return [self userUriFromWidgetPunchTimesheetLoad:responseDictionary];
            break;

        default:
            break;
    }
    return nil;
}

#pragma mark - Private

-(TimesheetFormat)timesheetFormatForTimesheetWithDetails:(NSDictionary *)timesheetDictionary
{
    BOOL widgetInoutTimesheetDetailsPresent = NO;
    BOOL widgetPunchTimesheetDetailsPresent = NO;
    NSDictionary *inOutTimesheetInfo = timesheetDictionary[@"inOutTimesheetDetails"];
    NSDictionary *standardTimesheetInfo = timesheetDictionary[@"standardTimesheetDetails"];
    NSDictionary *widgetTimesheetDetails = timesheetDictionary[@"widgetTimesheetDetails"];
    if ([self isNonEmptyDictionary:widgetTimesheetDetails]) {
        NSArray *widgetInoutTimesheetinfo = widgetTimesheetDetails[@"timeEntries"];
        NSDictionary *widgetPunchTimesheetInfo = widgetTimesheetDetails[@"timePunchTimeSegmentDetails"];
         widgetInoutTimesheetDetailsPresent = [self isNonEmptyArray:widgetInoutTimesheetinfo];
         widgetPunchTimesheetDetailsPresent = [self isNonEmptyDictionary:widgetPunchTimesheetInfo];
    }

    BOOL inOutTimesheetDetailsPresent = [self isNonEmptyDictionary:inOutTimesheetInfo];
    BOOL standardTimesheetDetailsPresent = [self isNonEmptyDictionary:standardTimesheetInfo];


    if (inOutTimesheetDetailsPresent)
        return Inout;

    else if (standardTimesheetDetailsPresent)
        return Standard;

    else if (widgetInoutTimesheetDetailsPresent)
        return Widget_Inout;

    else if (widgetPunchTimesheetDetailsPresent)
        return Widget_Punch;

    return UnknownType;

}

-(BOOL)isNonEmptyDictionary:(NSDictionary *)dictionary
{
    return (dictionary!=nil && ![dictionary isKindOfClass:[NSNull class]] && [dictionary allKeys].count > 0 );
}

-(BOOL)isNonEmptyArray:(NSArray *)array
{
    return (array!=nil && ![array isKindOfClass:[NSNull class]] && array.count > 0 );
}

-(NSString *)userUriFromStandardTimesheetLoad:(NSDictionary *)timesheetDictionary
{
    NSDictionary *standardTimesheetDetails = timesheetDictionary[@"standardTimesheetDetails"];
     NSDictionary *timesheetOwner = standardTimesheetDetails[@"owner"];
    return timesheetOwner[@"uri"];

}

-(NSString *)userUriFromInoutTimesheetLoad:(NSDictionary *)timesheetDictionary
{
    NSDictionary *inOutTimesheetDetails = timesheetDictionary[@"inOutTimesheetDetails"];
    NSDictionary *timesheetOwner = inOutTimesheetDetails[@"owner"];
    return timesheetOwner[@"uri"];
}

-(NSString *)userUriFromWidgetInoutTimesheetLoad:(NSDictionary *)timesheetDictionary
{
    NSDictionary *widgetTimesheetDetails = timesheetDictionary[@"widgetTimesheetDetails"];
    NSArray *widgetInoutTimesheetDetails = widgetTimesheetDetails[@"timeEntries"];
    if (widgetInoutTimesheetDetails != nil && widgetInoutTimesheetDetails.count > 0) {
        NSDictionary *rowInfo = widgetInoutTimesheetDetails.firstObject;
        NSDictionary *timesheetOwner = rowInfo[@"user"];
        return timesheetOwner[@"uri"];
    }
    return nil;

}

-(NSString *)userUriFromWidgetPunchTimesheetLoad:(NSDictionary *)timesheetDictionary
{
    NSDictionary *widgetTimesheetDetails = timesheetDictionary[@"widgetTimesheetDetails"];
    NSDictionary *widgetPunchTimesheetDetails = widgetTimesheetDetails[@"timePunchTimeSegmentDetails"];
    NSDictionary *timesheetOwner = widgetPunchTimesheetDetails[@"user"];
    return timesheetOwner[@"uri"];
}
@end
