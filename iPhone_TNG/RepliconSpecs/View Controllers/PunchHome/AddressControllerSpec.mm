#import <Cedar/Cedar.h>
#import "AddressController.h"
#import "Theme.h"
#import <KSDeferred/KSDeferred.h>
#import "LocalPunch.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(AddressControllerSpec)

describe(@"AddressController", ^{
    __block AddressController *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
    });

    describe(@"showing the address", ^{
        context(@"when there is an address", ^{

            __block KSDeferred *localPunchDeferred;
            beforeEach(^{
                localPunchDeferred = [[KSDeferred alloc] init];
                theme stub_method(@selector(addressLabelFont)).and_return([UIFont systemFontOfSize:14]);
                theme stub_method(@selector(addressLabelTextColor)).and_return([UIColor yellowColor]);

                subject = [[AddressController alloc] initWithLocalPunchPromise:localPunchDeferred.promise
                                                               backgroundColor:[UIColor redColor]
                                                                       address:@"An address"
                                                                         theme:theme];
                [subject view];
            });

            it(@"should show the address when the view loads", ^{
                subject.addressLabel.text should equal(@"An address");
            });

            it(@"should show the address when the view loads", ^{
                subject.view.backgroundColor should equal([UIColor redColor]);
            });

            it(@"should style the address label correctly", ^{
                subject.addressLabel.font should equal([UIFont systemFontOfSize:14]);
                subject.addressLabel.textColor should equal([UIColor yellowColor]);
            });

            context(@"when the local punch promise is resolved", ^{
                it(@"should update the address label with the local punch's address if it has one", ^{
                    LocalPunch *punch = nice_fake_for([LocalPunch class]);
                    punch stub_method(@selector(address)).and_return(@"Updated address");

                    [localPunchDeferred resolveWithValue:punch];

                    subject.addressLabel.text should equal(@"Updated address");
                });

                it(@"should should show placeholder text if the punch has no address", ^{
                    LocalPunch *punch = nice_fake_for([LocalPunch class]);

                    [localPunchDeferred resolveWithValue:punch];

                    subject.addressLabel.text should equal(RPLocalizedString(LOCATION_UNAVAILABLE_STRING, @""));
                });
            });
        });

        context(@"when there is no address", ^{
            beforeEach(^{
                subject = [[AddressController alloc] initWithLocalPunchPromise:nil
                                                               backgroundColor:[UIColor redColor]
                                                                       address:nil
                                                                         theme:theme];
            });

            it(@"should show placeholder text when the view loads", ^{
                [subject view];
                NSString *gettingLocation = RPLocalizedString(LOCATION_UNAVAILABLE_STRING, @"");
                subject.addressLabel.text should equal(gettingLocation);
            });

            it(@"should show the address when the view loads", ^{
                subject.view.backgroundColor should equal([UIColor redColor]);
            });
        });
    });
});

SPEC_END
