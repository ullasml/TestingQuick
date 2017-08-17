#import <UIKit/UIKit.h>
#import "Violation.h"


@interface ViolationSeverityPresenter : NSObject

- (UIImage *)severityImageWithViolationSeverity:(ViolationSeverity)severity;

@end
