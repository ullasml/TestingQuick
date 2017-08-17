#import <Cedar/Cedar.h>
#import "AddressControllerPresenterProvider.h"
#import "AddressControllerProvider.h"
#import <KSDeferred/KSPromise.h>
#import "AddressControllerPresenter.h"
#import "UserPermissionsStorage.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(AddressControllerPresenterProviderSpec)

describe(@"AddressControllerPresenterProvider", ^{
    __block AddressControllerPresenterProvider *subject;
    __block AddressControllerProvider *addressControllerProvider;
    __block UserPermissionsStorage *punchRulesStorage;
    __block id<Theme> theme;

    beforeEach(^{
        addressControllerProvider =  nice_fake_for([AddressControllerProvider class]);
        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        theme = nice_fake_for(@protocol(Theme));

        subject = [[AddressControllerPresenterProvider alloc] initWithAddressControllerProvider:addressControllerProvider
                                                                              punchRulesStorage:punchRulesStorage
                                                                                          theme:theme];
    });

    describe(@"Provide an instance", ^{
        __block KSPromise *localPunchPromise;
        __block AddressControllerPresenter *addressControllerPresenter;

        beforeEach(^{
            localPunchPromise = nice_fake_for([KSPromise class]);

            addressControllerPresenter = [subject provideInstanceWith:localPunchPromise];
        });

        it(@"should be the correct type", ^{
            addressControllerPresenter should be_instance_of([AddressControllerPresenter class]);
        });

        it(@"should have an addres controller provider", ^{
            addressControllerPresenter.addressControllerProvider should be_same_instance_as(addressControllerProvider);
        });

        it(@"should have punch rules storage", ^{
            addressControllerPresenter.punchRulesStorage should be_same_instance_as(punchRulesStorage);
        });

        it(@"should have a theme", ^{
            addressControllerPresenter.theme should be_same_instance_as(theme);
        });

        it(@"should have a local punch promise", ^{
            addressControllerPresenter.localPunchPromise should be_same_instance_as(localPunchPromise);
        });
    });
});

SPEC_END
