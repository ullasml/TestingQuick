#import "ViolationSeverityPresenter.h"
#import "Violation.h"


@implementation ViolationSeverityPresenter

- (UIImage *)severityImageWithViolationSeverity:(ViolationSeverity)severity
{
    if (severity == ViolationSeverityError) {
        return [UIImage imageNamed:@"icon_severity_error"];
    }

    if (severity == ViolationSeverityWarning) {
        return [UIImage imageNamed:@"icon_severity_warning"];
    }

    return [UIImage imageNamed:@"icon_severity_info"];
}

@end
