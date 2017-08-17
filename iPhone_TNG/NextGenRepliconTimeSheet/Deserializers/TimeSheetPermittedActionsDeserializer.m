

#import "TimeSheetPermittedActionsDeserializer.h"
#import "TimeSheetPermittedActions.h"

@implementation TimeSheetPermittedActionsDeserializer


- (TimeSheetPermittedActions *)deserialize:(NSDictionary *)jsonDictionary
{
    NSDictionary *permittedActions = jsonDictionary[@"permittedActions"];
    NSNumber *canAutoSubmitOnDueDateFlag = [permittedActions objectForKey:@"canAutoSubmitOnDueDate"];
    BOOL isAutoSubmitEnabled = [canAutoSubmitOnDueDateFlag boolValue];
    
    NSDictionary *permittedActionsDict = [jsonDictionary objectForKey:@"permittedApprovalActions"];
    NSNumber *canSubmitFlag = [permittedActionsDict objectForKey:@"canSubmit"];
    NSNumber *canReopenFlag = [permittedActionsDict objectForKey:@"canReopen"];
    NSNumber *canUnSubmitFlag = [permittedActionsDict objectForKey:@"canUnsubmit"];
    NSNumber *canResubmitFlag = [permittedActions objectForKey:@"displayResubmit"];
    
    BOOL canSubmit = [canSubmitFlag boolValue];
    BOOL canReopen = [canReopenFlag boolValue];
    BOOL canUnsubmit = [canUnSubmitFlag boolValue];
    BOOL canReSubmit = [canResubmitFlag boolValue];
    
    BOOL shouldShowSubmit = (!isAutoSubmitEnabled && canSubmit && !canReSubmit);
    BOOL shouldShowReopen = (canReopen || canUnsubmit);
    BOOL shouldShowReSubmit = (canSubmit && canReSubmit);
    
    TimeSheetPermittedActions *permittedActionsOnTimeSheet = [[TimeSheetPermittedActions alloc] initWithCanSubmitOnDueDate:shouldShowSubmit
                                                                                                                 canReopen:shouldShowReopen
                                                                                                      canReSubmitTimeSheet:shouldShowReSubmit];
    return permittedActionsOnTimeSheet;
}

- (TimeSheetPermittedActions *)deserializeForWidgetTimesheet:(NSDictionary *)jsonDictionary 
                                         isAutoSubmitEnabled:(BOOL)isAutoSubmitEnabled
{
    NSDictionary *permittedActionsDict = [jsonDictionary objectForKey:@"permittedApprovalActions"];
    NSNumber *canSubmitFlag = [permittedActionsDict objectForKey:@"canSubmit"];
    NSNumber *canReopenFlag = [permittedActionsDict objectForKey:@"canReopen"];
    NSNumber *canUnSubmitFlag = [permittedActionsDict objectForKey:@"canUnsubmit"];
    NSNumber *canResubmitFlag = [permittedActionsDict objectForKey:@"displayResubmit"];
    
    BOOL canSubmit = [canSubmitFlag boolValue];
    BOOL canReopen = [canReopenFlag boolValue];
    BOOL canUnsubmit = [canUnSubmitFlag boolValue];
    BOOL canReSubmit = [canResubmitFlag boolValue];
    
    BOOL shouldShowSubmit = (!isAutoSubmitEnabled && canSubmit && !canReSubmit);
    BOOL shouldShowReopen = (canReopen || canUnsubmit);
    BOOL shouldShowReSubmit = (canSubmit && canReSubmit);
    
    TimeSheetPermittedActions *permittedActionsOnTimeSheet = [[TimeSheetPermittedActions alloc] initWithCanSubmitOnDueDate:shouldShowSubmit
                                                                                                                 canReopen:shouldShowReopen
                                                                                                      canReSubmitTimeSheet:shouldShowReSubmit];
    return permittedActionsOnTimeSheet;
}

@end
