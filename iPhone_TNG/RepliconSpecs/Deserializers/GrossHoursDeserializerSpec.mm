#import <Cedar/Cedar.h>
#import "GrossHoursDeserializer.h"
#import "GrossHours.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(GrossHoursDeserializerSpec)

describe(@"GrossHoursDeserializer", ^{
    __block GrossHoursDeserializer *grossHoursDeserializer;

    beforeEach(^{
        grossHoursDeserializer = [[GrossHoursDeserializer alloc] init];
    });
    
    it(@"should parse the gross hours value", ^{
        NSDictionary *grossHoursDictionary = @{
                                                  @"hours":@2,
                                                  @"minutes":@30
                                                  };
        
        GrossHours *grossHours = [grossHoursDeserializer deserializeForHoursDictionary:grossHoursDictionary];
        grossHours.hours should equal(@"2");
        grossHours.minutes should equal(@"30");
    });
    it(@"should return the gross hours nil value", ^{
        [grossHoursDeserializer deserializeForHoursDictionary:nil] should be_nil;
    });
    it(@"should parse the gross hours value", ^{
        NSDictionary *grossHoursDictionary = @{
                                               @"hours":@0,
                                               @"minutes":@0
                                               };
        
        GrossHours *grossHours = [grossHoursDeserializer deserializeForHoursDictionary:grossHoursDictionary];
        grossHours.hours should equal(@"0");
        grossHours.minutes should equal(@"0");
    });
});

SPEC_END
