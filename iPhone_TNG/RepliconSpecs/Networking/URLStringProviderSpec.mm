#import <Cedar/Cedar.h>
#import "URLStringProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(URLStringProviderSpec)

describe(@"URLStringProvider", ^{
    __block URLStringProvider *subject;

    beforeEach(^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

        subject = [[URLStringProvider alloc] initWithUserDefaults:userDefaults];
    });

    it(@"should return the correct url for PutTimePunch", ^{
        NSString *urlString = [subject urlStringWithEndpointName:@"PutTimePunch2"];
        urlString should contain(@"mobile/TimePunchFlowService1.svc/BulkPutTimePunch2");
    });
});

SPEC_END
