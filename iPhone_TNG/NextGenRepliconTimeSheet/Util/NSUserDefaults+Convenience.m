//
//  NSUserDefaults+Convenience.m
//  NextGenRepliconTimeSheet
//

#import "NSUserDefaults+Convenience.h"
#import <objc/runtime.h>

@implementation NSUserDefaults (Convenience)

+ (void)load {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(objectForKey:);
        SEL swizzledSelector = @selector(objectForKey_New:);
        
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
    });
}



- (nullable id)objectForKey_New: (NSString *)defaultName {
    id value = [self objectForKey_New :defaultName];
    if(value == nil) {
        value = [[NSUserDefaults standardUserDefaults] objectForKey_New:defaultName];
    }
    return value;
}

@end
