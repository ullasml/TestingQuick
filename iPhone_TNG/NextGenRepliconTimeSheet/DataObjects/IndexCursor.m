#import "IndexCursor.h"
#import "DateProvider.h"
#import "TimesheetPeriod.h"
#import "Timesheet.h"


@interface IndexCursor ()
@property (nonatomic,copy) id <Timesheet> timesheet;
@property (nonatomic,copy) id <Timesheet> olderTimesheet;

@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) DateProvider *dateProvider;

@end


@implementation IndexCursor

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                            calendar:(NSCalendar *)calendar{
    self = [super init];
    if (self) {
        self.calendar = calendar;
        self.dateProvider = dateProvider;
    }
    return self;
}

-(void)setUpWithCurrentTimesheet:(id <Timesheet>)timesheet
               olderTimesheet:(id <Timesheet>)olderTimesheet
{
    self.timesheet = timesheet;
    self.olderTimesheet = olderTimesheet;
}

- (BOOL)canMoveForwards
{
    if (self.olderTimesheet == nil || self.olderTimesheet == (id)[NSNull null]) {
        return [self shouldForwardBeDisabledForTimesheetEndDate:self.timesheet.period.endDate];
    }
    return [self shouldForwardBeDisabledForTimesheetEndDate:self.olderTimesheet.period.endDate];
    
}

- (BOOL)canMoveBackwards
{
    if (self.timesheet == nil || self.timesheet == (id)[NSNull null]) {
        return NO;
    }
    return YES;
}

#pragma mark - Private

-(BOOL)shouldForwardBeDisabledForTimesheetEndDate:(NSDate *)endDate
{
    
    NSCalendarUnit unit = (NSCalendarUnitYear  | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *timesheetEndDateComponents = [self.calendar components:unit fromDate:endDate];
    NSDateComponents *todaysDateComponents = [self.calendar components:unit fromDate:self.dateProvider.date];
    NSDate *timesheetEndDate = [self.calendar dateFromComponents:timesheetEndDateComponents];
    NSDate *todayDate = [self.calendar dateFromComponents:todaysDateComponents];
    return ([timesheetEndDate compare:todayDate] == NSOrderedAscending);
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
