#import "SingleViolationDeserializer.h"
#import "Violation.h"
#import "WaiverOption.h"
#import "Constants.h"
#import "Waiver.h"
#import "WaiverDeserializer.h"


@interface SingleViolationDeserializer ()

@property (nonatomic) WaiverDeserializer *waiverDeserializer;

@end


@implementation SingleViolationDeserializer

- (instancetype)initWithWaiverDeserializer:(WaiverDeserializer *)waiverDeserializer
{
    self = [super init];
    if (self) {
        self.waiverDeserializer = waiverDeserializer;
    }
    return self;
}

- (Violation *)deserialize:(NSDictionary *)violationDictionary
{
    NSString *violationTitle = violationDictionary[@"displayText"];
    NSString *severityURI = violationDictionary[@"severity"];

    ViolationSeverity severity = ViolationSeverityUnknown;
    if ([severityURI isEqualToString:GEN4_TIMESHEET_ERROR_URI]) {
        severity = ViolationSeverityError;
    } else if ([severityURI isEqualToString:GEN4_TIMESHEET_WARNING_URI]) {
        severity = ViolationSeverityWarning;
    } else if ([severityURI isEqualToString:GEN4_TIMESHEET_INFORMATION_URI]) {
        severity = ViolationSeverityInfo;
    }

    NSDictionary *waiverDictionary = violationDictionary[@"waiver"];
    Waiver *waiver = [self.waiverDeserializer deserialize:waiverDictionary];
    Violation *violation = [[Violation alloc] initWithSeverity:severity
                                                        waiver:waiver
                                                         title:violationTitle];

    return violation;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
