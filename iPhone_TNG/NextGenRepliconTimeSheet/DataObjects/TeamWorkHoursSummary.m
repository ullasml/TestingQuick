#import "TeamWorkHoursSummary.h"

@interface TeamWorkHoursSummary ()


@property (nonatomic) NSDateComponents *overtimeComponents;
@property (nonatomic) NSDateComponents *breakTimeComponents;
@property (nonatomic) NSDateComponents *regularTimeComponents;
@property (nonatomic) NSDateComponents *timeOffComponents;
@property (nonatomic) BOOL isScheduledDay;
@end

@implementation TeamWorkHoursSummary


- (instancetype)initWithOvertimeComponents:(NSDateComponents *)overtimeComponents
                     regularTimeComponents:(NSDateComponents *)regularTimeComponents
                       breakTimeComponents:(NSDateComponents *)breakTimeComponents
                         timeOffComponents:(NSDateComponents *)timeOffComponents
                            isScheduledDay:(BOOL)isScheduledDay{
    self = [super init];
    if (self) {
        self.timeOffComponents = timeOffComponents;
        self.overtimeComponents = overtimeComponents;
        self.breakTimeComponents = breakTimeComponents;
        self.regularTimeComponents = regularTimeComponents;
        self.isScheduledDay = isScheduledDay;
    }
    return self;
}


- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - NSObject

- (BOOL)isEqual:(TeamWorkHoursSummary *)otherTeamWorkHoursSummary
{
    BOOL typesAreEqual = [self isKindOfClass:[otherTeamWorkHoursSummary class]];
    if (!typesAreEqual) {
        return NO;
    }

    BOOL overtimeEqualOrBothNil = (!self.overtimeComponents && !otherTeamWorkHoursSummary.overtimeComponents) || ([self.overtimeComponents isEqual:otherTeamWorkHoursSummary.overtimeComponents]);
    BOOL breaktimeEqualOrBothNil = (!self.breakTimeComponents && !otherTeamWorkHoursSummary.breakTimeComponents) || ([self.breakTimeComponents isEqual:otherTeamWorkHoursSummary.breakTimeComponents]);
    BOOL regulartimeEqualOrBothNil = (!self.regularTimeComponents && !otherTeamWorkHoursSummary.regularTimeComponents) || ([self.regularTimeComponents isEqual:otherTeamWorkHoursSummary.regularTimeComponents]);
    BOOL timeOffEqualOrBothNil = (!self.timeOffComponents && !otherTeamWorkHoursSummary.timeOffComponents) || ([self.timeOffComponents isEqual:otherTeamWorkHoursSummary.timeOffComponents]);
    BOOL isScheduledDayEqual = (self.isScheduledDay == otherTeamWorkHoursSummary.isScheduledDay);
    return overtimeEqualOrBothNil && breaktimeEqualOrBothNil && regulartimeEqualOrBothNil && timeOffEqualOrBothNil && isScheduledDayEqual;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>:\n Overtime: %@ \n Regular: %@ \n Break:%@ \n TimeOff:%@ \n isScheduledDay: %d \n", NSStringFromClass([self class]),
            self.overtimeComponents,
            self.regularTimeComponents,
            self.breakTimeComponents,
            self.timeOffComponents,
            self.isScheduledDay];
}

@end
