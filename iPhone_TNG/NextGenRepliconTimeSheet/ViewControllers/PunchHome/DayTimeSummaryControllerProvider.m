#import "DayTimeSummaryControllerProvider.h"
#import "DateProvider.h"
#import "TimeSummaryRepository.h"
#import "Theme.h"
#import "PunchRepository.h"
#import <KSDeferred/KSPromise.h>
#import "TimeSummaryFetcher.h"
#import "DelayedTimeSummaryFetcher.h"
#import <KSDeferred/KSDeferred.h>
#import "TimesheetForDateRange.h"
#import "WorkHoursDeferred.h"
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import "UserPermissionsStorage.h"
#import "DayTimeSummaryController.h"


@interface DayTimeSummaryControllerProvider ()

@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) TimeSummaryRepository *timeSummaryRepository;
@property (nonatomic) id <Theme> theme;
@property (nonatomic) id <BSInjector> injector;

@end


@implementation DayTimeSummaryControllerProvider

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                         timeSummaryRepository:(TimeSummaryRepository*)timeSummaryRepository
                                         theme:(id <Theme>)theme {
    self = [super init];
    if (self) {
        self.userPermissionsStorage = userPermissionsStorage;
        self.timeSummaryRepository = timeSummaryRepository;
        self.theme = theme;
    }

    return self;
}

- (DayTimeSummaryController *)provideInstanceWithPromise:(KSPromise *)serverDidFinishPunchPromise
                               placeholderWorkHours:(id<WorkHours>)placeholderWorkHours
                                           delegate:(id<DayTimeSummaryUpdateDelegate>)delegate
{
    WorkHoursPromise *workHoursPromise;
    if (serverDidFinishPunchPromise)
    {
        workHoursPromise = (id)[serverDidFinishPunchPromise then:^id(id value) {
            return [self.timeSummaryRepository timeSummaryForToday];
        } error:nil];
    }
    else
    {
        workHoursPromise = [self.timeSummaryRepository timeSummaryForToday];
    }
    BOOL isScheduledDay = placeholderWorkHours!=nil ? placeholderWorkHours.isScheduledDay : YES;
    DayTimeSummaryController *dayTimeSummaryController = [self.injector getInstance:[DayTimeSummaryController  class]];
    [dayTimeSummaryController setupWithDelegate:delegate
                           placeHolderWorkHours:placeholderWorkHours
                               workHoursPromise:workHoursPromise
                                 hasBreakAccess:self.userPermissionsStorage.breaksRequired
                                 isScheduledDay:isScheduledDay
                      todaysDateContainerHeight:44.0];
    
    return dayTimeSummaryController;
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
