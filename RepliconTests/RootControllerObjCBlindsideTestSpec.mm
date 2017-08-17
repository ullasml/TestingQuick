#import "Cedar.h"
#import "RepliconTests-Swift.h"
#import "UIControl+Spec.h"
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(RootControllerObjCBlindsideTestSpec)

/*
 This is a objective c test class .
 
 - Matcher framework - Cedar. Can use Nimble too
 - Assertions framework - Cedar
 - Mocks/Stubs: Cedar Doubles
*/

fdescribe(@"RootController", ^{
    __block RootController *subject;
    __block URLSessionClient <CedarDouble> *urlSessionClient;
    __block KSDeferred *deferred;
    __block id <BSInjector,BSBinder> injector;
    __block UINavigationController *navigationController;
    __block ObjectiveController *objectiveController;
    __block Presenter *presenter;



    beforeEach(^{
        injector = [InjectorProvider injector];
        deferred = [KSDeferred defer];
        presenter = nice_fake_for([Presenter class]);
        urlSessionClient = nice_fake_for(@protocol(URLSessionClientProtocol));
        objectiveController = nice_fake_for([ObjectiveController class]);
        [injector bind:@"ObjectiveController" toInstance:objectiveController];
        [injector bind:@"URLSessionClient" toInstance:urlSessionClient];
        [injector bind:@"Presenter" toInstance:presenter];

        subject = [injector getInstance:@"RootController"];
        navigationController = [[UINavigationController alloc]initWithRootViewController:subject];
        spy_on(navigationController);

        urlSessionClient stub_method(@selector(requestWithURL:)).with(@"http://jsonplaceholder.typicode.com/users").and_return(deferred.promise);
        subject.view should_not be_nil;
    });
    
    describe(@"When the view intially loads", ^{
        it(@"should have valid values", ^{
            subject.testResultsStatus.text should equal(@"Getting Results...");
        });
    });
    
    describe(@"When the promise resolves", ^{
        
        beforeEach(^{
            [deferred resolveWithValue:nil];
        });
        
        it(@"should have valid values", ^{
            subject.testResultsStatus.text should equal(@"Success");
        });
    });
    
    describe(@"When the promise is rejected", ^{
        
        beforeEach(^{
            [deferred rejectWithError:nil];
        });
        
        it(@"should have valid values", ^{
            subject.testResultsStatus.text should equal(@"Failure");
        });
    });
    
    describe(@"When the user taps on button", ^{
        
        beforeEach(^{
            [[subject button] tap];
        });
        
        it(@"should have valid values", ^{
            navigationController should have_received(@selector(pushViewController:animated:)).with(objectiveController,true);
        });
    });
    
    
    
});

SPEC_END
