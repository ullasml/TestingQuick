#import <Foundation/Foundation.h>
#import "DayTimeSummaryController.h"

@protocol Theme;
@protocol WorkHours;

@class WorkHoursController;
@class WorkHoursPromise;
@class KSPromise;
@class UserPermissionsStorage;
@class TimeSummaryRepository;


@interface DayTimeSummaryControllerProvider : NSObject

@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, readonly) TimeSummaryRepository *timeSummaryRepository;
@property (nonatomic, readonly) id <Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                         timeSummaryRepository:(TimeSummaryRepository*)timeSummaryRepository
                                         theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (DayTimeSummaryController *)provideInstanceWithPromise:(KSPromise *)serverDidFinishPunchPromise
                                    placeholderWorkHours:(id<WorkHours>)placeholderWorkHours
                                                delegate:(id<DayTimeSummaryUpdateDelegate>)delegate;

@end

