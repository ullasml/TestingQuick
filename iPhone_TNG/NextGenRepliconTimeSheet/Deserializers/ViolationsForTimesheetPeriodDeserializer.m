#import "ViolationsForTimesheetPeriodDeserializer.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import "Util.h"
#import "SingleViolationDeserializer.h"

@interface ViolationsForTimesheetPeriodDeserializer ()

@property (nonatomic) SingleViolationDeserializer *singleViolationDeserializer;
@property (nonatomic) NSCalendar *calendar;

@end


@implementation ViolationsForTimesheetPeriodDeserializer

- (instancetype)initWithSingleViolationDeserializer:(SingleViolationDeserializer *)singleViolationDeserializer
                                           calendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self)
    {
        self.singleViolationDeserializer = singleViolationDeserializer;
        self.calendar = calendar;
    }
    return self;
}

- (AllViolationSections *)deserialize:(NSDictionary *)jsonDictionary timesheetType:(TimesheetType )timesheetType
{
    NSUInteger totalViolationsCount = 0;
    if (timesheetType == AstroTimesheetType) {
        totalViolationsCount = [jsonDictionary[@"totalTimesheetPeriodValidationMessagesCount"] unsignedIntegerValue];
    }
    else {
        totalViolationsCount = [jsonDictionary[@"totalTimesheetPeriodViolationMessagesCount"] unsignedIntegerValue];
    }
    NSArray *validationMessagesByDate = jsonDictionary[@"validationMessagesByDate"];
    NSMutableArray *sections = [self deserializeViolationSections:validationMessagesByDate];

    NSArray *timesheetLevelViolations = jsonDictionary[@"timesheetLevelValidationMessages"];

    if (timesheetLevelViolations.count) {
        ViolationSection *timesheetLevelViolationSection = [self deserializeTimesheetLevelViolations:timesheetLevelViolations];
        [sections insertObject:timesheetLevelViolationSection atIndex:0];
    }

    return [[AllViolationSections alloc] initWithTotalViolationsCount:totalViolationsCount
                                                             sections:sections];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (NSMutableArray *)deserializeViolationSections:(NSArray *)validationMessagesByDate
{
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:validationMessagesByDate.count];

    for (NSDictionary *validationMessageDictionary in validationMessagesByDate) {
        NSDictionary *dateDictionary = validationMessageDictionary[@"date"];
        NSDate *date = [self deserializeDate:dateDictionary];

        NSArray *timePunchValidationMessages = validationMessageDictionary[@"timePunchValidationMessages"];
        NSArray *timePunchViolations = [self deserializeViolations:timePunchValidationMessages];

        NSArray *timesheetValidationMessages = validationMessageDictionary[@"timesheetValidationMessages"];
        NSArray *timesheetViolations = [self deserializeViolations:timesheetValidationMessages];

        NSArray *violations = [timePunchViolations arrayByAddingObjectsFromArray:timesheetViolations];

        ViolationSection *section = [[ViolationSection alloc] initWithTitleObject:date
                                                                       violations:violations
                                                                             type:ViolationSectionTypeDate];
        [sections addObject:section];
    }

    return sections;
}

- (ViolationSection *)deserializeTimesheetLevelViolations:(NSArray *)timesheetLevelViolations
{
    NSArray *deserializedTimesheetLevelViolations = [self deserializeViolations:timesheetLevelViolations];
    ViolationSection *section = [[ViolationSection alloc] initWithTitleObject:nil
                                                                   violations:deserializedTimesheetLevelViolations
                                                                         type:ViolationSectionTypeTimesheet];

    return section;
}

- (NSDate *)deserializeDate:(NSDictionary *)dateDictionary
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = [dateDictionary[@"year"] integerValue];
    dateComponents.month = [dateDictionary[@"month"] integerValue];
    dateComponents.day = [dateDictionary[@"day"] integerValue];
    return [self.calendar dateFromComponents:dateComponents];
}

- (NSArray *)deserializeViolations:(NSArray *)validationMessages
{
    NSMutableArray *violations = [NSMutableArray arrayWithCapacity:validationMessages.count];

    for (NSDictionary *violationMessageDictionary in validationMessages)
    {
        Violation *violation = [self.singleViolationDeserializer deserialize:violationMessageDictionary];
        [violations addObject:violation];
    }

    return violations;
}

@end
