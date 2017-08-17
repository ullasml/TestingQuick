
#import "PrefetchTimesheetsHelper.h"

@interface PrefetchTimesheetsHelper ()
@property (nonatomic) NSHashTable *operations;
@end

@implementation PrefetchTimesheetsHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operations = [NSHashTable weakObjectsHashTable];
    }
    return self;
}
-(void)addTimesheetOperation:(NSOperation *)timesheetOperation
{
    [self.operations addObject:timesheetOperation];
}

-(void)removeTimesheetOperation:(NSOperation *)timesheetOperation
{
    [self.operations removeObject:timesheetOperation];
    [timesheetOperation cancel];
}

@end
