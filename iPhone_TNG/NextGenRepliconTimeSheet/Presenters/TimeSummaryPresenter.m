#import "TimeSummaryPresenter.h"
#import "Theme.h"
#import "DurationCalculator.h"
#import "TimePeriodSummary.h"
#import "WorkHours.h"
#import "WorkHoursPresenter.h"
#import "Constants.h"


@interface TimeSummaryPresenter ()

@property (nonatomic) DurationCalculator *durationCalculator;
@property (nonatomic) id<Theme> theme;
@property (nonatomic, assign) BOOL hasBreakAccess;
@end


@implementation TimeSummaryPresenter

- (instancetype)initWithDurationCalculator:(DurationCalculator *)durationCalculator
                                     theme:(id <Theme>)theme {
    self = [super init];
    if (self) {
        self.durationCalculator = durationCalculator;
        self.theme = theme;
    }
    return self;
}

-(void)setUpWithBreakPermission:(BOOL)hasBreakAccess
{
    self.hasBreakAccess = hasBreakAccess;
}

- (NSArray *)placeholderSummaryItemsWithoutTimeOffHours
{
    WorkHoursPresenter *regularHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Work", @"Work")
                                                                                textColor:[self.theme workTimeDurationColor]
                                                                                    image:@"icon_timeline_clock_in"
                                                                                    value:@"-"];
    
    NSMutableArray *placeholderItems = [NSMutableArray arrayWithObject:regularHoursPresenter];
    
    
    if (self.hasBreakAccess) {
        WorkHoursPresenter *breakHoursPresenter = [[WorkHoursPresenter alloc] initWithTitle:RPLocalizedString(@"Break", @"Break")
                                                                                  textColor:[self.theme breakTimeDurationColor]
                                                                                      image:@"icon_timeline_break"
                                                                                      value:@"-"];
        
        [placeholderItems addObject:breakHoursPresenter];
    }
    
    return placeholderItems;
}



- (NSArray *)summaryItemsWithWorkHours:(id <WorkHours>)workHours
                    regularHoursOffset:(NSDateComponents *)regularHoursOffset
                      breakHoursOffset:(NSDateComponents *)breakHoursOffset
{
    
    WorkHoursPresenter *regularHoursPresenter = [self regularPresenterFromWorkHours:workHours
                                                                 regularHoursOffset:regularHoursOffset];
    
    NSMutableArray *itemsArray = [NSMutableArray arrayWithObject:regularHoursPresenter];
    
    
    if (![self isComponentsPresent:workHours.breakTimeComponents] && ![self isComponentsPresent:breakHoursOffset]) {
        if (self.hasBreakAccess) {
            WorkHoursPresenter *breakHoursPresenter = [self breakPresenterFromWorkHours:workHours
                                                                       breakHoursOffset:breakHoursOffset];
            [itemsArray addObject:breakHoursPresenter];
        }
    }
    else{
        WorkHoursPresenter *breakHoursPresenter = [self breakPresenterFromWorkHours:workHours
                                                                   breakHoursOffset:breakHoursOffset];
        [itemsArray addObject:breakHoursPresenter];
    }
    
    if ([self isComponentsPresent:workHours.timeOffComponents]) {
        WorkHoursPresenter *timeOffHoursPresenter = [self timeOffPresenterFromWorkHours:workHours];
        [itemsArray addObject:timeOffHoursPresenter];
    }
    
    return itemsArray;
}

- (NSArray *)summaryItemsWithWorkHours:(id <WorkHours>)workHours
                    regularHoursOffset:(NSDateComponents *)regularHoursOffset
{
    
    WorkHoursPresenter *regularHoursPresenter = [self regularPresenterFromWorkHours:workHours
                                                                 regularHoursOffset:regularHoursOffset];
    
    NSMutableArray *itemsArray = [NSMutableArray arrayWithObject:regularHoursPresenter];
    
    if ([self isComponentsPresent:workHours.timeOffComponents]) {
        WorkHoursPresenter *timeOffHoursPresenter = [self timeOffPresenterFromWorkHours:workHours];
        [itemsArray addObject:timeOffHoursPresenter];
    }

    return itemsArray;
}


#pragma mark - Private

- (NSString *)stringFromTimeComponents:(NSDateComponents *)timeComponents {
    return [NSString stringWithFormat:@"%ldh:%02ldm",
            (long)timeComponents.hour,
            timeComponents.minute];
}

- (WorkHoursPresenter *)regularPresenterFromWorkHours:(id<WorkHours>)workHours
                                   regularHoursOffset:(NSDateComponents *)regularHoursOffset {
    NSString *regularTitle = RPLocalizedString(@"Work", @"Work");
    
    NSDateComponents *deltaRegularComponents = [self.durationCalculator sumOfTimeByAddingDateComponents:regularHoursOffset
                                                                                       toDateComponents:workHours.regularTimeComponents];
    
    NSString *regularValueString = [self stringFromTimeComponents:deltaRegularComponents];
    
    UIColor *regularColor = [self.theme workTimeDurationColor];
    
    return [[WorkHoursPresenter alloc] initWithTitle:regularTitle
                                           textColor:regularColor
                                               image:@"icon_timeline_clock_in"
                                               value:regularValueString];
}

- (WorkHoursPresenter *)breakPresenterFromWorkHours:(id<WorkHours>)workHours
                                   breakHoursOffset:(NSDateComponents *)breakHoursOffset {
    NSDateComponents *deltaBreakComponents = [self.durationCalculator sumOfTimeByAddingDateComponents:breakHoursOffset
                                                                                     toDateComponents:workHours.breakTimeComponents];
    
    NSString *breakTitle = RPLocalizedString(@"Break", @"Break");
    
    NSString *breakValueString = [self stringFromTimeComponents:deltaBreakComponents];
    
    UIColor *breakColor = [self.theme breakTimeDurationColor];
    
    return [[WorkHoursPresenter alloc] initWithTitle:breakTitle
                                           textColor:breakColor
                                               image:@"icon_timeline_break"
                                               value:breakValueString];
}

- (WorkHoursPresenter *)timeOffPresenterFromWorkHours:(id<WorkHours>)workHours{
    NSString *timeOffTitle = RPLocalizedString(TimeoffLabelText, TimeoffLabelText);
    
    NSString *timeOffValueString = [self stringFromTimeComponents:workHours.timeOffComponents];
    
    UIColor *timeOffColor = [self.theme timeOffTimeDurationColor];
    
    return [[WorkHoursPresenter alloc] initWithTitle:timeOffTitle
                                           textColor:timeOffColor
                                               image:@"icon_time_off"
                                               value:timeOffValueString];
}


-(BOOL)isComponentsPresent:(NSDateComponents*)dateComponents
{
    if (dateComponents) {
        if (dateComponents.hour != 0 ||  dateComponents.minute != 0 || dateComponents.second != 0) {
            return YES;
        }
    }
    return NO;
}


@end
