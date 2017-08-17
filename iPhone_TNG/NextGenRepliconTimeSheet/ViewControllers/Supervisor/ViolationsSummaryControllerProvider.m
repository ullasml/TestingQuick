#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "ViolationsSummaryControllerProvider.h"
#import "ViolationsSummaryController.h"
#import <KSDeferred/KSPromise.h>


@interface ViolationsSummaryControllerProvider ()

@property (nonatomic, weak) id<BSInjector> injector;

@end


@implementation ViolationsSummaryControllerProvider

- (ViolationsSummaryController *)provideInstanceWithViolationSectionsPromise:(KSPromise *)violationSectionsPromise
                                                                    delegate:(id<ViolationsSummaryControllerDelegate>)delegate
{
    ViolationsSummaryController *violationsSummaryController = [self.injector getInstance:[ViolationsSummaryController class]];
    [violationsSummaryController setupWithViolationSectionsPromise:violationSectionsPromise
                                                          delegate:delegate];
    return violationsSummaryController;
}

@end
