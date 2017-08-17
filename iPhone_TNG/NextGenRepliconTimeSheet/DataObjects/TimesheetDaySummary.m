
#import "TimesheetDaySummary.h"

@interface TimesheetDaySummary ()

@property (nonatomic) NSDateComponents *dateComponents;
@property (nonatomic) NSDateComponents *breakTimeComponents;
@property (nonatomic) NSDateComponents *regularTimeComponents;
@property (nonatomic) NSDateComponents *timeOffComponents;
@property (nonatomic) NSDateComponents *regularTimeOffsetComponents;
@property (nonatomic) NSDateComponents *breakTimeOffsetComponents;
@property (nonatomic) NSInteger totalViolationMessageCount;
@property (nonatomic) NSArray *punchesForDay;
@property (nonatomic) BOOL isScheduledDay;
@end


@implementation TimesheetDaySummary

- (instancetype)initWithRegularTimeOffsetComponents:(NSDateComponents *)regularTimeOffsetComponents
                          breakTimeOffsetComponents:(NSDateComponents *)breakTimeOffsetComponents
                              regularTimeComponents:(NSDateComponents *)regularTimeComponents
                         totalViolationMessageCount:(NSInteger)totalViolationMessageCount
                                breakTimeComponents:(NSDateComponents *)breakTimeComponents
                                  timeOffComponents:(NSDateComponents *)timeOffComponents
                                     dateComponents:(NSDateComponents *)dateComponents
                                      punchesForDay:(NSArray *)punchesForDay
                                     isScheduledDay:(BOOL)isScheduledDay{
    self = [super init];
    if (self) {
        self.punchesForDay = punchesForDay;
        self.dateComponents = dateComponents;
        self.timeOffComponents = timeOffComponents;
        self.breakTimeComponents = breakTimeComponents;
        self.regularTimeComponents = regularTimeComponents;
        self.regularTimeOffsetComponents = regularTimeOffsetComponents;
        self.breakTimeOffsetComponents = breakTimeOffsetComponents;
        self.totalViolationMessageCount =  totalViolationMessageCount;
        self.isScheduledDay = isScheduledDay;
    }
    return self;
}

- (BOOL)isEqual:(TimesheetDaySummary *)otherDayTimeSummary
{
    BOOL dateComponentsEqual = [self sameComponents:otherDayTimeSummary.dateComponents otherComponents:self.dateComponents];
    BOOL breakTimeComponentsEqual = [self sameComponents:otherDayTimeSummary.breakTimeComponents otherComponents:self.breakTimeComponents];
    BOOL regularTimeComponentsEqual = [self sameComponents:otherDayTimeSummary.regularTimeComponents otherComponents:self.regularTimeComponents];
    BOOL regularTimeOffsetComponentsEqual = [self sameComponents:otherDayTimeSummary.regularTimeOffsetComponents otherComponents:self.regularTimeOffsetComponents];
    BOOL breakTimeOffsetComponentsEqual = [self sameComponents:otherDayTimeSummary.breakTimeOffsetComponents otherComponents:self.breakTimeOffsetComponents];
    BOOL timeOffComponentsEqual = [self sameComponents:otherDayTimeSummary.timeOffComponents otherComponents:self.timeOffComponents];
    BOOL punchesForDayEqual = (!self.punchesForDay && !otherDayTimeSummary.punchesForDay) || ([self.punchesForDay isEqualToArray:otherDayTimeSummary.punchesForDay]);
    BOOL totalViolationMessageCountEqual = self.totalViolationMessageCount == otherDayTimeSummary.totalViolationMessageCount;
    BOOL isScheduledDayEqual = (self.isScheduledDay == otherDayTimeSummary.isScheduledDay);

    return (dateComponentsEqual &&
            breakTimeComponentsEqual &&
            regularTimeComponentsEqual &&
            regularTimeOffsetComponentsEqual &&
            breakTimeOffsetComponentsEqual &&
            timeOffComponentsEqual &&
            punchesForDayEqual &&
            totalViolationMessageCountEqual  &&
            isScheduledDayEqual);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>: \r RegularTimeComponents: %@ \r BreakTimeComponents: %@\r RegularTimeOffsetComponents: %@ \r BreakTimeOffsetComponents: %@ \r DateComponents: %@\r TotalViolationMessageCount: %ld \r punchesForDay: %@\r timeOffComponents: %@ \r isScheduledDay: %d \r", NSStringFromClass([self class]),
            self.regularTimeComponents,
            self.breakTimeComponents,
            self.regularTimeOffsetComponents,
            self.breakTimeOffsetComponents,
            self.dateComponents,
            self.totalViolationMessageCount,
            self.punchesForDay,
            self.timeOffComponents,
            self.isScheduledDay];
}

#pragma mark - <NSCoding>

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.regularTimeComponents forKey:@"regularTimeComponents"];
    [coder encodeObject:self.breakTimeComponents forKey:@"breakTimeComponents"];
    [coder encodeObject:self.regularTimeOffsetComponents forKey:@"regularTimeOffsetComponents"];
    [coder encodeObject:self.breakTimeOffsetComponents forKey:@"breakTimeOffsetComponents"];
    [coder encodeObject:self.dateComponents forKey:@"dateComponents"];
    [coder encodeObject:self.punchesForDay forKey:@"punchesForDay"];
    [coder encodeObject:self.timeOffComponents forKey:@"timeOffComponents"];
    [coder encodeObject:[NSNumber numberWithInteger:self.totalViolationMessageCount] forKey:@"totalViolationMessageCount"];
    [coder encodeObject:[NSNumber numberWithBool:self.isScheduledDay] forKey:@"isScheduledDay"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    NSDateComponents *regularTimeComponents = [decoder decodeObjectForKey:@"regularTimeComponents"];
    NSDateComponents *breakTimeComponents = [decoder decodeObjectForKey:@"breakTimeComponents"];
    NSDateComponents *regularTimeOffsetComponents = [decoder decodeObjectForKey:@"regularTimeOffsetComponents"];
    NSDateComponents *breakTimeOffsetComponents = [decoder decodeObjectForKey:@"breakTimeOffsetComponents"];
    NSDateComponents *dateComponents = [decoder decodeObjectForKey:@"dateComponents"];
    NSDateComponents *timeOffComponents = [decoder decodeObjectForKey:@"timeOffComponents"];
    NSInteger totalViolationMessageCount = [decoder decodeInt32ForKey:@"totalViolationMessageCount"];
    NSMutableArray *punchesForDay = [decoder decodeObjectForKey:@"punchesForDay"];
    BOOL isScheduledDay = [[decoder decodeObjectForKey:@"isScheduledDay"] boolValue];
    
    return [self initWithRegularTimeOffsetComponents:regularTimeOffsetComponents
                           breakTimeOffsetComponents:breakTimeOffsetComponents
                               regularTimeComponents:regularTimeComponents
                          totalViolationMessageCount:totalViolationMessageCount
                                 breakTimeComponents:breakTimeComponents
                                   timeOffComponents:timeOffComponents
                                      dateComponents:dateComponents
                                       punchesForDay:punchesForDay
                                      isScheduledDay:isScheduledDay];
}


#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return [[TimesheetDaySummary alloc] initWithRegularTimeOffsetComponents:[self.regularTimeOffsetComponents copy]
                                                  breakTimeOffsetComponents:[self.breakTimeOffsetComponents copy]
                                                      regularTimeComponents:[self.regularTimeComponents copy]
                                                 totalViolationMessageCount:self.totalViolationMessageCount
                                                        breakTimeComponents:[self.breakTimeComponents copy]
                                                          timeOffComponents:[self.timeOffComponents copy]
                                                             dateComponents:[self.dateComponents copy]
                                                               punchesForDay:[self.punchesForDay copy]
                                                              isScheduledDay:self.isScheduledDay];
             
    
}

-(BOOL)sameComponents:(NSDateComponents *)components otherComponents:(NSDateComponents *)otherComponents
{
    BOOL dayComponentsEqual = (components.day == otherComponents.day);
    BOOL monthComponentsEqual = (components.month == otherComponents.month);
    BOOL yearComponentsEqual = (components.year == otherComponents.year);
    return  dayComponentsEqual && monthComponentsEqual && yearComponentsEqual ;
}

@end
