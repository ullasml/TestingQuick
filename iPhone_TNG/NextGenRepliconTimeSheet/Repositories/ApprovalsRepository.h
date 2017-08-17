#import <Foundation/Foundation.h>

@class KSPromise;
@class RepliconServiceProvider;
@class ApprovalsModelProvider;

@interface ApprovalsRepository : NSObject

@property(nonatomic, readonly) RepliconServiceProvider *repliconServiceProvider;
@property(nonatomic, readonly) ApprovalsModelProvider *approvalsModelProvider;
@property(nonatomic, readonly) NSNotificationCenter *notificationCenter;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRepliconServiceProvider:(RepliconServiceProvider *)repliconServiceProvider
               approvalsModelProvider:(ApprovalsModelProvider *)approvalsModelProvider
                   notificationCenter:(NSNotificationCenter *)notificationCenter NS_DESIGNATED_INITIALIZER;

- (void)fetchTimeOffApprovalsAndPostNotification;
- (void)fetchTimesheetApprovalsAndPostNotification;
- (void)fetchExpenseApprovalsAndPostNotification;
- (KSPromise *)approveAllExpenseSheetWithUriFromCollection:(NSArray *)allExpenseSheetUri;
- (KSPromise *)rejectAllExpenseSheetWithUriFromCollection:(NSArray *)allExpenseSheetUri;

@end
