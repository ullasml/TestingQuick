#import "DayTimeSummary.h"


@interface DayTimeSummary ()

@property (nonatomic) NSDateComponents *dateComponents;
@property (nonatomic) NSDateComponents *breakTimeComponents;
@property (nonatomic) NSDateComponents *regularTimeComponents;
@property (nonatomic) NSDateComponents *regularTimeOffsetComponents;
@property (nonatomic) NSDateComponents *breakTimeOffsetComponents;
@property (nonatomic) NSDateComponents *timeOffComponents;
@property (nonatomic) BOOL isScheduledDay;
@end


@implementation DayTimeSummary

- (instancetype)initWithRegularTimeOffsetComponents:(NSDateComponents *)regularTimeOffsetComponents
                          breakTimeOffsetComponents:(NSDateComponents *)breakTimeOffsetComponents
                              regularTimeComponents:(NSDateComponents *)regularTimeComponents
                                breakTimeComponents:(NSDateComponents *)breakTimeComponents
                                  timeOffComponents:(NSDateComponents *)timeOffComponents
                                     dateComponents:(NSDateComponents *)dateComponents
                                     isScheduledDay:(BOOL)isScheduledDay{
    self = [super init];
    if (self) {
        self.dateComponents = dateComponents;
        self.timeOffComponents = timeOffComponents;
        self.breakTimeComponents = breakTimeComponents;
        self.regularTimeComponents = regularTimeComponents;
        self.regularTimeOffsetComponents = regularTimeOffsetComponents;
        self.breakTimeOffsetComponents = breakTimeOffsetComponents;
        self.isScheduledDay = isScheduledDay;
    }
    return self;
}

- (BOOL)isEqual:(DayTimeSummary *)otherDayTimeSummary
{
    BOOL dateComponentsEqual = [self sameComponents:otherDayTimeSummary.dateComponents otherComponents:self.dateComponents];
    BOOL breakTimeComponentsEqual = [self sameComponents:otherDayTimeSummary.breakTimeComponents otherComponents:self.breakTimeComponents];
    BOOL regularTimeComponentsEqual = [self sameComponents:otherDayTimeSummary.regularTimeComponents otherComponents:self.regularTimeComponents];
    BOOL regularTimeOffsetComponentsEqual = [self sameComponents:otherDayTimeSummary.regularTimeOffsetComponents otherComponents:self.regularTimeOffsetComponents];
    BOOL breakTimeOffsetComponentsEqual = [self sameComponents:otherDayTimeSummary.breakTimeOffsetComponents otherComponents:self.breakTimeOffsetComponents];
    BOOL isScheduledDayEqual = (self.isScheduledDay == otherDayTimeSummary.isScheduledDay);
    return (dateComponentsEqual &&
            breakTimeComponentsEqual &&
            regularTimeComponentsEqual &&
            regularTimeOffsetComponentsEqual &&
            breakTimeOffsetComponentsEqual &&
            isScheduledDayEqual);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>: \n RegularTimeComponents: %@ \n BreakTimeComponents: %@\n RegularTimeOffsetComponents: %@\n BreakTimeOffsetComponents: %@ \n DateComponents: %@\n timeOffComponents: %@\n isScheduledDay: %d \n", NSStringFromClass([self class]),
            self.regularTimeComponents,
            self.breakTimeComponents,
            self.regularTimeOffsetComponents,
            self.breakTimeOffsetComponents,
            self.dateComponents,
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
    [coder encodeObject:self.timeOffComponents forKey:@"timeOffComponents"];
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
    BOOL isScheduledDay = [[decoder decodeObjectForKey:@"isScheduledDay"] boolValue];

    return [self initWithRegularTimeOffsetComponents:regularTimeOffsetComponents
                           breakTimeOffsetComponents:breakTimeOffsetComponents
                               regularTimeComponents:regularTimeComponents
                                 breakTimeComponents:breakTimeComponents
                                   timeOffComponents:timeOffComponents
                                      dateComponents:dateComponents
                                      isScheduledDay:isScheduledDay];
}


#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:[self.regularTimeOffsetComponents copy]
                                             breakTimeOffsetComponents:[self.breakTimeOffsetComponents copy]
                                                 regularTimeComponents:[self.regularTimeComponents copy]
                                                   breakTimeComponents:[self.breakTimeComponents copy]
                                                     timeOffComponents:[self.timeOffComponents copy]
                                                        dateComponents:[self.dateComponents copy]
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
