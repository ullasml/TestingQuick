#import <Cedar/Cedar.h>
#import <Blindside/BlindSide.h>
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimeOffRequestProviderSpec)

describe(@"TimeOffRequestProvider", ^{
    __block TimeOffRequestProvider *subject;
    __block GUIDProvider *guidProvider;
    __block URLStringProvider *urlStringProvider;
    __block id<BSBinder, BSInjector> injector;
    __block NSUserDefaults *defaults;
    
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        urlStringProvider = nice_fake_for([URLStringProvider class]);
        guidProvider = nice_fake_for([GUIDProvider class]);
        defaults = nice_fake_for([NSUserDefaults class]);
        
        [injector bind:[URLStringProvider class] toInstance:urlStringProvider];
        [injector bind:[GUIDProvider class] toInstance:guidProvider];
        [injector bind:InjectorKeyStandardUserDefaults toInstance:defaults];
        
        guidProvider stub_method(@selector(guid)).and_return(@"ABC-123");
        
        subject = [injector getInstance:InjectorKeyTimeOffRequestProvider];
        [subject setUserUri:@"user-uri"];
        
    });
    
    describe(@"requestForBookingParams", ^{
        __block NSURLRequest *request;
        
        beforeEach(^{
            
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1492041600];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1492128000];
            
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"BookingParams")
            .and_return(@"http://expected.endpoint/mobile-backend/timeoff/booking/params");
            
            request = [subject requestForBookingParamsWithTimeOffTypeUri:@"timeoff-uri"
                                                               startDate:startDate
                                                                 endDate:endDate];
            
        });
        
        it(@"should have correct HTTPMethod method", ^{
            request.HTTPMethod should equal(@"POST");
        });
        
        it(@"should have correct URL", ^{
            request.URL.absoluteString should equal(@"http://expected.endpoint/mobile-backend/timeoff/booking/params");
        });
        
        it(@"should equal requestBody", ^{
            NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];
            NSDictionary *startDate = @{@"day":@13,@"month":@4,@"year":@2017};
            NSDictionary *endDate = @{@"day":@14,@"month":@4,@"year":@2017};
            NSDictionary *expectedRequestBodyDictionary = @{@"timeOffTypeUri": @"timeoff-uri",@"userUri":@"user-uri",@"startDate":startDate, @"endDate":endDate};
            
            requestBodyDictionary should equal(expectedRequestBodyDictionary);
        });
    });
    
    
    describe(@"Submit/Resubmit/TimeOffBalance", ^{
        __block NSURLRequest *request;
        __block TimeOff* timeOff;
        __block TimeOffTypeDetails *timeOffTypeDetails;
        __block TimeOffEntry *timeOffEntry1;
        __block TimeOffEntry *timeOffEntry2;
        __block TimeOffEntry *timeOffEntry3;
        __block TimeOffDurationOptions *timeOffDurationOptions;
        __block TimeOffUDF *timeOffUdf;
        __block TimeOffDetails *timeOffDetails;
        
        context(@"Submit", ^{
            beforeEach(^{
                TimeOffDuration *timeOffDuration1 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                TimeOffDuration *timeOffDuration2 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                TimeOffDuration *timeOffDuration3 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                                   title:@"None"
                                                                                duration:@"0.0"];
                
                
                NSDate *entryDate1 = [NSDate dateWithTimeIntervalSince1970:1492041600];
                NSDate *entryDate2 = [NSDate dateWithTimeIntervalSince1970:1492128000];
                NSDate *entryDate3 = [NSDate dateWithTimeIntervalSince1970:1492214400];
                
                timeOffEntry1 = [[TimeOffEntry alloc] initWithDate:entryDate1
                                                  scheduleDuration:@"8.0"
                                                bookingDurationObj:timeOffDuration1
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                timeOffEntry2 = [[TimeOffEntry alloc] initWithDate:entryDate2
                                                  scheduleDuration:@"8.0"
                                                bookingDurationObj:timeOffDuration2
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                timeOffEntry3 = [[TimeOffEntry alloc] initWithDate:entryDate3
                                                  scheduleDuration:@"0.0"
                                                bookingDurationObj:timeOffDuration3
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                
                NSArray *timeOffDurations = [NSArray arrayWithObjects:timeOffDuration1,timeOffDuration2,timeOffDuration3, nil];
                
                timeOffDurationOptions = [[TimeOffDurationOptions alloc] initWithScheduleDuration:@"0.0"
                                                                                  durationOptions:timeOffDurations];
                
                timeOffUdf = [[TimeOffUDF alloc] initWithName:@"Number Udf"
                                                        value:@"Hello"
                                                          uri:@"UDF-uri"
                                                      typeUri:@"type-uri"
                                                   timeOffUri:@"timeOff-uri"
                                                decimalPlaces:2
                                                   optionsUri:@"options-uri"];
                
                timeOffTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"timeoff-type-uri" title:@"Vacation" measurementUri:@"days-measure"];
                
                timeOffDetails = [[TimeOffDetails alloc] initWithUri:@"timeoff-type-uri"
                                                            comments:@"hello"
                                                    resubmitComments:@""
                                                                edit:true
                                                              delete:true];
                
                
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"MultiDayTimeoffSubmit")
                .and_return(@"http://expected.endpoint/mobile-backend/timeoff/submit");
                
                
                
                timeOff = [[TimeOff alloc] initWithStartDayEntry:timeOffEntry1
                                                     endDayEntry:timeOffEntry3
                                                middleDayEntries:@[timeOffEntry2]
                                              allDurationOptions:@[timeOffDurationOptions]
                                                         allUDFs:@[timeOffUdf]
                                                  approvalStatus:nil
                                                     balanceInfo:nil
                                                            type:timeOffTypeDetails
                                                         details:timeOffDetails];
                
                request = [subject requestForMultiDayTimeoffSubmitWithTimeOff:timeOff isNewBooking:YES];
            });
            
            it(@"should have correct HTTPMethod method", ^{
                request.HTTPMethod should equal(@"POST");
            });
            
            it(@"should have correct URL", ^{
                request.URL.absoluteString should equal(@"http://expected.endpoint/mobile-backend/timeoff/submit");
            });
            
            it(@"should equal requestBody", ^{
                NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];
                NSDictionary *startDate = @{@"date":@{@"day":@13,@"month":@4,@"year":@2017},
                                            @"relativeDuration":@"urn:replicon:time-off-relative-duration:full-day",
                                            @"specificDuration":[NSNull null],
                                            @"timeOfDay":[NSNull null]};
                
                NSDictionary *endDate = @{@"date":@{@"day":@15,@"month":@4,@"year":@2017},
                                          @"relativeDuration":[NSNull null],
                                          @"specificDuration":[NSNull null],
                                          @"timeOfDay":[NSNull null]};
                
                
                NSDictionary *multiDayUsingStartEndDate = @{@"timeOffEnd":endDate, @"timeOffStart":startDate};
                NSDictionary *owner = @{@"loginName":[NSNull null],@"parameterCorrelationId":[NSNull null],@"uri":@"user-uri"};
                NSDictionary *timeOffType = @{@"name":[NSNull null],@"uri":@"timeoff-type-uri"};
                NSArray *userExplicitEntries = @[@{@"date":@{@"day":@13,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":@"urn:replicon:time-off-relative-duration:full-day",
                                                   @"specificDuration":[NSNull null],
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]},
                                                 
                                                 @{@"date":@{@"day":@14,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":@"urn:replicon:time-off-relative-duration:full-day",
                                                   @"specificDuration":[NSNull null],
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]},
                                                 
                                                 @{@"date":@{@"day":@15,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":[NSNull null],
                                                   @"specificDuration":@"0.00",
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]}];
                
                NSDictionary *customField = @{@"customField":@{@"groupUri":[NSNull null],
                                                               @"name":@"Number Udf",
                                                               @"uri":@"UDF-uri"}};
                
                NSDictionary *expectedRequestBodyDictionary = @{@"comments":@"",
                                                                @"unitOfWorkId":@"ABC-123",
                                                                @"comments":@"resubmit",
                                                                @"data":@{ @"comments": @"hello",
                                                                           @"customFieldValues":@[customField],
                                                                           @"entryConfigurationMethodUri":@"urn:replicon:time-off-entry-configuration-method:populate-daily-entries-using-explicit-user-entries",
                                                                           @"multiDayUsingStartEndDate":multiDayUsingStartEndDate,
                                                                           @"owner":owner,
                                                                           @"target":[NSNull null],
                                                                           @"timeOffType":timeOffType,
                                                                           @"userExplicitEntries":userExplicitEntries,
                                                                           }};
                
                requestBodyDictionary should equal(expectedRequestBodyDictionary);
            });
        });
        
        context(@"Re-submit", ^{
            __block NSURLRequest *request;
            beforeEach(^{
                
                TimeOffDuration *timeOffDuration1 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                TimeOffDuration *timeOffDuration2 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                TimeOffDuration *timeOffDuration3 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                                   title:@"None"
                                                                                duration:@"0.0"];
                
                
                NSDate *entryDate1 = [NSDate dateWithTimeIntervalSince1970:1492041600];
                NSDate *entryDate2 = [NSDate dateWithTimeIntervalSince1970:1492128000];
                NSDate *entryDate3 = [NSDate dateWithTimeIntervalSince1970:1492214400];
                
                timeOffEntry1 = [[TimeOffEntry alloc] initWithDate:entryDate1
                                                  scheduleDuration:@"8.0"
                                                bookingDurationObj:timeOffDuration1
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                timeOffEntry2 = [[TimeOffEntry alloc] initWithDate:entryDate2
                                                  scheduleDuration:@"8.0"
                                                bookingDurationObj:timeOffDuration2
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                timeOffEntry3 = [[TimeOffEntry alloc] initWithDate:entryDate3
                                                  scheduleDuration:@"0.0"
                                                bookingDurationObj:timeOffDuration3
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                
                NSArray *timeOffDurations = [NSArray arrayWithObjects:timeOffDuration1,timeOffDuration2,timeOffDuration3, nil];
                
                timeOffDurationOptions = [[TimeOffDurationOptions alloc] initWithScheduleDuration:@"0.0"
                                                                                  durationOptions:timeOffDurations];
                
                timeOffUdf = [[TimeOffUDF alloc] initWithName:@"Number Udf"
                                                        value:@"Hello"
                                                          uri:@"UDF-uri"
                                                      typeUri:@"type-uri"
                                                   timeOffUri:@"timeOff-uri"
                                                decimalPlaces:2
                                                   optionsUri:@"options-uri"];
                
                timeOffTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"timeoff-type-uri" title:@"Vacation" measurementUri:@"days-measure"];
                
                timeOffDetails = [[TimeOffDetails alloc] initWithUri:@"timeoff-type-uri"
                                                            comments:@"hello"
                                                    resubmitComments:@""
                                                                edit:true
                                                              delete:true];
                
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"MultiDayTimeoffReSubmit")
                .and_return(@"http://expected.endpoint/mobile-backend/timeoff/resubmit");
                
                timeOff = [[TimeOff alloc] initWithStartDayEntry:timeOffEntry1
                                                     endDayEntry:timeOffEntry3
                                                middleDayEntries:@[timeOffEntry2]
                                              allDurationOptions:@[timeOffDurationOptions]
                                                         allUDFs:@[timeOffUdf]
                                                  approvalStatus:nil
                                                     balanceInfo:nil
                                                            type:timeOffTypeDetails
                                                         details:timeOffDetails];
                
                request = [subject requestForMultiDayTimeoffSubmitWithTimeOff:timeOff isNewBooking:NO];
            });
            it(@"should have correct HTTPMethod method", ^{
                request.HTTPMethod should equal(@"POST");
            });
            it(@"should have correct URL", ^{
                request.URL.absoluteString should equal(@"http://expected.endpoint/mobile-backend/timeoff/resubmit");
            });
            it(@"should equal requestBody", ^{
                NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];
                NSDictionary *startDate = @{@"date":@{@"day":@13,@"month":@4,@"year":@2017},
                                            @"relativeDuration":@"urn:replicon:time-off-relative-duration:full-day",
                                            @"specificDuration":[NSNull null],
                                            @"timeOfDay":[NSNull null]};
                
                NSDictionary *endDate = @{@"date":@{@"day":@15,@"month":@4,@"year":@2017},
                                          @"relativeDuration":[NSNull null],
                                          @"specificDuration":[NSNull null],
                                          @"timeOfDay":[NSNull null]};
                
                NSDictionary *multiDayUsingStartEndDate = @{@"timeOffEnd":endDate, @"timeOffStart":startDate};
                NSDictionary *owner = @{@"loginName":[NSNull null],@"parameterCorrelationId":[NSNull null],@"uri":@"user-uri"};
                NSDictionary *timeOffType = @{@"name":[NSNull null],@"uri":@"timeoff-type-uri"};
                NSArray *userExplicitEntries = @[@{@"date":@{@"day":@13,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":@"urn:replicon:time-off-relative-duration:full-day",
                                                   @"specificDuration":[NSNull null],
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]},
                                                 
                                                 @{@"date":@{@"day":@14,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":@"urn:replicon:time-off-relative-duration:full-day",
                                                   @"specificDuration":[NSNull null],
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]},
                                                 
                                                 @{@"date":@{@"day":@15,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":[NSNull null],
                                                   @"specificDuration":@"0.00",
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]}];
                
                NSDictionary *customField = @{@"customField":@{@"groupUri":[NSNull null],
                                                               @"name":@"Number Udf",
                                                               @"uri":@"UDF-uri"}};
                
                NSDictionary *expectedRequestBodyDictionary = @{@"comments":@"",
                                                                @"unitOfWorkId":@"ABC-123",
                                                                @"comments":@"resubmit",
                                                                @"data":@{ @"comments": @"hello",
                                                                           @"customFieldValues":@[customField],
                                                                           @"entryConfigurationMethodUri":@"urn:replicon:time-off-entry-configuration-method:populate-daily-entries-using-explicit-user-entries",
                                                                           @"multiDayUsingStartEndDate":multiDayUsingStartEndDate,
                                                                           @"owner":owner,
                                                                           @"target":@{@"uri":@"timeoff-type-uri"},
                                                                           @"timeOffType":timeOffType,
                                                                           @"userExplicitEntries":userExplicitEntries,
                                                                           }};
                
                requestBodyDictionary should equal(expectedRequestBodyDictionary);
            });
        });
        
        context(@"getTimeOffBalance", ^{
            __block NSURLRequest *request;
            
            beforeEach(^{
                urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
                .with(@"TimeoffBalance")
                .and_return(@"http://expected.endpoint/mobile-backend/timeoff/balance");
                
                TimeOffDuration *timeOffDuration1 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                TimeOffDuration *timeOffDuration2 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                                   title:@"Full Day"
                                                                                duration:@"8.0"];
                
                TimeOffDuration *timeOffDuration3 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                                   title:@"None"
                                                                                duration:@"0.0"];
                
                NSDate *entryDate1 = [NSDate dateWithTimeIntervalSince1970:1492041600];
                NSDate *entryDate2 = [NSDate dateWithTimeIntervalSince1970:1492128000];
                NSDate *entryDate3 = [NSDate dateWithTimeIntervalSince1970:1492214400];
                
                timeOffEntry1 = [[TimeOffEntry alloc] initWithDate:entryDate1
                                                  scheduleDuration:@"8.0"
                                                bookingDurationObj:timeOffDuration1
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                timeOffEntry2 = [[TimeOffEntry alloc] initWithDate:entryDate2
                                                  scheduleDuration:@"8.0"
                                                bookingDurationObj:timeOffDuration2
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                timeOffEntry3 = [[TimeOffEntry alloc] initWithDate:entryDate3
                                                  scheduleDuration:@"0.0"
                                                bookingDurationObj:timeOffDuration3
                                                       timeStarted:@""
                                                         timeEnded:@""];
                
                
                NSArray *timeOffDurations = [NSArray arrayWithObjects:timeOffDuration1,timeOffDuration2,timeOffDuration3, nil];
                
                timeOffDurationOptions = [[TimeOffDurationOptions alloc] initWithScheduleDuration:@"0.0"
                                                                                  durationOptions:timeOffDurations];
                
                timeOffUdf = [[TimeOffUDF alloc] initWithName:@"Number Udf"
                                                        value:@"Hello"
                                                          uri:@"UDF-uri"
                                                      typeUri:@"type-uri"
                                                   timeOffUri:@"timeOff-uri"
                                                decimalPlaces:2
                                                   optionsUri:@"options-uri"];
                
                timeOffTypeDetails = [[TimeOffTypeDetails alloc] initWithUri:@"timeoff-type-uri" title:@"Vacation" measurementUri:@"days-measure"];
                
                timeOffDetails = [[TimeOffDetails alloc] initWithUri:@"timeoff-type-uri"
                                                            comments:@"hello"
                                                    resubmitComments:@""
                                                                edit:true
                                                              delete:true];
                
                timeOff = [[TimeOff alloc] initWithStartDayEntry:timeOffEntry1
                                                     endDayEntry:timeOffEntry3
                                                middleDayEntries:@[timeOffEntry2]
                                              allDurationOptions:@[timeOffDurationOptions]
                                                         allUDFs:@[timeOffUdf]
                                                  approvalStatus:nil
                                                     balanceInfo:nil
                                                            type:timeOffTypeDetails
                                                         details:timeOffDetails];
                
                request = [subject getTimeOffBalanceWithTimeOff:timeOff];
            });
            
            it(@"should have correct HTTPMethod method", ^{
                request.HTTPMethod should equal(@"POST");
            });
            
            it(@"should have correct URL", ^{
                request.URL.absoluteString should equal(@"http://expected.endpoint/mobile-backend/timeoff/balance");
            });
            
            
            
            it(@"should equal requestBody", ^{
                
                NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];
                
                NSDate *entryDate1 = [NSDate dateWithTimeIntervalSince1970:1492041600];
                NSDate *entryDate2 = [NSDate dateWithTimeIntervalSince1970:1492214400];
                
                
                NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:entryDate1];
                
                NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:entryDate2];
                
                NSDictionary *startDate = @{@"date":@{@"day":[NSNumber numberWithInteger:components1.day],@"month":[NSNumber numberWithInteger:components1.month],@"year":[NSNumber numberWithInteger:components1.year]}};
                
                NSDictionary *endDate = @{@"date":@{@"day":[NSNumber numberWithInteger:components2.day],@"month":[NSNumber numberWithInteger:components2.month ],@"year":[NSNumber numberWithInteger:components2.year]}};
                
                
                NSDictionary *multiDayUsingStartEndDate = @{@"timeOffEnd":endDate, @"timeOffStart":startDate};
                NSDictionary *owner = @{@"uri":@"user-uri"};
                NSDictionary *timeOffType = @{@"uri":@"timeoff-type-uri"};
                NSArray *userExplicitEntries = @[@{@"date":@{@"day":@13,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":@"urn:replicon:time-off-relative-duration:full-day",
                                                   @"specificDuration":[NSNull null],
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]},
                                                 
                                                 @{@"date":@{@"day":@14,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":@"urn:replicon:time-off-relative-duration:full-day",
                                                   @"specificDuration":[NSNull null],
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]},
                                                 
                                                 @{@"date":@{@"day":@15,@"month":@4,@"year":@2017},
                                                   @"relativeDurationUri":[NSNull null],
                                                   @"specificDuration":@0,
                                                   @"timeEnded":[NSNull null],
                                                   @"timeStarted":[NSNull null]}];
                
                
                NSDictionary *expectedRequestBodyDictionary = @{@"timeOff": @{@"comments": @"",
                                                                              @"customFieldValues":@[],
                                                                              @"entryConfigurationMethodUri":@"urn:replicon:time-off-entry-configuration-method:populate-daily-entries-using-explicit-user-entries",
                                                                              @"multiDayUsingStartEndDate":multiDayUsingStartEndDate,
                                                                              @"owner":owner,
                                                                              @"target":@{@"uri":[NSNull null]},
                                                                              @"timeOffType":timeOffType,
                                                                              @"userExplicitEntries":userExplicitEntries,
                                                                              }};
                
                requestBodyDictionary should equal(expectedRequestBodyDictionary);
            });
        });
    });
    
    describe(@"delete timeoff", ^{
        __block NSURLRequest *request;
        __block TimeOffDetails *timeOffDetails;
        __block TimeOff *timeOff;
        
        beforeEach(^{
            TimeOffEntry *to = nice_fake_for([TimeOffEntry class]);
            TimeOffStatusDetails *ts = nice_fake_for([TimeOffStatusDetails class]);
            
            urlStringProvider stub_method(@selector(urlStringWithEndpointName:))
            .with(@"DeleteTimeOffData")
            .and_return(@"http://expected.endpoint/mobile-backend/TimeOffService1.svc/DeleteTimeOff");
            
            timeOffDetails = [[TimeOffDetails alloc] initWithUri:@"timeoff-uri"
                                                        comments:@"hello"
                                                resubmitComments:@""
                                                            edit:true
                                                          delete:true];
            timeOff = [[TimeOff alloc] initWithStartDayEntry:to
                                                 endDayEntry:to
                                            middleDayEntries:@[]
                                          allDurationOptions:@[]
                                                     allUDFs:@[]
                                              approvalStatus:ts
                                                 balanceInfo:nil
                                                        type:nil
                                                     details:timeOffDetails];
            
            request = [subject deleteTimeOffWithTimeOff:timeOff];
            
        });
        
        it(@"should have correct HTTPMethod method", ^{
            request.HTTPMethod should equal(@"POST");
        });
        
        it(@"should have correct URL", ^{
            request.URL.absoluteString should equal(@"http://expected.endpoint/mobile-backend/TimeOffService1.svc/DeleteTimeOff");
        });
        
        it(@"should equal requestBody", ^{
            NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:nil];
            NSDictionary *expectedRequestBodyDictionary = @{@"timeOffUri": @"timeoff-uri"};
            
            requestBodyDictionary should equal(expectedRequestBodyDictionary);
        });
    });
    
});

SPEC_END
