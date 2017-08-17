
#import "WorkHoursStorage.h"
#import "DoorKeeper.h"
#import "DateProvider.h"
#import "WorkHours.h"
#import "DurationCalculator.h"
#import "DayTimeSummary.h"
#import "UserSession.h"

@interface WorkHoursStorage ()

@property (nonatomic) NSFileManager *fileManager;
@property (nonatomic) DoorKeeper *doorKeeper;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) DurationCalculator *durationCalculator;
@property (nonatomic) id<UserSession> userSession;


@property (nonatomic,copy) NSString *summaryHoursFilename;
@property (nonatomic,copy) NSString *summaryDateFilename;

@end

@implementation WorkHoursStorage

- (instancetype)initWithDurationCalculator:(DurationCalculator *)durationCalculator
                               fileManager:(NSFileManager *)fileManager
                              dateProvider:(DateProvider *)dateProvider
                                doorKeeper:(DoorKeeper *)doorKeeper
                               userSession:(id<UserSession>)userSession
{
    self = [super init];
    if (self) {
        self.doorKeeper = doorKeeper;
        self.fileManager = fileManager;
        self.dateProvider = dateProvider;
        self.durationCalculator = durationCalculator;
        self.userSession = userSession;
        [self.doorKeeper addLogOutObserver:self];
    }
    return self;
}

- (void)setupWithSummaryFilename:(NSString *)summaryFilename dateFileName:(NSString *)dateFileName {
    self.summaryHoursFilename = summaryFilename;
    self.summaryDateFilename = dateFileName;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)saveWorkHoursSummary:(id<WorkHours>)workHours
{
    if ([self.userSession validUserSession]) {
        [NSKeyedArchiver archiveRootObject:workHours.dateComponents toFile:[self storagePathForDate]];
        [NSKeyedArchiver archiveRootObject:workHours toFile:[self storagePathForSummaryHours]];
    }
}

- (id <WorkHours>)getWorkHoursSummary
{
    NSDateComponents *cachedDateComponents = [NSKeyedUnarchiver unarchiveObjectWithFile:[self storagePathForDate]];
    NSDateComponents *todayDateComponents = [self componentsForPresentDate];
    BOOL onSameDay = [self sameComponents:cachedDateComponents otherComponents:todayDateComponents];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: [self storagePathForSummaryHours]];
    if (onSameDay && exists) {
        id <WorkHours> workHours = [NSKeyedUnarchiver unarchiveObjectWithFile:[self storagePathForSummaryHours]];
        return workHours;
    }
    else{
        [self clearCachedWorkHoursSummary];
    }
    return nil;
}

- (id <WorkHours>)getCombinedWorkHoursSummary
{
    NSDateComponents *cachedDateComponents = [NSKeyedUnarchiver unarchiveObjectWithFile:[self storagePathForDate]];
    NSDateComponents *todayDateComponents = [self componentsForPresentDate];
    BOOL onSameDay = [self sameComponents:cachedDateComponents otherComponents:todayDateComponents];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: [self storagePathForSummaryHours]];
    if (onSameDay && exists) {
        id <WorkHours> workHours = [NSKeyedUnarchiver unarchiveObjectWithFile:[self storagePathForSummaryHours]];
        id <WorkHours> placeHolderWorkHours = [self provideSummaryWithOffsetForWorkHours:workHours];
        return placeHolderWorkHours;
    }
    else{
        [self clearCachedWorkHoursSummary];
    }
    return nil;
}



-(void)clearCachedWorkHoursSummary
{
    [self clearCachedFileAtPath:[self storagePathForSummaryHours]];
    [self clearCachedFileAtPath:[self storagePathForDate]];
}

#pragma mark - <DoorKeeperLogOutObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self clearCachedWorkHoursSummary];
}

#pragma mark - Private

-(NSDateComponents *)componentsForPresentDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [self.dateProvider date];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear  | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
    return dateComponents;
}

-(BOOL)sameComponents:(NSDateComponents *)components otherComponents:(NSDateComponents *)otherComponents
{
    BOOL dayComponentsEqual = (components.day == otherComponents.day);
    BOOL monthComponentsEqual = (components.month == otherComponents.month);
    BOOL yearComponentsEqual = (components.year == otherComponents.year);
    return  dayComponentsEqual && monthComponentsEqual && yearComponentsEqual ;
}

-(id <WorkHours>)provideSummaryWithOffsetForWorkHours:(id <WorkHours>)workHours
{

    NSDateComponents *regularComponents = [self.durationCalculator sumOfTimeByAddingDateComponents:workHours.regularTimeOffsetComponents
                                                                                  toDateComponents:workHours.regularTimeComponents];
    NSDateComponents *breakComponents = [self.durationCalculator sumOfTimeByAddingDateComponents:workHours.breakTimeOffsetComponents
                                                                                toDateComponents:workHours.breakTimeComponents];

    return [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:nil
                                             breakTimeOffsetComponents:nil
                                                 regularTimeComponents:regularComponents
                                                   breakTimeComponents:breakComponents
                                                     timeOffComponents:workHours.timeOffComponents
                                                        dateComponents:workHours.dateComponents
                                                        isScheduledDay:workHours.isScheduledDay];
}

-(id <WorkHours>)provideSummaryWithoutOffsetForWorkHours:(id <WorkHours>)workHours
{
    return [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:nil
                                             breakTimeOffsetComponents:nil
                                                 regularTimeComponents:workHours.regularTimeComponents
                                                   breakTimeComponents:workHours.breakTimeComponents
                                                     timeOffComponents:workHours.timeOffComponents
                                                        dateComponents:workHours.dateComponents
                                                        isScheduledDay:workHours.isScheduledDay];
}


-(void)clearCachedFileAtPath:(NSString *)filePath
{
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if(exists) {
        NSError *error;
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:&error];
    }
}

- (NSString *)storagePathForSummaryHours
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = paths.firstObject;

    return [directory stringByAppendingPathComponent:self.summaryHoursFilename];
}

- (NSString *)storagePathForDate
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = paths.firstObject;

    return [directory stringByAppendingPathComponent:self.summaryDateFilename];
}




@end
