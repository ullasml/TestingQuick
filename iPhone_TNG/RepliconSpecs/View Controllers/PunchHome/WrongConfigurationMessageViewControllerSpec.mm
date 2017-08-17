#import <Cedar/Cedar.h>
#import "Theme.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "Constants.h"
#import "WrongConfigurationMessageViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WrongConfigurationMessageViewControllerSpec)

describe(@"WrongConfigurationMessageViewController", ^{
    __block WrongConfigurationMessageViewController *subject;
    __block id<Theme> theme;
    __block id<BSInjector, BSBinder> injector;
    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        subject = [[WrongConfigurationMessageViewController alloc] initWithTheme:theme];
        spy_on(subject);
    });
    
    describe(@"styling", ^{
        beforeEach(^{
            theme stub_method(@selector(supervisorDashboardBackgroundColor)).and_return([UIColor orangeColor]);
            subject.view should_not be_nil;
        });
        
        it(@"should style the background", ^{
            subject.view.backgroundColor should equal([UIColor orangeColor]);
        });
    });
    
    
    
    describe(@"after the view loads", ^{
        beforeEach(^{
            theme stub_method(@selector(teamStatusValueFont)).and_return([UIFont italicSystemFontOfSize:17.0f]);
            [subject view];
        });
        
        it(@"should have a Message Label button", ^{
            subject.view should contain(subject.msgLabel);
        });
        
        it(@"should have a Message", ^{
            subject.msgLabel.text should equal(RPLocalizedString(wrongConfigurationMsg, wrongConfigurationMsg));
        });
        
        it(@"use theme to set message font and textcolor", ^{
            subject.msgLabel.font should equal([UIFont italicSystemFontOfSize:17.0f]);
        });
        
    });

});

SPEC_END
