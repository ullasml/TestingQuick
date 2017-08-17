#import <Cedar/Cedar.h>
#import "KeychainProvider.h"
#import "ACSimpleKeychain.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(KeychainProviderSpec)

describe(@"KeychainProvider", ^{
    __block KeychainProvider *subject;

    beforeEach(^{
        subject = [[KeychainProvider alloc] init];
    });

    describe(@"getting the keychain", ^{
        __block ACSimpleKeychain *keychain;
        beforeEach(^{
            keychain = [subject provideInstance];
        });

        it(@"should be the correct type", ^{
            keychain should be_instance_of([ACSimpleKeychain class]);
        });

        it(@"should be a singleton", ^{
            keychain should be_same_instance_as([subject provideInstance]);
        });
    });
});

SPEC_END
