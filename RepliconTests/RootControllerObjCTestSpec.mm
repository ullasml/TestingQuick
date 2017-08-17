//#import "Cedar.h"
//#import "RepliconTests-Swift.h"
//
//using namespace Cedar::Matchers;
//using namespace Cedar::Doubles;
//
//SPEC_BEGIN(RootControllerObjCTestSpec)
//
///*
// This is a objective c test class .
// 
// - Matcher framework - Cedar. Can use Nimble too
// - Assertions framework - Cedar
// - Mocks/Stubs: Cedar Doubles
// */
//
//describe(@"RootController", ^{
//    __block RootController *subject;
//    __block URLSessionClient <CedarDouble> *urlSessionClient;
//    __block KSDeferred *deferred;
//    __block id <BSBinder,BSInjector> injector;
//
//    beforeEach(^{
//        deferred = [KSDeferred defer];
//        urlSessionClient = nice_fake_for([URLSessionClient class]);
//        subject = [[RootController alloc]initWithUrlSessionClient:urlSessionClient presenter:nil];
//        urlSessionClient stub_method(@selector(requestWithURL:)).with(@"http://jsonplaceholder.typicode.com/users").and_return(deferred.promise);
//        subject.view should_not be_nil;
//    });
//    
//    describe(@"When the view intially loads", ^{
//        
//        it(@"should have valid values", ^{
//            subject.testResultsStatus.text should equal(@"Getting Results...");
//        });
//    });
//    
//    describe(@"When the promise resolves", ^{
//        
//        beforeEach(^{
//            [deferred resolveWithValue:nil];
//        });
//        
//        it(@"should have valid values", ^{
//            subject.testResultsStatus.text should equal(@"Success");
//        });
//    });
//    
//    describe(@"When the promise is rejected", ^{
//        
//        beforeEach(^{
//            [deferred rejectWithError:nil];
//        });
//        
//        it(@"should have valid values", ^{
//            subject.testResultsStatus.text should equal(@"Failure");
//        });
//    });
//    
//});
//
//SPEC_END
