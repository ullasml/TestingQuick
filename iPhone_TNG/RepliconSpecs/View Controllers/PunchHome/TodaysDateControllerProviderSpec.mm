#import <Cedar/Cedar.h>
#import "TodaysDateControllerProvider.h"
#import "DateProvider.h"
#import "TodaysDateController.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TodaysDateControllerProviderSpec)

describe(@"TodaysDateControllerProvider", ^{
    __block TodaysDateControllerProvider *subject;
    __block DateProvider *dateProvider;
    __block NSDateFormatter *dateFormatter;
    __block id<Theme> theme;

    beforeEach(^{
        dateProvider = nice_fake_for([DateProvider class]);
        dateFormatter = nice_fake_for([NSDateFormatter class]);
        theme = nice_fake_for(@protocol(Theme));
        subject = [[TodaysDateControllerProvider alloc] initWithDateProvider:dateProvider
                                                               dateFormatter:dateFormatter
                                                                       theme:theme];
    });

    describe(@"providing a todays date controller", ^{
        __block TodaysDateController *todaysDateController;
        beforeEach(^{
            todaysDateController = [subject provideInstance];
        });

        it(@"should create a TodaysDateController", ^{
            todaysDateController should be_instance_of([TodaysDateController class]);
        });

        it(@"should have the date provider", ^{
            todaysDateController.dateProvider should be_same_instance_as(dateProvider);
        });

        it(@"should have the date formatter", ^{
            todaysDateController.dateFormatter should be_same_instance_as(dateFormatter);
        });

        it(@"should have the theme", ^{
            todaysDateController.theme should be_same_instance_as(theme);
        });
    });
});

SPEC_END
