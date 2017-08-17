#import "TimesheetPeriod.h"


@interface TimesheetPeriod ()

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

@end


@implementation TimesheetPeriod

- (instancetype)initWithStartDate:(NSDate *)startDate
                          endDate:(NSDate *)endDate
{
    self = [super init];
    if (self)
    {
        self.startDate = startDate;
        self.endDate = endDate;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r startDate: %@ \r endDate: %@", NSStringFromClass([self class]),
            self.startDate,
            self.endDate];
}

- (BOOL)isEqual:(TimesheetPeriod *)otherTimesheetPeriod
{
    BOOL typesAreEqual = [self isKindOfClass:[otherTimesheetPeriod class]];
    if (!typesAreEqual) {
        return NO;
    }
    
    BOOL startDateEqualOrBothNil = (!self.startDate && !otherTimesheetPeriod.startDate) || ([self.startDate isEqual:otherTimesheetPeriod.startDate]);
    BOOL endDateEqualOrBothNil = (!self.endDate && !otherTimesheetPeriod.endDate) || ([self.endDate isEqual:otherTimesheetPeriod.endDate]);
    return startDateEqualOrBothNil && endDateEqualOrBothNil;
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return [[TimesheetPeriod alloc] initWithStartDate:[self.startDate copy]
                                              endDate:[self.endDate copy]];
}
@end
