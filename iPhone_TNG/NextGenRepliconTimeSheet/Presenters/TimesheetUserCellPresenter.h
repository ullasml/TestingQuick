#import <Foundation/Foundation.h>


@class TimesheetForUserWithWorkHours;
@protocol Theme;


@interface TimesheetUserCellPresenter : NSObject

@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

- (NSString *)userNameLabelTextWithTimesheetUser:(TimesheetForUserWithWorkHours *)timesheetUser;
- (NSString *)workHoursLabelTextWithTimesheetUser:(TimesheetForUserWithWorkHours *)timesheetUser;
- (NSAttributedString *)regularHoursLabelTextWithTimesheetUser:(TimesheetForUserWithWorkHours *)timesheetUser;

@end
