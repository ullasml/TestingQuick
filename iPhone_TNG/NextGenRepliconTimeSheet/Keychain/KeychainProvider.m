#import "KeychainProvider.h"
#import "ACSimpleKeychain.h"


@implementation KeychainProvider

- (ACSimpleKeychain *)provideInstance
{
    return [ACSimpleKeychain defaultKeychain];
}

@end
