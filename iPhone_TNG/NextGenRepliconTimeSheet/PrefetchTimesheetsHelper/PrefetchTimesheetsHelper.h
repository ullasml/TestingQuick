

#import <Foundation/Foundation.h>

@interface PrefetchTimesheetsHelper : NSObject

@property (nonatomic,readonly) NSHashTable *operations;

-(void)addTimesheetOperation:(NSOperation *)timesheetOperation;

-(void)removeTimesheetOperation:(NSOperation *)timesheetOperation;

@end
