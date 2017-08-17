
#import "TimesheetEntryObject.h"

@implementation TimesheetEntryObject
@synthesize timeEntryComments;
@synthesize timeEntryProjectName;
@synthesize timeEntryClientName;
@synthesize timeEntryTaskName;
@synthesize timeEntryActivityName;
@synthesize timeEntryHoursInHourFormat;
@synthesize timeEntryHoursInDecimalFormat;
@synthesize timeEntryUdfArray;
@synthesize isTimeoffSickRowPresent;
@synthesize timeEntryTimeOffName;
@synthesize multiDayInOutEntry;
@synthesize timeEntryProjectUri;
@synthesize timeEntryClientUri;
@synthesize timeEntryTaskUri;
@synthesize timeEntryActivityUri;
@synthesize timeEntryTimeOffUri;
@synthesize timeEntryBillingName;
@synthesize timeEntryBillingUri;
@synthesize timePunchUri;
@synthesize timeAllocationUri;
@synthesize timeEntryDate;
@synthesize entryType;
@synthesize timesheetUri;
@synthesize rowUri;
@synthesize isNewlyAddedAdhocRow;
@synthesize timeEntryHoursInDecimalFormatWithOutRoundOff;
@synthesize isRowEditable;
@synthesize timePunchesArray;
@synthesize breakName;
@synthesize breakUri;
@synthesize timeEntryRowUdfArray;
@synthesize timeEntryTimeOffRowUri;
@synthesize timeEntryProgramName;
@synthesize timeEntryProgramUri;
@synthesize rownumber;
@synthesize timeEntryCellOEFArray;
@synthesize timeEntryRowOEFArray;
@synthesize timeEntryDailyFieldOEFArray;
@synthesize hasTimeEntryValue;



#pragma mark - <NSCopying>
- (id)copy
{
    return [self copyWithZone:NULL];
}

-(id) copyWithZone: (NSZone *) zone
{
    TimesheetEntryObject *copyObject = [[TimesheetEntryObject allocWithZone: zone] init];
    
    [copyObject setTimeEntryTaskName:[self.timeEntryTaskName copy]];
    [copyObject setTimePunchUri:[self.timePunchUri copy]];
    [copyObject setRowUri:[self.rowUri copy]];
    [copyObject setBreakUri:[self.breakUri copy]];
    [copyObject setBreakName:[self.breakName copy]];
    [copyObject setEntryType:[self.entryType copy]];
    [copyObject setRownumber:[self.rownumber copy]];
    [copyObject setTimesheetUri:[self.timesheetUri copy]];
    [copyObject setTimeEntryDate:[self.timeEntryDate copy]];
    [copyObject setTimeEntryTaskUri:[self.timeEntryTaskUri copy]];
    [copyObject setIsRowEditable:self.isRowEditable];
    [copyObject setTimePunchesArray:[self.timePunchesArray mutableCopy]];
    [copyObject setTimeEntryComments:[self.timeEntryComments copy]];
    [copyObject setTimeEntryUdfArray:[self.timeEntryUdfArray mutableCopy]];
    [copyObject setTimeEntryRowOEFArray:[self.timeEntryRowOEFArray mutableCopy]];
    [copyObject setTimeAllocationUri:[self.timeAllocationUri copy]];
    [copyObject setTimeEntryClientUri:[self.timeEntryClientUri copy]];
    [copyObject setTimeEntryClientName:[self.timeEntryClientName copy]];
    [copyObject setTimeEntryBillingUri:[self.timeEntryBillingUri copy]];
    [copyObject setTimeEntryBillingName:[self.timeEntryBillingName copy]];
    [copyObject setTimeEntryProjectUri:[self.timeEntryProjectUri copy]];
    [copyObject setTimeEntryProjectName:[self.timeEntryProjectName copy]];
    [copyObject setTimeEntryProgramUri:[self.timeEntryProgramUri copy]];
    [copyObject setTimeEntryProgramName:[self.timeEntryProgramName copy]];
    [copyObject setTimeEntryCellOEFArray:[self.timeEntryCellOEFArray mutableCopy]];
    [copyObject setTimeEntryDailyFieldOEFArray:[self.timeEntryDailyFieldOEFArray mutableCopy]];
    [copyObject setHasTimeEntryValue:self.hasTimeEntryValue];
    [copyObject setMultiDayInOutEntry:[self.multiDayInOutEntry mutableCopy]];
    [copyObject setTimeEntryActivityUri:[self.timeEntryActivityUri copy]];
    [copyObject setTimeEntryActivityName:[self.timeEntryActivityName copy]];
    [copyObject setIsTimeoffSickRowPresent:self.isTimeoffSickRowPresent];
    [copyObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[self.timeEntryHoursInDecimalFormatWithOutRoundOff copy]];
    [copyObject setTimeEntryHoursInHourFormat:[self.timeEntryHoursInHourFormat copy]];
    [copyObject setTimeEntryHoursInDecimalFormat:[self.timeEntryHoursInDecimalFormat copy]];
    [copyObject setTimeEntryTimeOffName:[self.timeEntryTimeOffName copy]];
    [copyObject setTimeEntryTimeOffUri:[self.timeEntryTimeOffUri copy]];
    [copyObject setIsNewlyAddedAdhocRow:self.isNewlyAddedAdhocRow];
    [copyObject setTimeEntryRowUdfArray:[self.timeEntryRowUdfArray mutableCopy]];
    [copyObject setTimeEntryTimeOffRowUri:[self.timeEntryTimeOffRowUri copy]];
    return copyObject;
}




@end
