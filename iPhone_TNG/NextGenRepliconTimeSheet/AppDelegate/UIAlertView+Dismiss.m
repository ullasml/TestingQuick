//
//  UIAlertView+Dismiss.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 10/3/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "UIAlertView+Dismiss.h"
#import <objc/runtime.h>

// see http://nshipster.com/method-swizzling/
static inline void swizzle(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation UIAlertView (Dismiss)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzle([self class], @selector(show), @selector(xxx_show));
        swizzle([self class], @selector(dismissWithClickedButtonIndex:animated:), @selector(xxx_dismissWithClickedButtonIndex:animated:));
    });
}

+ (void)dismissAllVisibleAlertViews
{
    BOOL inTests = (BOOL)NSClassFromString(@"XCTest");
    if (!inTests) {
        NSArray *visibleAlertViews = [[self visibleAlertViews] copy];
        for (NSValue *value in visibleAlertViews)
        {
            id val = value.nonretainedObjectValue;

            if ([val isKindOfClass: [UIAlertView class]])
            {
                [val dismissWithClickedButtonIndex: 0 animated: YES];
            }
        }
    }
    else
    {
        NSLog(@"---Need not dismiss alerts while Running Tests---");
    }


}

#pragma mark - Method Swizzling

- (void)xxx_show
{
    [self xxx_show];

    [[self.class visibleAlertViews] addObject: [NSValue valueWithNonretainedObject: self]];
}

- (void)xxx_dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [self xxx_dismissWithClickedButtonIndex: buttonIndex animated: animated];

    [[self.class visibleAlertViews] removeObject: [NSValue valueWithNonretainedObject: self]];
}

#pragma mark - Cache

+ (NSMutableSet *)visibleAlertViews
{
    static NSMutableSet *views = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        views = [NSMutableSet new];
    });

    return views;
}

@end