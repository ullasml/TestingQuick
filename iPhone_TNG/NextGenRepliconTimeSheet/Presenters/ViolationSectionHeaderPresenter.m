#import "ViolationSectionHeaderPresenter.h"
#import "DateProvider.h"
#import "ViolationEmployee.h"
#import "ViolationSection.h"


@interface ViolationSectionHeaderPresenter ()

@property (nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation ViolationSectionHeaderPresenter

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self) {
        self.dateFormatter = dateFormatter;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)sectionHeaderTextWithViolationSection:(ViolationSection *)violationSection
{
    id titleObject = violationSection.titleObject;

    switch(violationSection.type)
    {
        case ViolationSectionTypeEmployee:
            return [titleObject name];
        case ViolationSectionTypeDate:
            return [self.dateFormatter stringFromDate:titleObject];
        case ViolationSectionTypeTimesheet:
            return RPLocalizedString(@"Timesheet Level Violations", @"Timesheet Level Violations");
    }
}

@end
