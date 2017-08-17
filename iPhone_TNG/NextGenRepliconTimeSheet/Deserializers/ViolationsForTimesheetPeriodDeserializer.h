#import <Foundation/Foundation.h>


@class AllViolationSections;
@class SingleViolationDeserializer;

typedef NS_ENUM(NSInteger, TimesheetType){
    WidgetTimesheetType = 0,
    AstroTimesheetType = 1,
};


@interface ViolationsForTimesheetPeriodDeserializer : NSObject

@property (nonatomic, readonly) SingleViolationDeserializer *singleViolationDeserializer;
@property (nonatomic, readonly) NSCalendar *calendar;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSingleViolationDeserializer:(SingleViolationDeserializer *)singleViolationDeserializer
                                           calendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

- (AllViolationSections *)deserialize:(NSDictionary *)jsonDictionary timesheetType:(TimesheetType )timesheetType;

@end
