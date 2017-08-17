#import <Cedar/Cedar.h>
#import "ForgotPasswordRepository.h"
#import "ForgotPasswordRequestProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <repliconkit/ReachabilityMonitor.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ForgotPasswordRepositorySpec)

describe(@"ForgotPasswordRepository", ^{
    __block ForgotPasswordRepository *subject;
    __block id <RequestPromiseClient> client;
    __block ForgotPasswordRequestProvider *forgotPasswordRequestProvider;
    __block id<BSBinder,BSInjector> injector;
    __block ReachabilityMonitor *reachabilityMonitor;
    beforeEach(^{
        injector = [InjectorProvider injector];

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];

        forgotPasswordRequestProvider = nice_fake_for([ForgotPasswordRequestProvider class]);
        [injector bind:[ForgotPasswordRequestProvider class] toInstance:forgotPasswordRequestProvider];
        
        client = nice_fake_for(@protocol(RequestPromiseClient));
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];

        subject = [injector getInstance:[ForgotPasswordRepository class]];
        spy_on(subject);
    });
    
    
    describe(@"send password request", ^{
        __block NSURLRequest *request;
        __block KSPromise *clientPromise;
        beforeEach(^{
            clientPromise = nice_fake_for([KSPromise class]);
            request = nice_fake_for([NSURLRequest class]);
            forgotPasswordRequestProvider stub_method(@selector(provideRequestWithCompanyName:andemail:)).and_return(request);
            
            forgotPasswordRequestProvider stub_method(@selector(provideRequestWithPasswordResetRequestUri:)).and_return(request);
            
            client stub_method(@selector(promiseWithRequest:)).and_return(clientPromise);
        });
        
        describe(@"When passwordResetRequestWithCompanyName", ^{
            __block KSPromise *expectedPromise;
            
            beforeEach(^{
                
                expectedPromise = [subject passwordResetRequestWithCompanyName:@"my special company name" email:@"my special email"];
            });
            it(@"Request client should have received the request", ^{
                forgotPasswordRequestProvider should have_received(@selector(provideRequestWithCompanyName:andemail:)).with(@"my special company name",@"my special email");
            });
            
            it(@"request client should have received the url request", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });
            
            it(@"should return the expected promise", ^{
                expectedPromise should equal(clientPromise);
            });
        });
        
        describe(@"when sendRequestToResetPassword ToEmail", ^{
            __block KSPromise *expectedPromise;
            beforeEach(^{
                expectedPromise = [subject sendRequestToResetPasswordToEmail:@"my request URI"];
            });
            
            it(@"should have received the request", ^{
                forgotPasswordRequestProvider should have_received(@selector(provideRequestWithPasswordResetRequestUri:)).with(@"my request URI");
            });
            
            it(@"request client should have received the url request", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });
            
            it(@"should return the expected promise", ^{
                expectedPromise should equal(clientPromise);
            });
        });
        
    });
});

SPEC_END
