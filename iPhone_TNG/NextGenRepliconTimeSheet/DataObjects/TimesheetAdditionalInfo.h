
#import <Foundation/Foundation.h>

@class TimeSheetPermittedActions;
@class AllViolationSections;


@interface TimesheetAdditionalInfo : NSObject <NSCopying>

@property (nonatomic, readonly) TimeSheetPermittedActions *timesheetPermittedActions;
@property (nonatomic, readonly) AllViolationSections *allViolationSections;
@property (nonatomic, readonly) BOOL payDetailsPermission;
@property (nonatomic, readonly) BOOL payAmountDetailsPermission;
@property (nonatomic, readonly) NSString *scriptCalculationDateValue;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetPermittedActions:(TimeSheetPermittedActions *)timesheetPermittedActions
                             allViolationSections:(AllViolationSections *)allViolationSections
                       scriptCalculationDateValue:(NSString *)scriptCalculationDateValue
                       payAmountDetailsPermission:(BOOL)payAmountDetailsPermission
                             payDetailsPermission:(BOOL)payDetailsPermission NS_DESIGNATED_INITIALIZER;
;

@end
