#import <Cedar/Cedar.h>
#import "ErrorReporter.h"
#import "LoginService.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ErrorReporterSpec)

describe(@"ErrorReporter", ^{
    __block ErrorReporter *subject;
    __block LoginService *loginService;

    beforeEach(^{
        loginService = nice_fake_for([LoginService class]);
        subject = [[ErrorReporter alloc]initWithLoginService:loginService];
    });

    context(@"-reportToCustomerSupportWithError", ^{
        beforeEach(^{
            NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error", @"NSErrorFailingURLStringKey":@"some fake url"};
            NSError *error = [[NSError alloc]initWithDomain:@"Unknown" code:-9999 userInfo:userInfo];
            [subject reportToCustomerSupportWithError:error];
        });
        it(@"should ask the login service to log error to customer support", ^{
            loginService should have_received(@selector(sendrequestToLogtoCustomerSupportWithMsg:serviceURL:)).with(@"some fake error",@"some fake url");
        });
    });
    context(@"-checkForServerMaintenanaceWithError:", ^{
        beforeEach(^{
            NSDictionary* userInfo = @{NSLocalizedDescriptionKey:@"some fake error", @"NSErrorFailingURLStringKey":@"some fake url"};
            NSError *error = [[NSError alloc]initWithDomain:@"Unknown" code:-9999 userInfo:userInfo];
            [subject checkForServerMaintenanaceWithError:error];
        });
        it(@"should ask the login service to check for Server Maintenanace", ^{
            loginService should have_received(@selector(sendRequestToCheckServerDownStatusWithServiceURL:)).with(@"some fake url");
        });
    });
});

SPEC_END
