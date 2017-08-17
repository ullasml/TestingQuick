
@class DurationCalculator;
@protocol Theme;
@protocol WorkHours;

#import <Foundation/Foundation.h>

@interface TimeSummaryPresenter : NSObject

@property (nonatomic, readonly) DurationCalculator *durationCalculator;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDurationCalculator:(DurationCalculator *)durationCalculator
                                     theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

-(void)setUpWithBreakPermission:(BOOL)hasBreakAccess;

- (NSArray *)placeholderSummaryItemsWithoutTimeOffHours;

- (NSArray *)summaryItemsWithWorkHours:(id<WorkHours>)workHours
                    regularHoursOffset:(NSDateComponents *)regularHoursOffset
                      breakHoursOffset:(NSDateComponents *)breakHoursOffset;

- (NSArray *)summaryItemsWithWorkHours:(id<WorkHours>)workHours
                    regularHoursOffset:(NSDateComponents *)regularHoursOffset;



@end
