

#import "TimeSheetPermittedActions.h"

@interface TimeSheetPermittedActions()

@property (nonatomic) BOOL canAutoSubmitOnDueDate;
@property (nonatomic) BOOL canReOpenSubmittedTimeSheet;
@property (nonatomic) BOOL canReSubmitTimeSheet;

@end

@implementation TimeSheetPermittedActions

- (instancetype)initWithCanSubmitOnDueDate:(BOOL)canSubmitOnDueDate
                                 canReopen:(BOOL)canReopenTimeSheet
                      canReSubmitTimeSheet:(BOOL)canReSubmitTimeSheet{

    if(self = [super init]) {
        self.canAutoSubmitOnDueDate = canSubmitOnDueDate;
        self.canReOpenSubmittedTimeSheet = canReopenTimeSheet;
        self.canReSubmitTimeSheet = canReSubmitTimeSheet;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@> \r canAutoSubmitOnDueDate: %d \r canReOpenSubmittedTimeSheet: %d \r canReSubmitTimeSheet: %d", NSStringFromClass([self class]),
            self.canAutoSubmitOnDueDate,
            self.canReOpenSubmittedTimeSheet,
            self.canReSubmitTimeSheet];
}

-(BOOL)isEqual:(TimeSheetPermittedActions *)otherPunchUser
{
    if(![otherPunchUser isKindOfClass:[self class]]) {
        return NO;
    }
    
    BOOL canAutoSubmitOnDueDateEqual = self.canAutoSubmitOnDueDate == otherPunchUser.canAutoSubmitOnDueDate;
    BOOL canReopenTimeSheetEqual = self.canReOpenSubmittedTimeSheet == otherPunchUser.canReOpenSubmittedTimeSheet;
    BOOL canReSubmitTimeSheetEqual = self.canReSubmitTimeSheet == otherPunchUser.canReSubmitTimeSheet;
    return ( canAutoSubmitOnDueDateEqual && canReSubmitTimeSheetEqual && canReopenTimeSheetEqual);
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[TimeSheetPermittedActions alloc] initWithCanSubmitOnDueDate:self.canAutoSubmitOnDueDate
                                                               canReopen:self.canReOpenSubmittedTimeSheet
                                                    canReSubmitTimeSheet:self.canReSubmitTimeSheet];
    
}
@end
