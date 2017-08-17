#import <Foundation/Foundation.h>

@class KSPromise;

@protocol AssemblyGuard

- (KSPromise *)shouldAssemble;

@end