#if !__has_feature(objc_arc)
#error This class must be compiled with ARC
#endif

#import "UIPopoverController+Spec.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation UIPopoverController (Spec)

static __weak UIPopoverController *currentPopoverController__;
static UIPopoverArrowDirection arrowDirectionMask__;

#pragma clang diagnostic pop

+ (void)load {
    id cedarHooksProtocol = NSProtocolFromString(@"CDRHooks");
    if (cedarHooksProtocol) {
        class_addProtocol(self, cedarHooksProtocol);
    }
}

+ (instancetype)currentPopoverController {
    return currentPopoverController__;
}

+ (void)reset {
    currentPopoverController__ = nil;
}

+ (void)afterEach {
    [self reset];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    currentPopoverController__ = self;
    arrowDirectionMask__ = arrowDirections;
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated {
    currentPopoverController__ = self;
    arrowDirectionMask__ = arrowDirections;
}

- (void)dismissPopoverAnimated:(BOOL)animated {
    if ([self isPopoverVisible]) {
        [[self class] reset];
    }
}

- (BOOL)isPopoverVisible {
    return (self == currentPopoverController__);
}

- (UIPopoverArrowDirection)popoverArrowDirection {
    return arrowDirectionMask__;
}

#pragma clang diagnostic pop

@end
