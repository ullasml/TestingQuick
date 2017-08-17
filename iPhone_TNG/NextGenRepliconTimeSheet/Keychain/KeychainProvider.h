#import <Foundation/Foundation.h>


@class ACSimpleKeychain;


@interface KeychainProvider : NSObject

- (ACSimpleKeychain *)provideInstance;

@end
