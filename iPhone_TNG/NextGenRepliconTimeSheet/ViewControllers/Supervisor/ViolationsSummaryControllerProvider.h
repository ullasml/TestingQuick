#import <Foundation/Foundation.h>


@class ViolationsSummaryController;
@class KSPromise;
@protocol ViolationsSummaryControllerDelegate;


@interface ViolationsSummaryControllerProvider : NSObject

- (ViolationsSummaryController *)provideInstanceWithViolationSectionsPromise:(KSPromise *)violationSectionsPromise
                                                                    delegate:(id<ViolationsSummaryControllerDelegate>)delegate;

@end
