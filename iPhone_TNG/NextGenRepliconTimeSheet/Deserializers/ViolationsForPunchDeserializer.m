#import "ViolationsForPunchDeserializer.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import "SingleViolationDeserializer.h"
#import "Violation.h"
#import "DateTimeComponentDeserializer.h"


@interface ViolationsForPunchDeserializer ()

@property (nonatomic) SingleViolationDeserializer *singleViolationDeserializer;
@property (nonatomic) DateTimeComponentDeserializer *timeComponentDeserializer;

@end


@implementation ViolationsForPunchDeserializer

- (instancetype)initWithSingleViolationDeserializer:(SingleViolationDeserializer *)singleViolationDeserializer
{
    self = [super init];
    if (self) {
        self.singleViolationDeserializer = singleViolationDeserializer;
        self.timeComponentDeserializer = [[DateTimeComponentDeserializer alloc] init];
    }
    return self;
}

- (AllViolationSections *)deserialize:(NSDictionary *)jsonDictionary
{
    NSArray *dataArray = jsonDictionary[@"d"];
    if (dataArray != nil && dataArray != (id)[NSNull null]) {
        NSArray *validationMessageDictionaries = jsonDictionary[@"d"][@"validationMessages"];
        if (validationMessageDictionaries != nil && validationMessageDictionaries != (id)[NSNull null]) {
            NSUInteger totalViolationsCount = [validationMessageDictionaries count];
            
            NSMutableArray *validationMessages = [NSMutableArray arrayWithCapacity:totalViolationsCount];
            for (NSDictionary *validationMessageDictionary in validationMessageDictionaries) {
                Violation *violation = [self.singleViolationDeserializer deserialize:validationMessageDictionary];
                [validationMessages addObject:violation];
            }
            NSDictionary *validationTimeDictionary = jsonDictionary[@"d"][@"validationTime"];
            
            NSDateComponents *dateComponents = [self.timeComponentDeserializer deserializeDateTime:validationTimeDictionary];
            
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDate *date  =[calendar dateFromComponents:dateComponents];
            ViolationSection *violationSection = [[ViolationSection alloc] initWithTitleObject:date
                                                                                    violations:validationMessages
                                                                                          type:ViolationSectionTypeDate];
            
            return [[AllViolationSections alloc] initWithTotalViolationsCount:totalViolationsCount
                                                                     sections:@[violationSection]];
        }
    }
    return [[AllViolationSections alloc] initWithTotalViolationsCount:0
                                                             sections:@[]];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}



@end
