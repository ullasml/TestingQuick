#import <Foundation/Foundation.h>
#import "Timesheet.h"


@interface AstroAwareTimesheet : NSObject

@property (nonatomic, readonly) TimesheetAstroUserType astroUserType;
@property (nonatomic, copy, readonly) NSString *format;
@property (nonatomic, copy, readonly) NSString *uri;
@property (nonatomic, copy, readonly) NSDictionary *timesheetDictionary;
@property (nonatomic, readonly) BOOL hasPayrollSummary;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetAstroUserType:(TimesheetAstroUserType)astroUserType format:(NSString *)format uri:(NSString *)uri timesheetDictionary:(NSDictionary *)timesheetDictionary hasPayRollSummary:(BOOL)hasPayRollSummary;

@end
