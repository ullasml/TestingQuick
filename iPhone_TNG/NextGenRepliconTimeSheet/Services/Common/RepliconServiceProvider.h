#import <Foundation/Foundation.h>

@class ApprovalsService;
@class ExpenseService;

@interface RepliconServiceProvider : NSObject

- (ApprovalsService *)provideApprovalsService;
- (ExpenseService *)provideExpenseService;

@end
