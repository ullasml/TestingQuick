#import "TimesheetDetailsPresenter.h"
#import "Timesheet.h"
#import "TeamTimesheetSummary.h"
#import "TimesheetPeriod.h"
#import "TimeSheetApprovalStatus.h"
#import "Cursor.h"
#import "DateProvider.h"

typedef enum {
    CursorTypeCurrent = 0,
    CurrsorTypeForwardOrBackward = 1
}CursorType;

@interface TimesheetDetailsPresenter ()

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) DateProvider *dateProvider;

@end


@implementation TimesheetDetailsPresenter

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter
                         dateProvider:(DateProvider *)dateProvider
{
    self = [super init];
    if (self) {
        self.dateFormatter = dateFormatter;
        self.dateProvider = dateProvider;
    }
    
    return self;
}


- (NSString *)dateRangeTextWithTimesheetPeriod:(TimesheetPeriod *)timesheetPeriod
{
    NSString *startDateString = [self.dateFormatter stringFromDate:timesheetPeriod.startDate];
    NSString *endDateString = [self.dateFormatter stringFromDate:timesheetPeriod.endDate];
    
    return [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
}

- (BOOL)isCurrentTimesheetForPeriod:(TimesheetPeriod *)period
{
    BOOL isCurrentPeriod = isDateWithinRange(self.dateProvider.date, period.startDate, period.endDate);
    return isCurrentPeriod;
}


- (NSString *)approvalStatusForTimeSheet:(TimeSheetApprovalStatus *)timeSheetApprovalStatus
                                  cursor:(id<Cursor>) cursor
                         timeSheetPeriod:(TimesheetPeriod *)timeSheetPeriod  {
    
    CursorType cursorType = [self getCursorTypeForCursor:cursor timeSheetPeriod:timeSheetPeriod];
    NSString *approvalStatus ;
    switch (cursorType) {
        case CursorTypeCurrent:
            approvalStatus =  RPLocalizedString(@"Current Period", @"Current Period");;
            break;
            
        default:
            approvalStatus = @"";
            break;
    }
    return approvalStatus;
}


#pragma mark -Helper Methods

- (CursorType)getCursorTypeForCursor:(id<Cursor>)cursor timeSheetPeriod:(TimesheetPeriod *)timesheetPeriod {
    CursorType cursorType;
    
    if((![cursor canMoveForwards] && [cursor canMoveBackwards]) || [self isCurrentPeriod:timesheetPeriod]) {
        cursorType = CursorTypeCurrent;
    }
    else {
        cursorType = CurrsorTypeForwardOrBackward;
    }
    return cursorType;
}

- (BOOL)isCurrentPeriod:(TimesheetPeriod *)period {
    BOOL isCurrentPeriod = isDateWithinRange([NSDate date], period.startDate, period.endDate);
    return isCurrentPeriod;
}

@end
