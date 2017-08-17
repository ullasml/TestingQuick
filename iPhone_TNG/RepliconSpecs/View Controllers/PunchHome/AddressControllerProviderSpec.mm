#import <Cedar/Cedar.h>
#import "AddressControllerProvider.h"
#import "AddressController.h"
#import "Theme.h"
#import <KSDeferred/KSPromise.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(AddressControllerProviderSpec)

describe(@"AddressControllerProvider", ^{
    __block AddressControllerProvider *subject;
    __block id<Theme> theme;
    __block KSPromise *localPunchPromise;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        localPunchPromise = nice_fake_for([KSPromise class]);
        subject = [[AddressControllerProvider alloc] initWithTheme:theme];
    });

    describe(@"providing an instance", ^{
        __block AddressController *addressController;
        __block UIColor *backgroundColor;
        beforeEach(^{
            backgroundColor = [UIColor lightGrayColor];
            addressController = [subject provideInstanceWithAddress:@"My Address"
                                                  localPunchPromise:localPunchPromise
                                                    backgroundColor:backgroundColor];
        });

        it(@"should be the correct type", ^{
            addressController should be_instance_of([AddressController class]);
        });

        it(@"should set the address controller's properties correctly", ^{
            addressController.address should equal(@"My Address");
            addressController.theme should be_same_instance_as(theme);
            addressController.localPunchPromise should be_same_instance_as(localPunchPromise);
            addressController.backgroundColor should be_same_instance_as([UIColor lightGrayColor]);
        });
    });
});

SPEC_END
