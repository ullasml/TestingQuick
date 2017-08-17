#import "LegacyTimesheetApprovalInfo.h"


@interface LegacyTimesheetApprovalInfo ()

@property (nonatomic) NSArray *allApprovalsTSArray;
@property (nonatomic) NSArray *dbTimesheetArray;
@property (nonatomic) NSInteger countOfUsers;
@property (nonatomic) BOOL isWidgetTimesheet;
@property (nonatomic) NSInteger indexCount;
@property (nonatomic, weak) id delegate;
@property (nonatomic) BOOL isFromPendingApprovals;
@property (nonatomic) BOOL isFromPreviousApprovals;

@end


@implementation LegacyTimesheetApprovalInfo

- (instancetype)initWithAllApprovalsTimesheetsArray:(NSArray *)allApprovalsTSArray
                        isWidgetTimesheet:(BOOL)isWidgetTimesheet
                         dbTimesheetArray:(NSArray *)dbTimesheetArray
                             countOfUsers:(NSInteger)countOfUsers
                               indexCount:(NSInteger)indexCount
                                 delegate:(id)delegate
                        isFromPendingApprovals:(BOOL)isFromPendingApprovals
                        isFromPreviousApprovals:(BOOL)isFromPreviousApprovals
{
    self = [super init];
    if (self) {
        self.allApprovalsTSArray = allApprovalsTSArray;
        self.isWidgetTimesheet = isWidgetTimesheet;
        self.dbTimesheetArray = dbTimesheetArray;
        self.countOfUsers = countOfUsers;
        self.indexCount = indexCount;
        self.delegate = delegate;
        self.isFromPendingApprovals = isFromPendingApprovals;
        self.isFromPreviousApprovals = isFromPreviousApprovals;
    }

    return self;
}

-(void)setDatabaseTimesheetArray:(NSArray *)dbTimesheetArray
{
    self.dbTimesheetArray=dbTimesheetArray;
}

@end
