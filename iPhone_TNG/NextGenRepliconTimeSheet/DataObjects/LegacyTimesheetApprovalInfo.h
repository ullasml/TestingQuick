#import <Foundation/Foundation.h>


@interface LegacyTimesheetApprovalInfo : NSObject

@property (nonatomic, readonly) NSInteger indexCount;
@property (nonatomic, readonly) NSArray *allApprovalsTSArray;
@property (nonatomic, readonly) NSArray *dbTimesheetArray;
@property (nonatomic, weak, readonly) id delegate;
@property (nonatomic, readonly) BOOL isWidgetTimesheet;
@property (nonatomic, readonly) NSInteger countOfUsers;
@property (nonatomic, readonly) BOOL isFromPendingApprovals;
@property (nonatomic, readonly) BOOL isFromPreviousApprovals;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithAllApprovalsTimesheetsArray:(NSArray *)allApprovalsTSArray
                        isWidgetTimesheet:(BOOL)isWidgetTimesheet
                         dbTimesheetArray:(NSArray *)dbTimesheetArray
                             countOfUsers:(NSInteger)countOfUsers
                               indexCount:(NSInteger)indexCount
                                 delegate:(id)delegate
                   isFromPendingApprovals:(BOOL)isFromPendingApprovals
                   isFromPreviousApprovals:(BOOL)isFromPreviousApprovals  NS_DESIGNATED_INITIALIZER;

-(void)setDatabaseTimesheetArray:(NSArray *)dbTimesheetArray;

@end
