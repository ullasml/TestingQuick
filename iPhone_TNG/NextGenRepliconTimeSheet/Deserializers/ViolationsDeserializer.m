#import "ViolationsDeserializer.h"
#import "Waiver.h"
#import "WaiverOption.h"
#import "Violation.h"
#import "Constants.h"
#import "SingleViolationDeserializer.h"


@interface ViolationsDeserializer ()

@property (nonatomic) SingleViolationDeserializer *singleViolationDeserializer;

@end


@implementation ViolationsDeserializer

- (instancetype)initWithSingleViolationDeserializer:(SingleViolationDeserializer *)singleViolationDeserializer
{
    self = [super init];
    if (self)
    {
        self.singleViolationDeserializer = singleViolationDeserializer;
    }
    return self;
}

- (NSArray *)deserialize:(NSArray *)responseArray
{
    NSMutableArray *violations = [[NSMutableArray alloc] init];
    
    if (responseArray.count >0 ) {
        NSDictionary *currentDayViolations = responseArray[0];

        if (currentDayViolations != nil && ![currentDayViolations isKindOfClass:(id)[NSNull null]]) {
            NSArray *timePunchValidationMessages = currentDayViolations[@"timePunchValidationMessages"];
            NSArray *timesheetValidationMessages = currentDayViolations[@"timesheetValidationMessages"];
            
            NSArray *timesheetViolationsResult = [self getViolationsForValidationResult:timesheetValidationMessages];
            [violations addObjectsFromArray:timesheetViolationsResult];
            
            NSArray *timePunchViolationsResult = [self getViolationsForValidationResult:timePunchValidationMessages];
            [violations addObjectsFromArray:timePunchViolationsResult];
        }
    }
    return violations;
}

- (NSArray*)deserializeViolationsFromPunchValidationResult:(NSDictionary*)response
{
    NSMutableArray *violations = [NSMutableArray array];
    NSDictionary *punchValidationResult = response[@"punchValidationResult"];
    if (punchValidationResult != nil && punchValidationResult != (id)[NSNull null]) {
        NSMutableArray *validationMessages = punchValidationResult[@"validationMessages"];
        if (validationMessages != nil && validationMessages != (id)[NSNull null]) {
            for (NSDictionary *violationMessageDictionary in validationMessages)
            {
                Violation *violation = [self.singleViolationDeserializer deserialize:violationMessageDictionary];
                [violations addObject:violation];
            }
        }
    }
    return violations;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (NSArray *)getViolationsForValidationResult:(NSArray *)validationMessages
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
