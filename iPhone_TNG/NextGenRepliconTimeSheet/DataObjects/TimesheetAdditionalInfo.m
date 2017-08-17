
#import "TimesheetAdditionalInfo.h"
#import "TimeSheetPermittedActions.h"
#import "AllViolationSections.h"


@interface TimesheetAdditionalInfo ()

@property (nonatomic) BOOL payDetailsPermission;
@property (nonatomic) BOOL payAmountDetailsPermission;
@property (nonatomic) AllViolationSections *allViolationSections;
@property (nonatomic) TimeSheetPermittedActions *timesheetPermittedActions;
@property (nonatomic) NSString *scriptCalculationDateValue;
@end

@implementation TimesheetAdditionalInfo

- (instancetype)initWithTimesheetPermittedActions:(TimeSheetPermittedActions *)timesheetPermittedActions
                             allViolationSections:(AllViolationSections *)allViolationSections
                       scriptCalculationDateValue:(NSString *)scriptCalculationDateValue
                       payAmountDetailsPermission:(BOOL)payAmountDetailsPermission
                             payDetailsPermission:(BOOL)payDetailsPermission{
    
    self = [super init];
    if (self) {
        self.payDetailsPermission = payDetailsPermission;
        self.payAmountDetailsPermission = payAmountDetailsPermission;
        self.timesheetPermittedActions = timesheetPermittedActions;
        self.allViolationSections = allViolationSections;
        self.scriptCalculationDateValue = scriptCalculationDateValue;
    }
    return self;
    
}


#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone
{
    return [[TimesheetAdditionalInfo alloc] initWithTimesheetPermittedActions:[self.timesheetPermittedActions copy]
                                                         allViolationSections:[self.allViolationSections copy]
                                                   scriptCalculationDateValue: [self.scriptCalculationDateValue copy]
                                                   payAmountDetailsPermission:self.payAmountDetailsPermission
                                                         payDetailsPermission:self.payDetailsPermission];
    
}


@end
