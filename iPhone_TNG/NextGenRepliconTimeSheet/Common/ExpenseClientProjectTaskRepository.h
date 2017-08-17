

#import <Foundation/Foundation.h>
#import "ClientProjectTaskRepository.h"


@interface ExpenseClientProjectTaskRepository : NSObject <ClientProjectTaskRepository>

-(void)setUpWithExpenseSheetUri:(NSString*)uri;
@end
