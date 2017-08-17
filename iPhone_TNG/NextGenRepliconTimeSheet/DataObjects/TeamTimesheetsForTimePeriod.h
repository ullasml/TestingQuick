#import <Foundation/Foundation.h>

@interface TeamTimesheetsForTimePeriod : NSObject

@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;
@property (nonatomic, readonly) NSArray *timesheets;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate timesheets:(NSArray *)timesheets NS_DESIGNATED_INITIALIZER;

@end
