#import <Cedar/Cedar.h>
#import "RepliconSpecHelper.h"
#import <Blindside/BlindSide.h>
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimeOffDeserializerSpec)

describe(@"TimeOffDeserializer", ^{
    __block TimeOffDeserializer *subject;
    __block id<BSInjector, BSBinder> injector;
    __block TimeoffModel *timeoffModel;
    __block LoginModel *loginModel;
    __block ApprovalsModel *approvalsModel;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        timeoffModel = nice_fake_for([TimeoffModel class]);
        loginModel = nice_fake_for([LoginModel class]);
        approvalsModel = nice_fake_for([ApprovalsModel class]);
        
        [injector bind:[TimeoffModel class] toInstance:timeoffModel];
        [injector bind:[LoginModel class] toInstance:loginModel];
        [injector bind:[ApprovalsModel class] toInstance:approvalsModel];
        
        subject = [injector getInstance:InjectorKeyTimeOffDeserializer];
    });

    
    describe(@"deserialize bookingParams", ^{
       __block NSDictionary *paramsDict;
        beforeEach(^{
            [subject deserializeTimeOffDetailsWithTimeOffUri:@"timeoff-uri"];

            id json = [RepliconSpecHelper jsonWithFixture:@"MultiDayTimeOff_Booking_Params"];
            paramsDict = [subject deserializeDurationOptionsAndSchedulesFrom:json];
        });
        
        it(@"should match duration options object and entries object", ^{
            
            TimeOffDuration *timeoffDuration1 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                              title:@"Full Day"
                                                                           duration:@"1.00"];
            
            TimeOffDuration *timeoffDuration2 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:three-quarter-day"
                                                                              title:@"3/4 Day"
                                                                           duration:@"0.75"];
            
            TimeOffDuration *timeoffDuration3 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:half-day"
                                                                              title:@"1/2 Day"
                                                                           duration:@"0.50"];

            TimeOffDuration *timeoffDuration4 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:quarter-day"
                                                                              title:@"1/4 Day"
                                                                           duration:@"0.25"];
            
            TimeOffDuration *timeoffDuration5 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                              title:@"None"
                                                                           duration:@"0.00"];

            
            TimeOffDurationOptions *timeOffDurationOptions1 = [[TimeOffDurationOptions alloc] initWithScheduleDuration:@"1.00" durationOptions:@[timeoffDuration1,timeoffDuration2,timeoffDuration3,timeoffDuration4,timeoffDuration5]];
            
            TimeOffDuration *timeoffDuration11 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                               title:@"Full Day"
                                                                            duration:@"1.00"];
            TimeOffDuration *timeoffDuration51 = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:none"
                                                                               title:@"None"
                                                                            duration:@"0.00"];
            TimeOffDurationOptions *timeOffDurationOptions2 = [[TimeOffDurationOptions alloc] initWithScheduleDuration:@"0.00" durationOptions:@[timeoffDuration51,timeoffDuration11]];

            
            TimeOffDuration *timeoffDuration = [[TimeOffDuration alloc] initWithUri:@"urn:replicon:time-off-relative-duration:full-day"
                                                                              title:@"Full Day"
                                                                           duration:@"1.00"];
            
            NSDate* date1 = [NSDate dateWithTimeIntervalSince1970:1492041600];
            NSDate* date2 = [NSDate dateWithTimeIntervalSince1970:1492128000];
            
            TimeOffEntry *timeOffEntry1 = [[TimeOffEntry alloc] initWithDate:date1
                                                            scheduleDuration:@"1.00"
                                                          bookingDurationObj:timeoffDuration
                                                                 timeStarted:@""
                                                                   timeEnded:@""];
            
            TimeOffEntry *timeOffEntry2 = [[TimeOffEntry alloc] initWithDate:date2
                                                            scheduleDuration:@"1.00"
                                                          bookingDurationObj:timeoffDuration
                                                                 timeStarted:@""
                                                                   timeEnded:@""];

            NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@[timeOffDurationOptions1, timeOffDurationOptions2], @"TimeOffDurationOptions",@[timeOffEntry1, timeOffEntry2], @"TimeOffEntry", nil];
            paramsDict.description should equal(dataDict.description);
        });
        
        it(@"timeoffModel should have received getTimeoffUserExplicitEntries", ^{
            timeoffModel should have_received(@selector(getTimeoffUserExplicitEntries:));
        });
    });
    
    describe(@"deserialize timeoff balance", ^{
        __block TimeOffBalance *timeOffBalance;
        beforeEach(^{
            id json = [RepliconSpecHelper jsonWithFixture:@"MultiDayTimeOff_Booking_Balance"];
            timeOffBalance = [subject getBalanceInfo:json[@"d"]];
        });
        
        it(@"should deserialize correct balance", ^{
            TimeOffBalance *timeoffBal = [[TimeOffBalance alloc] initWithTimeRemaining:@"-1.23"
                                                                             timeTaken:@"1.23"];
            
            timeOffBalance.description should equal(timeoffBal.description);
        });
    });
    
    context(@"Deserialize timeoff data from DB - User Flow", ^{
        describe(@"deserialize timeoff data from DB", ^{
            __block NSArray *timeOffDataArray;
            __block TimeOff *timeOff;
            beforeEach(^{
                [subject setTimeOffModelTypeWithType:TimeOffModelTypeTimeOff];
                timeOffDataArray = [NSArray arrayWithObjects:@{@"approvalStatus":@"Waiting for Approval",
                                                               @"approvalStatusUri":@"approvalStatusUri",
                                                               @"balancesDurationDays":[NSNull null],
                                                               @"balancesDurationDecimal":[NSNull null],
                                                               @"balancesDurationHour":[NSNull null],
                                                               @"comments":@"user-comments",
                                                               @"endDate":@1500422400,
                                                               @"endDateDurationDecimal":[NSNull null],
                                                               @"endDateDurationHour":[NSNull null],
                                                               @"endDateTime":[NSNull null],
                                                               @"endEntryDurationUri":[NSNull null],
                                                               @"hasTimeOffDeletetAcess":@1,
                                                               @"hasTimeOffEditAcess":@1,
                                                               @"isDeviceSupportedEntryConfiguration":@0,
                                                               @"isMultiDayTimeOff":@1,
                                                               @"shiftDurationDecimal":@0,
                                                               @"shiftDurationHour":@"0:0",
                                                               @"startDate":@1500336000,
                                                               @"startDateDurationDecimal":[NSNull null],
                                                               @"startDateDurationHour":[NSNull null],
                                                               @"startDateTime":[NSNull null],
                                                               @"startEntryDurationUri":[NSNull null],
                                                               @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                                               @"timeoffTypeName":@"Australia Annual Leave",
                                                               @"timeoffTypeUri":@"urn:replicon-tenant:repliconiphone-2:time-off-type:13",
                                                               @"timeoffUri":@"timeoff-uri",
                                                               @"timesheetUri":[NSNull null],
                                                               @"totalDurationDecimal":@44,
                                                               @"totalDurationHour":@"44:0",
                                                               @"totalTimeoffDays":@"2.00"}, nil];
                
                NSDictionary *userEntry1 = @{@"date":@1500336000,
                                             @"relativeDurationUri":@"urn:replicon:time-off-relative-duration:full-day",
                                             @"scheduledDuration":@"22.0",
                                             @"specificDuration":@"22.0",
                                             @"timeEnded":[NSNull null],
                                             @"timeOffUri":@"timeoff-uri",
                                             @"timeStarted":[NSNull null]
                                             };
                
                NSDictionary *userEntry2 = @{@"date":@1500422400,
                                             @"relativeDurationUri":@"urn:replicon:time-off-relative-duration:full-day",
                                             @"scheduledDuration":@"22.0",
                                             @"specificDuration":@"22.0",
                                             @"timeEnded":[NSNull null],
                                             @"timeOffUri":@"timeoff-uri",
                                             @"timeStarted":[NSNull null]
                                             };
                
                NSDictionary *timeOffDuration = @{@"displayText" : @"Full Day",
                                                  @"duration" : @"22.0",
                                                  @"scheduledDuration" : @"22.0",
                                                  @"timeOffUri" : @"urn:replicon-tenant:repliconiphone-2:time-off:19707",
                                                  @"uri" : @"urn:replicon:time-off-relative-duration:full-day"};
                
                NSDictionary *balanceDictionary = @{@"balanceRemainingDays":[NSNull null],
                                                    @"balanceRemainingHours":@"-403",
                                                    @"balanceTotalDays":[NSNull null],
                                                    @"requestedDays":[NSNull null],
                                                    @"requestedHours":@"8,21",
                                                    @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                                    @"timeOffURI":@"urn:replicon-tenant:repliconiphone-2:time-off:20273"};
                
                timeoffModel stub_method(@selector(getTimeoffUserExplicitEntries:)).and_return(@[userEntry1, userEntry2]);
                timeoffModel stub_method(@selector(getTimeoffScheduledDurations:)).and_return(@[timeOffDuration]);
                timeoffModel stub_method(@selector(getTimeoffInfoSheetIdentity:)).and_return(timeOffDataArray);
                timeoffModel stub_method(@selector(getTimeoffBalanceForMultidayBooking:)).and_return(balanceDictionary);
                timeOff = [subject deserializeTimeOffDetailsWithTimeOffUri:@"timeoff-uri"];
            });
            
            it(@"should have called time off model class", ^{
                timeoffModel should have_received(@selector(getTimeoffInfoSheetIdentity:)).with(@"timeoff-uri");
            });
            
            it(@"should have correct balance info", ^{
                timeOff.balanceInfo should be_instance_of([TimeOffBalance class]);
                timeOff.balanceInfo.timeTaken should equal(@"8.21");
                timeOff.balanceInfo.timeRemaining should equal(@"-403.00");
            });
            
            it(@"should return correct timeoff details values", ^{
                
                timeOff.details should be_instance_of([TimeOffDetails class]);
                timeOff.details.uri should equal(@"timeoff-uri");
                timeOff.details.canEdit should be_truthy;
                timeOff.details.canDelete should be_truthy;
                timeOff.details.userComments should equal(@"user-comments");
                timeOff.details.resubmitComments should equal(@"");
            });
            
            it(@"should return correct start day entry", ^{
                NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:1500336000];
                timeOff.startDayEntry.date should equal(startDate);
                timeOff.startDayEntry.scheduleDuration should equal(@"22.00");
                timeOff.startDayEntry.bookingDurationDetails.duration should equal(@"22.00");
                timeOff.startDayEntry.bookingDurationDetails.uri should equal(@"urn:replicon:time-off-relative-duration:full-day");
                timeOff.startDayEntry.bookingDurationDetails.title should equal(@"Full Day");
                timeOff.startDayEntry.timeEnded should equal(@"");
                timeOff.startDayEntry.timeStarted should equal(@"");
            });
            
            it(@"should return correct end day entry", ^{
                NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:1500422400];
                timeOff.endDayEntry.date should equal(endDate);
                timeOff.endDayEntry.scheduleDuration should equal(@"22.00");
                timeOff.endDayEntry.bookingDurationDetails.title should equal(@"Full Day");
                timeOff.endDayEntry.bookingDurationDetails.uri should equal(@"urn:replicon:time-off-relative-duration:full-day");
                timeOff.endDayEntry.timeEnded should equal(@"");
                timeOff.endDayEntry.timeStarted should equal(@"");
            });
            
            it(@"should have zero middle day entries", ^{
                timeOff.middleDayEntries.count should equal(0);
            });
            
            it(@"should have zero UDF's", ^{
                timeOff.allUDFs.count should equal(0);
            });
            
            it(@"should deserialize correct TimeOffDurationOptions", ^{
                TimeOffDurationOptions *timeOffDurationOptions = timeOff.allDurationOptions.firstObject;
                timeOff.allDurationOptions.count should equal(1);
                timeOffDurationOptions.scheduleDuration should equal(@"22.00");
                TimeOffDuration *timeOffDuration = timeOffDurationOptions.durationOptions.firstObject;
                timeOffDuration.title should equal(@"Full Day");
                timeOffDuration.duration should equal(@"22.00");
                timeOffDuration.uri should equal(@"urn:replicon:time-off-relative-duration:full-day");
            });
        });
        
        describe(@"deserialize all default timeOff type from DB", ^{
            __block TimeOffTypeDetails *timeOffTypeDetails;
            beforeEach(^{
                NSDictionary *timeOffType1 = @{@"enabled":@"1",
                                               @"minTimeoffIncrementPolicyUri":@"urn:replicon:policy:time-off:minimum-increment:no-minimum",
                                               @"startEndTimeSpecRequirementUri":@"urn:replicon:policy:require-start-end-time-for-partial-days",
                                               @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                               @"timeoffBalanceTrackingOptionUri":@"urn:replicon:time-off-balance-tracking-option:track-time-remaining",
                                               @"timeoffTypeName":@"Australia Annual Leave",
                                               @"timeoffTypeUri":@"type-uri"};
                
                NSDictionary *timeOffType2 = @{@"enabled":@"1",
                                               @"minTimeoffIncrementPolicyUri":@"urn:replicon:policy:time-off:minimum-increment:no-minimum",
                                               @"startEndTimeSpecRequirementUri":@"urn:replicon:policy:require-start-end-time-for-partial-days",
                                               @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:days",
                                               @"timeoffBalanceTrackingOptionUri":@"urn:replicon:time-off-balance-tracking-option:track-time-remaining",
                                               @"timeoffTypeName":@"Sick",
                                               @"timeoffTypeUri":@"type1-uri"};
                
                NSDictionary *defaultTimeOffType = @{@"enabled":@"1",
                                                     @"minTimeoffIncrementPolicyUri":@"urn:replicon:policy:time-off:minimum-increment:no-minimum",
                                                     @"startEndTimeSpecRequirementUri":@"urn:replicon:policy:require-start-end-time-for-partial-days",
                                                     @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:days",
                                                     @"timeoffBalanceTrackingOptionUri":@"urn:replicon:time-off-balance-tracking-option:track-time-remaining",
                                                     @"timeoffTypeName":@"Sick",
                                                     @"uri":@"type1-uri"};
                
                timeoffModel stub_method(@selector(getAllTimeOffTypesFromDB)).and_return(@[timeOffType1,timeOffType2]);
                timeoffModel stub_method(@selector(getDefaultTimeoffType)).and_return(defaultTimeOffType);
                timeOffTypeDetails = [subject getDefaultTimeOffType];
            });
            
            it(@"should equal the default timeoff type", ^{
                TimeOffTypeDetails *timeOffTypeDet = [[TimeOffTypeDetails alloc] initWithUri:@"type1-uri"
                                                                                       title:@"Sick"
                                                                              measurementUri:@"urn:replicon:time-off-measurement-unit:days"];
                timeOffTypeDetails.description should equal(timeOffTypeDet.description);
            });
            
            it(@"should return nil when there are no default timeOff type", ^{
                timeoffModel stub_method(@selector(getDefaultTimeoffType)).again().and_return(nil);
                timeOffTypeDetails = [subject getDefaultTimeOffType];
                timeOffTypeDetails should be_nil;
            });
        });
        
        describe(@"deserialize all all timeOff types from DB", ^{
            __block NSArray *timeOffTypeDetails;
            beforeEach(^{
                NSDictionary *timeOffType1 = @{@"enabled":@"1",
                                               @"minTimeoffIncrementPolicyUri":@"urn:replicon:policy:time-off:minimum-increment:no-minimum",
                                               @"startEndTimeSpecRequirementUri":@"urn:replicon:policy:require-start-end-time-for-partial-days",
                                               @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                               @"timeoffBalanceTrackingOptionUri":@"urn:replicon:time-off-balance-tracking-option:track-time-remaining",
                                               @"timeoffTypeName":@"Australia Annual Leave",
                                               @"timeoffTypeUri":@"type-uri"};
                
                NSDictionary *timeOffType2 = @{@"enabled":@"1",
                                               @"minTimeoffIncrementPolicyUri":@"urn:replicon:policy:time-off:minimum-increment:no-minimum",
                                               @"startEndTimeSpecRequirementUri":@"urn:replicon:policy:require-start-end-time-for-partial-days",
                                               @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:days",
                                               @"timeoffBalanceTrackingOptionUri":@"urn:replicon:time-off-balance-tracking-option:track-time-remaining",
                                               @"timeoffTypeName":@"Sick",
                                               @"timeoffTypeUri":@"type1-uri"};
                
                
                timeoffModel stub_method(@selector(getAllTimeOffTypesFromDB)).and_return(@[timeOffType1,timeOffType2]);
                timeOffTypeDetails = [subject getAllTimeOffType];
            });
            
            it(@"should equal number of objects", ^{
                timeOffTypeDetails.count should equal(2);
            });
            
            it(@"should equal the value of the objects", ^{
                TimeOffTypeDetails *timeOffTypeDet1 = [[TimeOffTypeDetails alloc] initWithUri:@"type-uri"
                                                                                        title:@"Australia Annual Leave"
                                                                               measurementUri:@"urn:replicon:time-off-measurement-unit:hours"];
                
                TimeOffDetails *obj1 = timeOffTypeDetails.firstObject;
                obj1.description should equal(timeOffTypeDet1.description);
            });
            
            it(@"should return nil when there are no default timeOff type", ^{
                timeoffModel stub_method(@selector(getAllTimeOffTypesFromDB)).again().and_return(nil);
                timeOffTypeDetails = [subject getAllTimeOffType];
                timeOffTypeDetails.count should equal(0);
            });
        });
    });
    
    context(@"Should call correct model types", ^{
        describe(@"should call timeOff model", ^{
            __block TimeOff *timeOff;
            beforeEach(^{
                [subject setTimeOffModelTypeWithType:TimeOffModelTypeTimeOff];
                timeOff = [subject deserializeTimeOffDetailsWithTimeOffUri:@"timeoff-uri"];
            });
        
            it(@"should have called time off model class", ^{
                timeoffModel should have_received(@selector(getTimeoffInfoSheetIdentity:)).with(@"timeoff-uri");
            });
            
            it(@"should call timeoff model for default timeoff type", ^{
                [subject getAllTimeOffType];
                timeoffModel should have_received(@selector(getAllTimeOffTypesFromDB));
            });
        });
        
        describe(@"should call apptovals pending", ^{
            __block TimeOff *timeOff;
            beforeEach(^{
                [subject setTimeOffModelTypeWithType:TimeOffModelTypePendingApproval];
                timeOff = [subject deserializeTimeOffDetailsWithTimeOffUri:@"timeoff-uri"];
            });
            
            it(@"should have called time off model class", ^{
                approvalsModel should have_received(@selector(getAllPendingTimeoffFromDBForTimeoff:)).with(@"timeoff-uri");
            });
            
            it(@"should call timeoff model for default timeoff type", ^{
                [subject getAllTimeOffType];
                approvalsModel should have_received(@selector(getAllPendingTimeOffsOfApprovalFromDB));
            });
        });
        
        describe(@"should call apptovals pending", ^{
            __block TimeOff *timeOff;
            beforeEach(^{
                [subject setTimeOffModelTypeWithType:TimeOffModelTypePreviousApproval];
                timeOff = [subject deserializeTimeOffDetailsWithTimeOffUri:@"timeoff-uri"];
            });
            
            it(@"should have called time off model class", ^{
                approvalsModel should have_received(@selector(getAllPreviousTimeoffFromDBForTimeoff:)).with(@"timeoff-uri");
            });
            
            it(@"should call timeoff model for default timeoff type", ^{
                [subject getAllTimeOffType];
                approvalsModel should have_received(@selector(getAllPreviousTimeOffsOfApprovalFromDB));
            });
        });
    });
    
});

SPEC_END
