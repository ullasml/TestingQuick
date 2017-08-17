#import "PunchErrorPresenter.h"
#import "Constants.h"
#import "FailedPunchErrorStorage.h"

@interface PunchErrorPresenter ()

@property (nonatomic) FailedPunchErrorStorage *failedPunchErrorStorage;

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSDateFormatter *timeFormatter;
@property (nonatomic) NSDateFormatter *localTimeZoneDateFormatter;

@end

@implementation PunchErrorPresenter

- (instancetype)initWithLocalTimeZoneDateFormatter:(NSDateFormatter *)localTimeZoneDateFormatter
                           failedPunchErrorStorage:(FailedPunchErrorStorage *)failedPunchErrorStorage
                                     dateFormatter:(NSDateFormatter *)dateFormatter
                                     timeFormatter:(NSDateFormatter *)timeFormatter {
    self = [super init];
    if (self) {
        self.dateFormatter = dateFormatter;
        self.timeFormatter = timeFormatter;
        self.failedPunchErrorStorage = failedPunchErrorStorage;
        self.localTimeZoneDateFormatter = localTimeZoneDateFormatter;
    }
    return self;
}

- (void)presentFailedPunchesErrors
{
    NSArray *punchErrors = [self.failedPunchErrorStorage getFailedPunchErrors];
    if (punchErrors != nil && punchErrors != (id)[NSNull null] && [punchErrors count]) {
        NSString *errorMessageString =
        [NSString stringWithFormat:@"\n %@",RPLocalizedString(punchesWithErrorsMsg, punchesWithErrorsMsg)];
        NSString *dateString;
        NSString *timeString;
        NSString *actionType;
        NSString *errorMsg;
        
        for (NSDictionary *errorDict in punchErrors) {
            NSString *singleErrorString = @"";
            self.localTimeZoneDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            NSDate *localDate = [self.localTimeZoneDateFormatter dateFromString:errorDict[@"date"]];
            dateString = [self.dateFormatter stringFromDate:localDate];
            timeString = [self.timeFormatter stringFromDate:localDate];
            actionType = errorDict[@"action_type"];
            errorMsg = errorDict[@"error_msg"];
            
            BOOL isBreakEntry = NO;
            
            if ([self isValidString:errorDict[@"break_name"]]) {
                isBreakEntry = YES;
                actionType = [NSString stringWithFormat:@"%@ %@",errorDict[@"break_name"], RPLocalizedString(Break, Break)];
            }
            else if ([actionType isEqualToString:RPLocalizedString(@"Clocked Out", @"Clocked Out")])
            {
                
            }
            else{
                if ([self isValidString:errorDict[@"activity_name"]]) {
                    actionType = [NSString stringWithFormat:@"%@ %@ %@",actionType, RPLocalizedString(@"with", @"with"), errorDict[@"activity_name"]];
                }
                else
                {
                    if ([self isValidString:errorDict[@"client_name"]]) {
                        actionType = [NSString stringWithFormat:@"%@ %@ %@",actionType, RPLocalizedString(@"with", @"with"), errorDict[@"client_name"]];
                    }
                    if ([self isValidString:errorDict[@"project_name"]]) {
                        if ([self isValidString:errorDict[@"client_name"]]) {
                            actionType = [NSString stringWithFormat:@"%@, %@",actionType, errorDict[@"project_name"]];
                        }
                        else{
                            actionType = [NSString stringWithFormat:@"%@ %@ %@",actionType, RPLocalizedString(@"with", @"with"), errorDict[@"project_name"]];
                        }
                    }
                    if ([self isValidString:errorDict[@"task_name"]]) {
                        actionType = [NSString stringWithFormat:@"%@, %@",actionType, errorDict[@"task_name"]];
                    }
                }
            }
            singleErrorString = [NSString stringWithFormat:@"%@ %@ %@, \n %@: %@", dateString, RPLocalizedString(AT_STRING, AT_STRING), timeString,  actionType, errorMsg];
            errorMessageString = [NSString stringWithFormat:@"%@ \n \n %@",errorMessageString, singleErrorString];
        }

        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:nil
                                                message:errorMessageString
                                                  title:RPLocalizedString(punchesWithErrorsTitle, punchesWithErrorsTitle)
                                                    tag:LONG_MIN];

        [self.failedPunchErrorStorage deletePunchErrors:punchErrors];
    }
}

-(BOOL)isValidString:(NSString *)value
{
    if (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]) {
        return YES;
    }
    return NO;
}

@end
