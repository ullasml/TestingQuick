
#import <Foundation/Foundation.h>

@interface TimesheetEntryObject : NSObject  <NSCoding, NSCopying>

{
    NSString *timeEntryComments;
    NSString *timeEntryProjectName;
    NSString *timeEntryProjectUri;
    NSString *timeEntryClientName;
    NSString *timeEntryClientUri;
    NSString *timeEntryTaskName;
    NSString *timeEntryTaskUri;
    NSString *timeEntryActivityName;
    NSString *timeEntryActivityUri;
    NSString *timeEntryBillingName;
    NSString *timeEntryBillingUri;
    NSString *timeOffName;
    NSString *timeOffTypeUri;
    NSString *timeEntryHoursInHourFormat;
    NSString *timeEntryHoursInDecimalFormat;
    NSString *timeEntryHoursInDecimalFormatWithOutRoundOff;
    NSMutableArray *timeEntryUdfArray;
    BOOL isTimeoffSickRowPresent;
    NSMutableDictionary *multiDayInOutEntry;
    NSString *timePunchUri;
    NSString *timeAllocationUri;
    NSDate *timeEntryDate;
    NSString *entryType;
    NSString *timesheetUri;
    NSString *rowUri;
    BOOL isNewlyAddedAdhocRow;
    BOOL isRowEditable;
    NSMutableArray *timePunchesArray;
    NSString *breakName;
    NSString *breakUri;
    NSMutableArray *timeEntryRowUdfArray;
    NSString *timeEntryTimeOffRowUri;
    NSString *rownumber;
    NSMutableArray *timeEntryRowOEFArray;
    NSMutableArray *timeEntryCellOEFArray;
    NSMutableArray *timeEntryDailyFieldOEFArray;
    BOOL hasTimeEntryValue;
}
@property(nonatomic,assign)BOOL hasTimeEntryValue;
@property(nonatomic,strong)NSString *timeEntryComments;
@property(nonatomic,strong)NSString *timeEntryProjectName;
@property(nonatomic,strong)NSString *timeEntryProjectUri;
@property(nonatomic,strong)NSString *timeEntryClientName;
@property(nonatomic,strong)NSString *timeEntryClientUri;
@property(nonatomic,strong)NSString *timeEntryTaskName;
@property(nonatomic,strong)NSString *timeEntryTaskUri;
@property(nonatomic,strong)NSString *timeEntryActivityName;
@property(nonatomic,strong)NSString *timeEntryActivityUri;
@property(nonatomic,strong)NSString *timeEntryTimeOffName;
@property(nonatomic,strong)NSString *timeEntryTimeOffUri;
@property(nonatomic,strong)NSString *timeEntryBillingName;
@property(nonatomic,strong)NSString *timeEntryBillingUri;
@property(nonatomic,strong)NSString *timeEntryHoursInHourFormat;
@property(nonatomic,strong)NSString *timeEntryHoursInDecimalFormat;
@property(nonatomic,strong)NSString *timeEntryHoursInDecimalFormatWithOutRoundOff;
@property(nonatomic,strong)NSMutableArray *timeEntryUdfArray;
@property(nonatomic,assign)BOOL isTimeoffSickRowPresent;
@property(nonatomic,strong)NSMutableDictionary *multiDayInOutEntry;
@property(nonatomic,strong)NSString *timePunchUri;
@property(nonatomic,strong)NSString *timeAllocationUri;
@property(nonatomic,strong)NSDate *timeEntryDate;
@property(nonatomic,strong)NSString *entryType;
@property(nonatomic,strong)NSString *timesheetUri;
@property(nonatomic,strong)NSString *rowUri;
@property(nonatomic,assign)BOOL isNewlyAddedAdhocRow;
@property(nonatomic,assign)BOOL isRowEditable;
@property(nonatomic,strong)NSMutableArray *timePunchesArray;
@property(nonatomic,strong)NSString *breakName;
@property(nonatomic,strong)NSString *breakUri;
@property(nonatomic,strong)NSMutableArray *timeEntryRowUdfArray;
@property(nonatomic,strong) NSString *timeEntryTimeOffRowUri;
@property(nonatomic,strong)NSString *timeEntryProgramName;
@property(nonatomic,strong)NSString *timeEntryProgramUri;
@property(nonatomic,strong)NSString *rownumber;
@property(nonatomic,strong)NSMutableArray *timeEntryRowOEFArray;
@property(nonatomic,strong)NSMutableArray *timeEntryCellOEFArray;
@property(nonatomic,strong)NSMutableArray *timeEntryDailyFieldOEFArray;


@end

